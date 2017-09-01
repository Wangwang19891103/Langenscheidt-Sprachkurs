//
//  UserProgressManagerResetDataPopupView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface UserProgressManagerResetDataPopupView : UIView


@property (nonatomic, strong) void(^cancelBlock)();

@property (nonatomic, strong) void(^confirmBlock)();


- (IBAction)actionCancel:(id)sender;
- (IBAction)actionConfirm:(id)sender;

@end
