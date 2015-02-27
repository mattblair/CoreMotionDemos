//
//  RealTimePedometerViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//


@import CoreMotion;
@import AVFoundation;

#import "RealTimePedometerViewController.h"
#import "PedometerLogViewController.h"

// To access the seque indentifier constants.
// In a production app, those would be defined a constants file, not the root view controller.
#import "DemoListViewController.h"


typedef NS_ENUM(NSInteger, CMDRealTimeStartFrom) {
    CMDRealTimeStartFromNow = 0,
    CMDRealTimeStartFromSixHoursAgo,
    CMDRealTimeStartFromTwelveHoursAgo
};


@interface RealTimePedometerViewController ()

@property (strong, nonatomic) CMPedometer *pedometer;

@property (nonatomic) CMDRealTimeStartFrom startTimeFrom;

@property (strong, nonatomic) NSMutableArray *stepCountLog;
@property (strong, nonatomic) NSDateFormatter *timestampFormatter;

@property (strong, nonatomic) AVSpeechSynthesizer *announcer;

@end


@implementation RealTimePedometerViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.startTimeFrom = CMDRealTimeStartFromNow;
    self.startSegmentedControl.selectedSegmentIndex = self.startTimeFrom;
    
    self.pedometer = [[CMPedometer alloc] init];
    [self startQueryingPedometer];
    
    self.announcer = [[AVSpeechSynthesizer alloc] init];
    
    // capacity could be bigger for long-running tests
    self.stepCountLog = [[NSMutableArray alloc] initWithCapacity:40];
    
    // setup a date formatter for timestamping our log data:
    self.timestampFormatter = [[NSDateFormatter alloc] init];
    self.timestampFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    self.timestampFormatter.timeZone = [NSTimeZone localTimeZone];
    self.timestampFormatter.dateStyle = NSDateFormatterNoStyle;
    self.timestampFormatter.timeStyle = NSDateFormatterMediumStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Pedometer Management

- (NSDate *)dateForStartSelection:(CMDRealTimeStartFrom)startSelection {
    
    NSDate *returnDate = nil;
    
    switch (startSelection) {
        case CMDRealTimeStartFromNow: {
            returnDate = [NSDate date];
            break;
        }
            
        case CMDRealTimeStartFromSixHoursAgo: {
            returnDate = [[NSDate date] dateByAddingTimeInterval:-(6.0*60.0*60.0)];
            break;
        }
            
        case CMDRealTimeStartFromTwelveHoursAgo: {
            returnDate = [[NSDate date] dateByAddingTimeInterval:-(12.0*60.0*60.0)];
            break;
        }
            
        default: {
            // or an assertion
            NSLog(@"WARNING: Unhandled start index: %ld", startSelection);
            break;
        }
    }
    
    return returnDate;
}

- (void)startQueryingPedometer {
    
    __weak __typeof(self)weakSelf = self;
    
    CMPedometerHandler handler = ^(CMPedometerData *pedometerData, NSError *error){
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error) {
            
            NSLog(@"Real-time pedometer updates failed with error: %@", [error localizedDescription]);
            
            // switch to main queue if we're going to do anything with UIKit
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf) {
                    self.resultsLabel.text = @"There was an error.";
                }
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (strongSelf) {
                    [strongSelf handlePedometerData:pedometerData];
                }
            });
        }
    };
    
    [self.pedometer startPedometerUpdatesFromDate:[self dateForStartSelection:self.startTimeFrom]
                                      withHandler:handler];
    self.showLogsButton.enabled = YES;
}

- (void)stopQueryingPedometer {
    
    [self.pedometer stopPedometerUpdates];
    
    // clear out the timestamped log
    [self.stepCountLog removeAllObjects];
    self.showLogsButton.enabled = NO;
    
    self.resultsLabel.text = @"Updates stopped.";
}


#pragma mark - Data Presentation

// updated approximately every 2.5 seconds?
- (void)handlePedometerData:(CMPedometerData *)pmData {
    
    // Log it
    NSLog(@"Data Received: %@", pmData);
    
    NSString *timestampString = [self.timestampFormatter stringFromDate:pmData.endDate];
    NSString *logString = [NSString stringWithFormat:@"%@ - %@ steps",
                           timestampString, pmData.numberOfSteps];
    [self.stepCountLog addObject:logString];
    
    
    // Display it
    NSString *floorString;
    
    if ([CMPedometer isFloorCountingAvailable]) {
        floorString = [NSString stringWithFormat:@"Floors: %@ up, %@ down",
                       pmData.floorsAscended, pmData.floorsDescended];
    } else {
        floorString = @"(Floor counts not available on this device.)";
    }
    
    self.resultsLabel.text = [NSString stringWithFormat:@"%@ steps\n%1.2f meters\n%@\n\n(Update #%ld)",
                              pmData.numberOfSteps, [pmData.distance doubleValue],
                              floorString, self.stepCountLog.count];
    
    
    // Speak it
    NSString *countString =[NSString stringWithFormat:@"%@ steps", pmData.numberOfSteps];
    AVSpeechUtterance *countUtterance = [[AVSpeechUtterance alloc] initWithString:countString];
    countUtterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    countUtterance.rate = 0.3;
    
    [self.announcer speakUtterance:countUtterance];
}


#pragma mark - Respond to User Actions

- (IBAction)handleStartTimeSelected:(UISegmentedControl *)sender {
    
    self.startTimeFrom = self.startSegmentedControl.selectedSegmentIndex;
    NSLog(@"Would start gathering data from %@", [self dateForStartSelection:self.startTimeFrom]);
    
    // CMPedometer doesn't have any kind of isRunning property to test
    [self stopQueryingPedometer];
    
    [self startQueryingPedometer];
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:CMDSegueToPedometerLog]) {
        if (self.stepCountLog.count == 0) {
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Nothing To Show"
                                                                        message:@"There aren't any logged step counts to display."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleCancel
                                                                handler:nil];
            [ac addAction:closeAction];
            
            [self presentViewController:ac
                               animated:YES
                             completion:nil];
            
            return NO;
        } // else case will just continue on to return YES
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:CMDSegueToPedometerLog]) {
        
        PedometerLogViewController *logVC = (PedometerLogViewController *)[segue destinationViewController];
        logVC.logString = [self.stepCountLog componentsJoinedByString:@"\n"];
    }
}

@end
