//
//  LTXTLayoutView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 11.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "LTXTLayoutView.h"
#import "UIView+Extensions.h"


@implementation LTXTLayoutView

@synthesize string;
@synthesize fontName;
@synthesize fontSize;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    [self updateView];
}



- (void) updateView {

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIFont* font = [UIFont fontWithName:self.fontName size:self.fontSize];
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    UILabel* label = [[UILabel alloc] init];
    label.text = self.string;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor blueColor];
    label.font = font;
    CGRect textRect = [self.string boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                                options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                          NSFontAttributeName : font,
                                                          NSParagraphStyleAttributeName : paragraph
                                                          }
                                                context:nil];
    [label setFrameWidth:self.frame.size.width];
    [label setFrameHeight:textRect.size.height];
    
    [self addSubview:label];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|"
                                                                options:0
                                                                metrics:@{}
                                                                  views:NSDictionaryOfVariableBindings(label)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]-0-|"
                                                                 options:0
                                                                 metrics:@{}
                                                                   views:NSDictionaryOfVariableBindings(label)]];
    
}


- (CGSize) intrinsicContentSize {
    
    return self.frame.size;
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}




#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    [self updateView];
}


@end
