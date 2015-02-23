//
//  FloorViewController.m
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/23/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

#import "FloorViewController.h"


@interface FloorViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end


@implementation FloorViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self tryToStartLocationUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Report Results

- (void)updateResultsWithSuccess:(BOOL)success message:(NSString *)message {
    
    NSDictionary *resultAttributes;
    if (success) {
        resultAttributes = @{ NSForegroundColorAttributeName : [UIColor greenColor] };
    } else {
        resultAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor] };
    }
    
    NSAttributedString *resultString = [[NSAttributedString alloc] initWithString:message
                                                                       attributes:resultAttributes];
    
    self.resultLabel.attributedText = resultString;
}


#pragma mark - Core Location Manager & Permissions

- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (void)tryToStartLocationUpdates {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // for iOS 7, check kCLAuthorizationStatusAuthorized. That's deprecated in iOS 8.
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        
        NSLog(@"User has already granted location authorization.");
        [self.locationManager startUpdatingLocation];
    } else {
        [self askForLocationPermission];
    }
}

- (void)askForLocationPermission {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        
        NSLog(@"Location turned off. Don't bother the user further.");
        
    } else {
        
        // This is iOS 8 only
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            // NOTE: adding an explanation of why you're asking to the Info.plist
            // as the value of the NSLocationWhenInUseUsageDescription key is
            // also required, or this will fail silently.
            // This is *not* the same as the key labeled "Privacy - Location Usage Description"!
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            // this will trigger permissions request automatically on iOS 7.x and earlier
            [self.locationManager startUpdatingLocation];
        }
    }
}


#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"Location Authorization changed to %d", status);
    [self tryToStartLocationUpdates];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"Location updated: %@", newLocation);
    
    if (newLocation.floor) {
        
        NSString *message = [NSString stringWithFormat:@"YES! You are on Floor %ld", (long)newLocation.floor.level];
        [self updateResultsWithSuccess:YES
                               message:message];
    } else {
        [self updateResultsWithSuccess:NO
                               message:@"Nope. The floor value is not defined for this location."];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Location Failure.");
    NSLog(@"Error: %@", [error localizedDescription]);
    NSLog(@"Error code %ld in domain: %@", (long)[error code], [error domain]);
    
    NSString *message = [NSString stringWithFormat:@"Location Failed with Error: %@", [error localizedDescription]];
    [self updateResultsWithSuccess:NO
                           message:message];
}

@end
