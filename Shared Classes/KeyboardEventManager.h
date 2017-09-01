//
//  KeyboardEventManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@protocol KeyboardEventManagerObserver;



@interface KeyboardEventManager : NSObject  {
    
    NSMutableArray* _observers;
}


@property (nonatomic, readonly) CGRect beginKeyboardFrame;

@property (nonatomic, readonly) CGRect endKeyboardFrame;


+ (instancetype)  instance;


- (void) addObserver:(id<KeyboardEventManagerObserver>) observer;

- (void) removeObserver:(id<KeyboardEventManagerObserver>) observer;



@end



@protocol  KeyboardEventManagerObserver <NSObject>

- (void) keyboardEventManagerKeyboardWillShow:(KeyboardEventManager*) keyboardEventManager;

- (void) keyboardEventManagerKeyboardWillHide:(KeyboardEventManager*) keyboardEventManager;

- (void) keyboardEventManagerKeyboardWillChangeFrame:(KeyboardEventManager*) keyboardEventManager;

@end