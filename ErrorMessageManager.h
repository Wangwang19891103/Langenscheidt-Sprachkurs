//
//  ErrorMessageManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 31.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ErrorMessageManager : NSObject {
    
    __block BOOL _displayingErrorMessage;
//    void(^_completionBlock)();
//    __block UIViewController* _parentViewController;
}

+ (instancetype)  instance;


- (void) handleError:(NSError*) error withParentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock;

- (void) showErrorPopupWithTitle:(NSString*) title message:(NSString*) message parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock;

@end
