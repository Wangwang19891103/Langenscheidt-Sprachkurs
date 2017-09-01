//
//  DragAndDropInputView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

IB_DESIGNABLE


@interface DragAndDropInputView : UIInputView


@property (nonatomic, copy) IBInspectable NSString* buttonFontName;

@property (nonatomic, assign) IBInspectable CGFloat buttonFontSize;

@property (nonatomic, assign) IBInspectable CGFloat buttonHeight;

@property (nonatomic, assign) IBInspectable CGFloat buttonSideInsets;

@end
