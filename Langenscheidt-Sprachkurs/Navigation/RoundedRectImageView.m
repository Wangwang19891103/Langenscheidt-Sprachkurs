//
//  RoundedRectImageView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "RoundedRectImageView.h"
#import "RoundedRectImage.h"


@implementation RoundedRectImageView

@synthesize cornerRadius;
@synthesize borderColor;
@synthesize borderWidth;


- (void) awakeFromNib {
    
    [super awakeFromNib];

    [self _setImage];
}


- (void) _setImage {
    
    UIImage* image = [RoundedRectImage roundedRectImageWithColor:self.tintColor cornerRadius:self.cornerRadius borderWidth:self.borderWidth borderColor:self.borderColor];
    
    self.image = image;
}


- (void) update {
    
    [self _setImage];
}


- (void) prepareForInterfaceBuilder {
    
    [self _setImage];
}

@end
