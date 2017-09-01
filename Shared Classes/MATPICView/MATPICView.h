//
//  MATPICVIew.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "MATPICItem.h"
#import "Lesson.h"


IB_DESIGNABLE


@protocol MATPICViewDelegate;


@interface MATPICView : UIView <MATPICItemDelegate> {
    
    UIView* _innerView;
    
    int _currentRound;
    
    BOOL _interactionBlocked;
}

@property (nonatomic, strong) NSArray* vocabularySets;

@property (nonatomic, copy) IBInspectable NSString* fontName;

@property (nonatomic, assign) IBInspectable CGFloat fontSize;

@property (nonatomic, strong) IBInspectable UIColor* fontColor;

@property (nonatomic, assign) IBInspectable CGFloat imageWidth;

@property (nonatomic, assign) IBInspectable CGFloat labelSpacing;

@property (nonatomic, assign) IBInspectable CGFloat horizontalSpacing;

@property (nonatomic, assign) IBInspectable CGFloat verticalSpacing;

@property (nonatomic, assign) BOOL animating;

@property (nonatomic, assign) IBOutlet id<MATPICViewDelegate> delegate;

@property (nonatomic, readonly) NSInteger scoreAfterFinish;

@property (nonatomic, readonly) NSInteger maxScore;

@property (nonatomic, assign) float roundDelay;

@property (nonatomic, strong) Lesson* lesson;  // used to retrieve resources


- (void) createView;


@end



@protocol MATPICViewDelegate <NSObject>

- (void) matpicView:(MATPICView*) matpicView didStartNewRoundWithVocabularySet:(NSDictionary*) vocabularySet;

- (void) matpicViewDidFinishLastRound:(MATPICView*) matpicView;

@end