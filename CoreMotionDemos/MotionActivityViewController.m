//
//  MotionActivityViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

@import CoreMotion;

#import "MotionActivityViewController.h"


@interface MotionActivityViewController ()

@property (strong, nonatomic) CMMotionActivityManager *activityManager;
@property (strong, nonatomic) NSOperationQueue *motionActivityQueue;

@end


@implementation MotionActivityViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityManager = [[CMMotionActivityManager alloc] init];
    self.motionActivityQueue = [[NSOperationQueue alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self startActivityManager];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self stopActivityManager];
}


#pragma mark - CMMotionActivityManager

- (void)startActivityManager {
    
    __weak __typeof(self)weakSelf = self;
    
    CMMotionActivityHandler handler = ^(CMMotionActivity *activity){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // NOTE: Unlike CMPedometer, this does not receive an NSError
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf updateUIWithMotionActivity:activity];
            }
        });
    };
    
    [self.activityManager startActivityUpdatesToQueue:self.motionActivityQueue
                                          withHandler:handler];
}

- (void)stopActivityManager {
    
    [self.activityManager stopActivityUpdates];
    
    // update UI?
}


#pragma mark - Updating the UI

- (void)updateUIWithMotionActivity:(CMMotionActivity *)activity {
    
    NSLog(@"Motion Activity: %@", activity);
    
    // Update Confidence
    NSString *confidenceString = nil;
    UIColor *bgColor = [UIColor redColor];
    
    switch (activity.confidence) {
        case CMMotionActivityConfidenceHigh: {
            confidenceString = @"High Confidence";
            // more legible than that UIColor's greenColor
            bgColor = [UIColor colorWithRed:70.0/255.0
                                      green:115.0/255.0
                                       blue:81.0/255.0
                                      alpha:1.0];
            break;
        }
        case CMMotionActivityConfidenceMedium: {
            confidenceString = @"Medium Confidence";
            bgColor = [UIColor orangeColor];
            break;
        }
            
        case CMMotionActivityConfidenceLow: {
            confidenceString = @"Low Confidence";
            break;
        }
            
        default: {
            
            NSLog(@"WARNING: Unexpected motion activity confidence value: %ld", activity.confidence);
            confidenceString = @"Error";
            break;
        }
    }
    
//    NSDictionary *confidenceAttributes = @{ NSForegroundColorAttributeName : textColor };
//    self.confidenceLabel.attributedText = [[NSAttributedString alloc] initWithString:confidenceString
//                                                                          attributes:confidenceAttributes];
    
    self.confidenceLabel.text = confidenceString;
    self.confidenceLabel.backgroundColor = bgColor;
    
    // build results string
    NSMutableArray *activityStrings = [NSMutableArray arrayWithCapacity:2];
    
    // stationary
    NSString *stationaryString = activity.stationary ? @"Stationary" : @"Not Stationary";
    [activityStrings addObject:stationaryString];
    
    // These are all mutually exclusive BOOL properties of CMMotionActivity:
    if (activity.walking) {
        [activityStrings addObject:@"Walking"];
    }
    if (activity.running) {
        [activityStrings addObject:@"Running"];
    }
    if (activity.automotive) {
        [activityStrings addObject:@"Automotive"];
    }
    
    // cycling was added in iOS 8
    if ([activity respondsToSelector:@selector(cycling)]) {
        if ([activity cycling]) {
            [activityStrings addObject:@"Cycling"];
        }
    }
    if (activity.unknown) {
        [activityStrings addObject:@"Unknown"];
    }

    self.resultsLabel.text = [activityStrings componentsJoinedByString:@"\n"];
}

@end
