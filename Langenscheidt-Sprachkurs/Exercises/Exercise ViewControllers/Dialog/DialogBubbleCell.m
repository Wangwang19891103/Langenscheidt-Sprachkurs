//
//  DialogBubbleCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.03.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DialogBubbleCell.h"


#define MY_OWN_WORKING_LAYOUT_MARGINS       UIEdgeInsetsMake(8,8,8,8)


@implementation DialogBubbleCell

@synthesize innerView;


//- (void) prepareForReuse {
//    
//    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    
//    self.bubble = nil;
//}


- (void) setInnerView:(UIView *)p_innerView {
    
    innerView = p_innerView;
    
    if (innerView) {
        
        [self.contentView addSubview:innerView];
        
        // cell has width of tableView width assigned at this point (when dequeued from tableView)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
        });
        
        ;
        ;
        
        
    }
}


+ (UIEdgeInsets) margins {
    
    return MY_OWN_WORKING_LAYOUT_MARGINS;
}


- (void) updateConstraints {

    NSAssert(self.innerView, @"");
    
    UIEdgeInsets margins = MY_OWN_WORKING_LAYOUT_MARGINS;
    
    NSString* formatString = nil;
    
    
    if ([self.innerView isKindOfClass:[DialogBubble class]]) {
        
        if ([(DialogBubble*)self.innerView isNarratorBubble]) {
         
            formatString = @"H:|-(left)-[innerView]-(right)-|";
        }
        else {
        
            switch ([(DialogBubble*)self.innerView side]) {
                    
                case 0:
                    formatString = @"H:|-(left)-[innerView]-(>=right@1000,==right@500)-|";
                    break;
                    
                case 1:
                    formatString = @"H:|-(>=left@1000,==left@500)-[innerView]-(right)-|";
                    break;
                    
                default:
                    break;
            }
        }
    }
    else {
        
        formatString = @"H:|-(left)-[innerView]-(right)-|";
    }
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:@{@"left" : @(margins.left), @"right" : @(margins.right)} views:NSDictionaryOfVariableBindings(innerView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[innerView]" options:0 metrics:@{@"top" : @(margins.top), @"bottom" : @(margins.bottom)} views:NSDictionaryOfVariableBindings(innerView)]];
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(320, UIViewNoIntrinsicMetric);
}


- (NSString*) description {
    
    return [innerView description];
}


@end
