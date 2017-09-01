//
//  ExerciseNavigationBar.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ProgressBar.h"





@protocol ExerciseNavigationBarDelegate;


IB_DESIGNABLE @interface ExerciseNavigationBar : UIView

@property (nonatomic, assign) IBOutlet id<ExerciseNavigationBarDelegate> delegate;

@property (nonatomic, strong) UIButton* closeButton;

@property (nonatomic, strong) ProgressBar* progressBar;

@property (nonatomic, strong) UILabel* progressLabel;

@property (nonatomic, assign) IBInspectable NSInteger currentPosition;

@property (nonatomic, assign) IBInspectable NSInteger totalPositions;

@property (nonatomic, copy) IBInspectable NSString* fontName;

@property (nonatomic, assign) IBInspectable CGFloat fontSize;

@property (nonatomic, strong) IBInspectable UIColor* textColor;

@property (nonatomic, strong) IBInspectable UIColor* barForegroundColor;

@property (nonatomic, strong) IBInspectable UIColor* barBackgroundColor;

@property (nonatomic, assign) IBInspectable CGFloat progressBarHeight;

@property (nonatomic, assign) BOOL progressBarFinished;

- (void) createView;



@end



@protocol ExerciseNavigationBarDelegate <NSObject>

- (void) exerciseNavigationBarDidReceiveCloseCommand:(ExerciseNavigationBar*) navigationBar;

@end