//
//  RoundedRectButton.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "RoundedRectButton.h"
#import "RoundedRectImage.h"


@implementation RoundedRectButton


@synthesize cornerRadius;
@synthesize borderColor;
@synthesize borderWidth;



- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    [self initialize];
    
    return self;
}


- (id) init {
    
    self = [super init];

    [self initialize];

    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImageCreated = NO;
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    if (!self.backgroundColor) {
        
        self.backgroundColor = [UIColor clearColor];
    }
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) layoutSubviews {

    [super layoutSubviews];
    
    [self _createBackgroundImageIfNeeded];
}





- (void) _createBackgroundImageIfNeeded {
    
    if (_backgroundImageCreated) return;
    
    
    UIImage* image = [RoundedRectImage roundedRectImageWithColor:self.tintColor cornerRadius:self.cornerRadius borderWidth:self.borderWidth borderColor:self.borderColor];
    
    
    _backgroundImageCreated = YES;

    [self setBackgroundImage:image forState:UIControlStateNormal];
    
}


- (void) prepareForInterfaceBuilder {
    
    [self awakeFromNib];
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"RoundedRectButton (frame=%@, title=%@)", NSStringFromCGRect(self.frame), self.titleLabel.text];
}

@end
