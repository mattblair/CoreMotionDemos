//
//  PedometerLogViewController.h
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PedometerLogViewController : UIViewController

@property (strong, nonatomic) NSString *logString;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end
