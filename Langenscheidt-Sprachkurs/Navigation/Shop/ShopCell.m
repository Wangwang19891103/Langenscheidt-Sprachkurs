//
//  ShopCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "ShopCell.h"



#define BLUE            [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0]
#define GRAY            [UIColor colorWithWhite:0.9 alpha:1.0]
#define WHITE           [UIColor whiteColor]


// normal (gray)

#define BACKGROUND_COLOR_NORMAL         GRAY
#define BORDER_COLOR_NORMAL             nil
#define BORDER_WIDTH_NORMAL             3.0


// top seller (white blue)

#define BACKGROUND_COLOR_TOP            WHITE
#define BORDER_COLOR_TOP                BLUE
#define BORDER_WIDTH_TOP                3.0



@implementation ShopCell


- (void) prepareForReuse {
    
    [super prepareForReuse];
 
    self.monthLabel.text = @"";
    self.priceLabel.text = @"";
    self.descriptionLabel.text = @"";
    self.isTopseller = NO;
    self.isTopPrice = NO;
    self.isEarlyBird = NO;
    
    // reset
}


- (void) setIsTopseller:(BOOL)isTopseller {
    
    _isTopseller = isTopseller;
    
    [self update];
}


- (void) setIsTopPrice:(BOOL)isTopPrice {
    
    _isTopPrice = isTopPrice;
    
    [self update];
}


- (void) setIsEarlyBird:(BOOL)isEarlyBird {
    
    _isEarlyBird = isEarlyBird;
    
    [self update];
}


- (void) update {
    
    self.topSellerView.hidden = !_isTopseller;
    self.topPriceView.hidden = !_isTopPrice;
    self.earlyBirdView.hidden = !_isEarlyBird;
    
    UIColor* backgroundColor = nil;
    UIColor* borderColor = nil;
    CGFloat borderWidth = 0;
    
    if (_isTopseller || _isEarlyBird) {
        
        backgroundColor = BACKGROUND_COLOR_TOP;
        borderColor = BORDER_COLOR_TOP;
        borderWidth = BORDER_WIDTH_TOP;
    }
    else {
        
        backgroundColor = BACKGROUND_COLOR_NORMAL;
        borderColor = BORDER_COLOR_NORMAL;
        borderWidth = BORDER_WIDTH_NORMAL;
    }
    
    self.roundedRectImageView.tintColor = backgroundColor;
    self.roundedRectImageView.borderColor = borderColor;
    self.roundedRectImageView.borderWidth = borderWidth;
    
    [self.roundedRectImageView update];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(320, UIViewNoIntrinsicMetric);
}


- (IBAction) actionButton {
    
    _actionBlock();
}

@end
