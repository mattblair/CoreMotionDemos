//
//  MotionActivityViewController.h
//  CoreMotionDemos
//
//  Created by Matt Blair on 2/24/15.
//  Copyright (c) 2015 Elsewise LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MotionActivityViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *explainerLabel;
@property (weak, nonatomic) IBOutlet UILabel *confidenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultsLabel;

@end
