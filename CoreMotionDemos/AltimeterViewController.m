//
//  AltimeterViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/23/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

@import CoreMotion;

#import "AltimeterViewController.h"


@interface AltimeterViewController ()

@property (strong, nonatomic) NSMutableArray *altitudes;
@property (strong, nonatomic) NSOperationQueue *altimeterQueue;
@property (strong, nonatomic) CMAltimeter *altimeter;

@end


@implementation AltimeterViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([CMAltimeter isRelativeAltitudeAvailable]) {
        
        self.altimeter = [[CMAltimeter alloc] init];
        self.altimeterQueue = [[NSOperationQueue alloc] init];
        
    } else {
        NSLog(@"Device does not support relative altitude.");
        self.resultsLabel.text = @"This device does not support the measurement of relative altitude.";
    }
    
    self.altitudes = [[NSMutableArray alloc] initWithCapacity:40];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self stopUpdates];
}


#pragma mark - Requesting Data

- (void)startUpdates {
    
    __weak __typeof(self)weakSelf = self;
    
    CMAltitudeHandler handler = ^(CMAltitudeData *altitudeData, NSError *error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Altitude Data: %@", altitudeData);
            
            NSDictionary *resultAttributes;
            if ([altitudeData.relativeAltitude doubleValue] > 0) {
                resultAttributes = @{ NSForegroundColorAttributeName : [UIColor greenColor] };
            } else {
                resultAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor] };
            }
            
            // TODO: only change the colors of the values, not the whole thing
            
            NSString *resultString = [NSString stringWithFormat:@"Altitude Change:\n%1.2f meters\n\n Pressure:\n%1.4f kilopascals",
                                      [altitudeData.relativeAltitude doubleValue], [altitudeData.pressure doubleValue]];
            
            if (strongSelf) {
                strongSelf.resultsLabel.attributedText = [[NSAttributedString alloc] initWithString:resultString
                                                                                         attributes:resultAttributes];
            }
        });
    };
    
    // NOTE: This will reset to zero each time you start
    [self.altimeter startRelativeAltitudeUpdatesToQueue:self.altimeterQueue
                                            withHandler:handler];
}

- (void)stopUpdates {
    
    NSDictionary *resultAttributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
    
    self.resultsLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Stopped."
                                                                       attributes:resultAttributes];
    
    [self.altimeter stopRelativeAltitudeUpdates];
}

@end
