//
//  DemoListViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/23/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//


@import CoreMotion;

#import "DemoListViewController.h"
#import "FloorViewController.h"


NSString * const CMDSegueToMotionActivity = @"PushToActivityTypeSegue";
NSString * const CMDSegueToRealTimePedometer = @"PushToRealTimePedometerSegue";
NSString * const CMDSegueToHistoricalPedometer = @"PushToHistoricalPedometerSegue";
NSString * const CMDSegueToAltimeter = @"PushToAltimeterSegue";
NSString * const CMDSegueToCLFloor = @"PushToFloorSegue";
NSString * const CMDSegueToPedometerLog = @"PushToPedometerLogSegue";


@interface DemoListViewController ()

@end


@implementation DemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *linkButton = [[UIButton alloc] init];
    
    [linkButton setTitle:@"View Source and README on GitHub"
                forState:UIControlStateNormal];
    [linkButton setTitleColor:[UIColor blueColor]
                     forState:UIControlStateNormal];
    [linkButton addTarget:self
                   action:@selector(showOnGitHub:)
         forControlEvents:UIControlEventTouchUpInside];
    [linkButton sizeToFit];
    
    self.tableView.tableFooterView = linkButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    // Class methods which check device feature availability do not trigger
    // permissions requests
    
    if ([identifier isEqualToString:CMDSegueToMotionActivity]) {
        if ([CMMotionActivityManager isActivityAvailable]) {
            return YES;
        } else {
            
            [self showFeatureNotAvailableAlertWithMessage:@"This device does not support motion activity detection."];
            return NO;
        }
    }
    
    BOOL isPedometerRelated = [identifier isEqualToString:CMDSegueToRealTimePedometer] ||
    [identifier isEqualToString:CMDSegueToHistoricalPedometer];
    
    if (isPedometerRelated) {
        if ([CMPedometer isStepCountingAvailable]) {
            return YES;
        } else {
            [self showFeatureNotAvailableAlertWithMessage:@"This device does not support step counting."];
            return NO;
        }
    }
    
    if ([identifier isEqualToString:CMDSegueToAltimeter]) {
        if ([CMAltimeter isRelativeAltitudeAvailable]) {
            return YES;
        } else {
            [self showFeatureNotAvailableAlertWithMessage:@"This device does not support relative altitude measurements."];
            return NO;
        }
    }
    
    return YES;
}


#pragma mark - User Alerts

- (void)showFeatureNotAvailableAlertWithMessage:(NSString *)message {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Uh Oh. Not Available."
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    [ac addAction:closeAction];
    
    [self presentViewController:ac
                       animated:YES
                     completion:nil];
}


#pragma mark - Show on GitHub

- (void)showOnGitHub:(UIButton *)sender {
    
    NSURL *gitHubURL = [NSURL URLWithString:@"https://github.com/mattblair/CoreMotionDemos"];
    [[UIApplication sharedApplication] openURL:gitHubURL];
}


@end
