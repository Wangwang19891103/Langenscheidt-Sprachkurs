//
//  ModalStackView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.07.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ModalStackViewController : UIViewController {
    
    NSMutableArray* _viewControllers;
    NSMutableDictionary* _configurations;
}

@property (nonatomic, copy) NSString* name;


+ (instancetype) instanceWithName:(NSString*) name;

+ (void) destroyInstanceWithName:(NSString*) name;

- (BOOL) isPresented;

- (void) addViewController:(UIViewController*) controller withConfiguration:(NSDictionary*) configDict;

- (void) addViewController:(UIViewController *)controller withConfiguration:(nonnull NSDictionary *)configDict completionBlock:(void (^)()) completionBlock;

- (void) dismissStackWithCompletionBlock:(void (^)()) completionBlock;


@end
