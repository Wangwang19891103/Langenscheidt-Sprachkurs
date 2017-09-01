//
//  ExercisePopupViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExercisePopupView.h"
#import "FadeView.h"


@interface ExercisePopupViewController : UIViewController {
    
    UIVisualEffectView* _effectView;
    ExercisePopupView* _popupView;
    UIView* _blendView;
}

@property (nonatomic, copy) NSString* file;

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, strong) Lesson* lesson;


- (id) initWithFile:(NSString*) p_file ;

@end
