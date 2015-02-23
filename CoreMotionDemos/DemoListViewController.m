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


@interface DemoListViewController ()

@end


@implementation DemoListViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"PushToAltimeterSegue"]) {
        if ([CMAltimeter isRelativeAltitudeAvailable]) {
            return YES;
        } else {
            // show alert
            [self showDeviceNotCapableAlertWithMessage:@"This device does not support relative altitude measurements."];
            return NO;
        }
    }
    
    return YES;
}


#pragma mark - User Alerts

- (void)showDeviceNotCapableAlertWithMessage:(NSString *)message {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Device Lacks Capability"
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


@end
