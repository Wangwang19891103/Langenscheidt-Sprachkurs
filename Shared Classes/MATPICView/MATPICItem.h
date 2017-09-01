//
//  MATPICItem.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@protocol MATPICItemDelegate;


typedef NS_ENUM(NSInteger, MATPICItemState) {
    
    Normal,
    Correct,
    Wrong,
    Missed
};


@interface MATPICItem : UIView {
    
    UIImageView* _imageView;
    UILabel* _label;
    UIView* _colorView;
    UIImageView* _checkImageView;
    
    UIImage* _checkImage;
    UIImage* _crossImage;
}

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, assign) CGFloat imageWidth;

@property (nonatomic, copy) NSAttributedString* attributedString;

@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) id<MATPICItemDelegate> delegate;

@property (nonatomic, assign) MATPICItemState state;


- (void) createView;


@end



@protocol MATPICItemDelegate <NSObject>

- (BOOL) itemShouldProcessTap:(MATPICItem*) item;

- (void) itemDidGetTapped:(MATPICItem*) item;

@end