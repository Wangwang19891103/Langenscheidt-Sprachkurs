//
//  KeyboardEventManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "KeyboardEventManager.h"

@implementation KeyboardEventManager


#pragma mark - Init

- (id) init {
    
    self = [super init];
    
    _observers = [NSMutableArray array];
    [self _registerForNotifications];
    
    return self;
}


+ (instancetype)  instance {
    
    static id __instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __instance = [[self alloc] init];
    });
    
    return __instance;
}



#pragma mark - Update Keyboard Frame

- (void) _setKeyboardFramesWithDictionary:(NSDictionary*) dictionary {
    
    _beginKeyboardFrame = [dictionary[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    _endKeyboardFrame = [dictionary[UIKeyboardFrameEndUserInfoKey] CGRectValue];
}



#pragma mark - Handle keyboard events

- (void) _handleKeyboardWillShow:(NSNotification*) notification {
    
    NSLog(@"will show");
    [self test:notification];
    
    [self _reportSelector:@selector(keyboardEventManagerKeyboardWillShow:)];
}


- (void) _handleKeyboardDidShow:(NSNotification*) notification {
    
    NSLog(@"did show");
    [self test:notification];
}


- (void) _handleKeyboardWillHide:(NSNotification*) notification {
    
    NSLog(@"will hide");
    [self test:notification];

    [self _reportSelector:@selector(keyboardEventManagerKeyboardWillHide:)];
}


- (void) _handleKeyboardDidHide:(NSNotification*) notification {
    
    NSLog(@"did hide");
    [self test:notification];
}


- (void) _handleKeyboardWillChangeFrame:(NSNotification*) notification {
    
    NSLog(@"will change frame");
    [self test:notification];
    
    [self _setKeyboardFramesWithDictionary:notification.userInfo];
}


- (void) _handleKeyboardDidChangeFrame:(NSNotification*) notification {
    
    NSLog(@"did change frame");
    [self test:notification];

    [self _setKeyboardFramesWithDictionary:notification.userInfo];
    
    [self _reportSelector:@selector(keyboardEventManagerKeyboardWillChangeFrame:)];
}


- (void) test:(NSNotification*) notification {
    
//    NSLog(@"%@", notification.userInfo);
}



#pragma mark - Observers

- (void) addObserver:(id<KeyboardEventManagerObserver>) observer {
    
    NSValue* value = [NSValue valueWithNonretainedObject:observer];
    
    [_observers addObject:value];
}


- (void) removeObserver:(id<KeyboardEventManagerObserver>) observer {
    
    NSValue* value = [NSValue valueWithNonretainedObject:observer];
    
    [_observers removeObject:value];
}


- (void) _reportSelector:(SEL) selector {
    
    for (NSValue* value in _observers) {
        
        id<KeyboardEventManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:selector]) {
            
            [observer performSelector:selector withObject:self];
        }
    }
}





#pragma mark - Register for notifications

- (void) _registerForNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleKeyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

@end
