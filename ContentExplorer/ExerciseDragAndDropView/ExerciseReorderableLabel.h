//
//  ExerciseReorderableView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReorderableViewProtocol.h"
@import UIKit;

@interface ExerciseReorderableLabel : UILabel <ReorderableViewProtocol>

@property (nonatomic, strong) UIColor* normalBackgroundColor;

@property (nonatomic, strong) UIColor* ghostBackgroundColor;

@end
