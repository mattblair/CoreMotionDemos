//
//  PedometerLogViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

#import "PedometerLogViewController.h"

@interface PedometerLogViewController ()

@end

@implementation PedometerLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logTextView.text = self.logString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
