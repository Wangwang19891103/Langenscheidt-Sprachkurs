//
//  SCRLabel.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 01.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;



typedef NS_ENUM(NSInteger, SnakeLabelState) {
    
    Normal,
    Selected,
    Correct,
    Wrong,
    Prefix
};


@interface SnakeLabel : UIView  {
    
    UILabel* _label;
    UIImageView* _imageView;
    
    UIImage* _imageNormal;
    UIImage* _imageSelected;
    UIImage* _imageCorrect;
    UIImage* _imageWrong;
    UIImage* _imagePrefix;
}


@property (nonatomic, copy) NSString* string;

//@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) BOOL correctAnswer;

@property (nonatomic, assign) SnakeLabelState state;



- (id) initWithString:(NSString*) p_string;

- (void) createView;


@end
