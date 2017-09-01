//
//  ViewController.h
//  MATPICTest
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MATPICView.h"


@interface ViewController : UIViewController <MATPICViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) IBOutlet MATPICView *matpicView;

@property (strong, nonatomic) IBOutlet UIButton *restartButton;

- (IBAction) handleRestart;

@end

