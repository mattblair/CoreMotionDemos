//
//  FloorViewController.h
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/23/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@interface FloorViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *explainerLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

