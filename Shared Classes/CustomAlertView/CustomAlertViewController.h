//
//  CustomAlertView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "CustomAlertView.h"

@interface CustomAlertViewController : UIViewController {
    
    UIVisualEffectView* _effectView;
    UIView* _blendView;
}

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) NSArray* contentViews;


- (void) showContentView:(UIView*) stepView animated:(BOOL) animated;

@end
