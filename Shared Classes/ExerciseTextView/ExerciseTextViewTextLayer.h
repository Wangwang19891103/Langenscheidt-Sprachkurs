//
//  ExerciseTextViewTextLayer.h
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 12.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import QuartzCore;


@interface ExerciseTextViewTextLayer : CALayer

@property (nonatomic, copy) NSAttributedString* attributedString;

@property (nonatomic, assign) BOOL isWhitespace;

@property (nonatomic, assign) BOOL isNewline;

@end
