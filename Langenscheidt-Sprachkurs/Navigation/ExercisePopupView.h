//
//  ExercisePopupView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import WebKit;
#import "RoundedRectButton.h"
#import "FadeView.h"
#import "Lesson.h"


@interface ExercisePopupView : UIView <WKNavigationDelegate> {
    
    WKWebView* _webView;
    UIButton* _closeButton;
    UIImageView* _iconImageView;
    RoundedRectButton* _okButton;
    FadeView* _fadeView;
    
    NSString* _file;
}

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, strong) Lesson* lesson;


- (id) initWithFile:(NSString*) file;
- (void) createView;


@end
