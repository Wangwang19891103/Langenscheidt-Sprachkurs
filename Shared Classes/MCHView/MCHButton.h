//
//  MCHButton.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


typedef NS_ENUM(NSInteger, MCHButtonState) {

    Normal,
    Selected,
    Correct,
    Wrong,
    Missed
};


@interface MCHButton : UIView {
    
    UILabel* _label;
    UIImageView* _imageView;
    UIImageView* _checkImageView;
    
    UIImage* _imageNormal;
    UIImage* _imageSelected;
    UIImage* _imageCorrect;
    UIImage* _imageWrong;
    
    UIImage* _wrongImage;
    UIImage* _correctImage;
}

@property (nonatomic, copy) NSString* string;

@property (nonatomic, assign) MCHButtonState buttonState;


- (void) createView ;

@end
