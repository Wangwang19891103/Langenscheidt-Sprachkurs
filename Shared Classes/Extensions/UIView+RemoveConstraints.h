//
//  UIView+RemoveConstraints.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface UIView (RemoveConstraints)

- (void) removeConstraintsAffectingSubview:(UIView*) subview;

@end
