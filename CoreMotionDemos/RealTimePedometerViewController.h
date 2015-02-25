//
//  RealTimePedometerViewController.h
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealTimePedometerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *startSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;
@property (weak, nonatomic) IBOutlet UIButton *showLogsButton;

- (IBAction)handleStartTimeSelected:(UISegmentedControl *)sender;

@end
