//
//  HistoricalPedometerViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//


@import CoreMotion;

#import "HistoricalPedometerViewController.h"


typedef NS_ENUM(NSInteger, CMDHistoricalTimeRange) {
    CMDHistoricalTimeRangeTwelveHours = 0,
    CMDHistoricalTimeRangeThreeDays,
    CMDHistoricalTimeRangeOneWeek
};


@interface HistoricalPedometerViewController ()

@property (nonatomic) CMDHistoricalTimeRange selectedTimeRange;

@property (strong, nonatomic) NSDateIntervalFormatter *timeRangeFormatter; // iOS 8+
@property (strong, nonatomic) NSNumberFormatter *stepCountFormatter;
@property (strong, nonatomic) NSLengthFormatter *distanceFormatter;        // iOS 8+

@property (strong, nonatomic) CMPedometer *pedometer;

@end


@implementation HistoricalPedometerViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedTimeRange = CMDHistoricalTimeRangeTwelveHours;
    self.timeRangeSegmentedControl.selectedSegmentIndex = self.selectedTimeRange;
    
    // These formatters could be instantiated lazily, but in this case, we know
    // they'll be used right away, so we might as well set them up.
    
    self.timeRangeFormatter = [[NSDateIntervalFormatter alloc] init];
    self.timeRangeFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    self.timeRangeFormatter.timeZone = [NSTimeZone localTimeZone];
    self.timeRangeFormatter.dateStyle = NSDateFormatterLongStyle;
    self.timeRangeFormatter.timeStyle = NSDateFormatterShortStyle;
    
    self.stepCountFormatter = [[NSNumberFormatter alloc] init];
    self.stepCountFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    self.stepCountFormatter.usesGroupingSeparator = YES; // not set by locale
    
    // unit depends on selected region, not language
    self.distanceFormatter = [[NSLengthFormatter alloc] init];
    self.distanceFormatter.numberFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    self.distanceFormatter.numberFormatter.maximumFractionDigits = 2;
    
    self.pedometer = [[CMPedometer alloc] init];
    [self queryPedometerData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Querying Pedometer Data

- (NSDate *)startDateForHistoricalTimeRange:(CMDHistoricalTimeRange)timeRange {
    
    // These date calculations are crude, and may not match the time ranges
    // all users expect. For a production app, consider assembling a start date
    // from NSDateComponents, along with NSLocale, NSCalendar, and NSTimeZone.
    
    NSDate *startDate = nil;
    
    switch (timeRange) {
        case CMDHistoricalTimeRangeTwelveHours: {
            startDate = [[NSDate date] dateByAddingTimeInterval:-(12.0*60.0*60.0)];
            break;
        }
            
        case CMDHistoricalTimeRangeThreeDays: {
            startDate = [[NSDate date] dateByAddingTimeInterval:-(3.0*24.0*60.0*60.0)];
            break;
        }
        case CMDHistoricalTimeRangeOneWeek: {
            startDate = [[NSDate date] dateByAddingTimeInterval:-(7.0*24.0*60.0*60.0)];
            break;
        }
            
        default: {
            NSLog(@"WARNING: Unexpected time range index: %ld", (long)timeRange);
            startDate = [NSDate date];
            break;
        }
    }
    return startDate;
}

- (void)queryPedometerData {
    
    __weak __typeof(self)weakSelf = self;
    
    CMPedometerHandler handler = ^(CMPedometerData *pedometerData, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error) {
            
            NSLog(@"Historical pedometer updates failed with error: %@", [error localizedDescription]);
            
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
    
    NSDate *startDate = [self startDateForHistoricalTimeRange:self.selectedTimeRange];
    
    [self.pedometer queryPedometerDataFromDate:startDate
                                        toDate:[NSDate date] // now
                                   withHandler:handler];
}


#pragma mark - Updating UI

- (void)handlePedometerData:(CMPedometerData *)pmData {
    
    NSLog(@"Pedometer Data: %@", pmData);
    
    // Using NSDateIntervalFormatter (iOS 8+)
    NSString *timeRangeString = [self.timeRangeFormatter stringFromDate:[pmData startDate]
                                                                 toDate:[pmData endDate]];
    
    // Using NSNumberFormatter
    NSString *stepCountString = [self.stepCountFormatter stringFromNumber:[pmData numberOfSteps]];
    NSString *numberOfStepsString = [NSString stringWithFormat:@"%@ steps", stepCountString];
    
    // Using NSLengthFormatter (iOS 8+)
    double distanceInMeters = [[pmData distance] doubleValue];
    NSString *distanceString = [self.distanceFormatter stringFromMeters:distanceInMeters];
    
    NSString *floorString;
    
    if ([CMPedometer isFloorCountingAvailable]) {
        
        // simple string formatting. Could use NSLocalizedString for template.
        floorString = [NSString stringWithFormat:@"Floors: %@ up, %@ down",
                       pmData.floorsAscended, pmData.floorsAscended];
    } else {
        floorString = @"(Floor counts not available on this device.)";
    }
    
    NSArray *resultStrings = @[timeRangeString,
                               @"",
                               numberOfStepsString,
                               distanceString,
                               floorString];
    
    self.resultsLabel.text = [resultStrings componentsJoinedByString:@"\n"];
}


#pragma mark - Respond to User Actions

- (IBAction)timeRangeSelected:(UISegmentedControl *)sender {
    
    self.selectedTimeRange = self.timeRangeSegmentedControl.selectedSegmentIndex;
    
    [self queryPedometerData];
}

@end
