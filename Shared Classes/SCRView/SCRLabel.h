//
//  SCRLabel.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 01.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ReorderableViewProtocol.h"


typedef NS_ENUM(NSInteger, SCRLabelState) {
    
    Normal,
    Ghost,
    Dragged,
    Immovable,
    Correct,
    Wrong
};


@interface SCRLabel : UIView <ReorderableViewProtocol> {
    
    UILabel* _label;
    UIImageView* _imageView;
    
    UIImage* _imageNormal;
    UIImage* _imageGhost;
    UIImage* _imageDragged;
    UIImage* _imageImmovable;
    UIImage* _imageCorrect;
    UIImage* _imageWrong;
}

@property (nonatomic, assign) SCRLabelState state;

@property (nonatomic, copy) NSString* string;


- (id) initWithString:(NSString*) p_string;

- (void) createView;

//- (UIView*) aaa;

@end
