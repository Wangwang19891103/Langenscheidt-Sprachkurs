//
//  StackView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "StackView.h"
#import "UIView+RemoveConstraints.h"


@implementation StackView

@synthesize spacing;
//@synthesize arrangedSubviews;#
@synthesize shouldStretch;



#pragma mark - Init

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self sharedInit];
    
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self sharedInit];
    
    return self;
}

- (void) awakeFromNib {
    
    [super awakeFromNib];
 
}

- (void) sharedInit {
    
//    _arrangedSubviews = [NSMutableArray array];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _subviewDict = [NSMutableDictionary dictionary];
}


#pragma mark - Setters

//- (void) setArrangedSubviews:(NSMutableArray *)p_arrangedSubviews {
//    
//    arrangedSubviews = [p_arrangedSubviews mutableCopy];
//}


# pragma mark - Public


//- (void) addSubview:(UIView *)view:(UIView *)subview {
//    
//    [arrangedSubviews addObject:subview];
//    [self addSubview:subview];
//    
//    [self setNeedsLayout];
//}


//- (void) removeArrangedSubview:(UIView*)subview {
//    
//    [arrangedSubviews removeObject:subview];
//
//    if (subview.superview == self) {
//        
//        [subview removeFromSuperview];
//    }
//    
//    [self setNeedsLayout];
//}
//
//
//- (void) removeAllArrangedSubviews {
//
//    for (UIView* subview in arrangedSubviews) {
//        
//        [self removeArrangedSubview:subview];
//    }
//}


- (void) addSubview:(UIView *)view withOrientation:(StackViewSubviewOrientation)orientation {
    
    _subviewDict[[NSValue valueWithNonretainedObject:view]] = @(orientation);
    
    [self addSubview:view];
    
    [self arrangeSubviews];
}


- (void) setNeedsUpdateConstraints {
    
    [super setNeedsUpdateConstraints];
    
//    NSLog(@"StackView - setneedsupdateconstraints");
}


- (void) setNeedsLayout {
    
    [super setNeedsLayout];
    
//    NSLog(@"StackView - setneedslayout");
}



#pragma mark - Private

- (void) arrangeSubviews {
    
    NSLog(@"StackView - arrangeSubviews");
    
    UIView* previousView = nil;
    
    for (UIView* subview in self.subviews) {
        
        StackViewSubviewOrientation subviewOrientation = [_subviewDict[[NSValue valueWithNonretainedObject:subview]] integerValue];
        
        subview.translatesAutoresizingMaskIntoConstraints = NO;
        
        // remove constraints affecting subview
        
        [self removeConstraintsAffectingSubview:subview];
        
        
//        if (self.shouldStretch) {
//            
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview(self)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview, self)]];
//        }
        
        // first subview top constraint
        
        if (!previousView) {
        
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[subview]"
                                                                         options:0
                                                                         metrics:@{}
                                                                           views:NSDictionaryOfVariableBindings(subview)]];
        }
        else {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-(spacing)-[subview]"
                                                                         options:0
                                                                         metrics:@{@"spacing" : @(spacing)}
                                                                           views:NSDictionaryOfVariableBindings(subview, previousView)]];
        }
        
        
        // horizontal constraints with orientation
        
        NSString* formatString = nil;
        
        switch (subviewOrientation) {

            default:
            case StackViewSubviewOrientationUndefined:
            case StackViewSubviewOrientationFill:
                formatString = @"H:|-[subview]-|";
                break;
                
            case StackViewSubviewOrientationLeft:
                formatString = @"H:|-[subview]-(>=right@1000,==right@500)-|";  // this is very important (priorities in relation to DialogBubble)
                break;

            case StackViewSubviewOrientationRight:
                formatString = @"H:|-(>=left@1000,==left@500)-[subview]-|";
                break;
                
        }
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                                     options:0
                                                                     metrics:@{@"left" : @(self.layoutMargins.left),
                                                                               @"right" : @(self.layoutMargins.right)}
                                                                       views:NSDictionaryOfVariableBindings(subview)]];
        
        
        
        previousView = subview;
    }
    
    // last subview bottom constraint
    
    if (previousView) {

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-|"
                                                                     options:0
                                                                     metrics:@{}
                                                                       views:NSDictionaryOfVariableBindings(previousView)]];
    }
    
    NSLog(@"Stackview: constraints: %@", self.constraints);
    
//    [self invalidateIntrinsicContentSize];
}


#pragma mark - Override

- (void) layoutSubviews {
    
    NSLog(@"StackView (%@) - layoutSubviews (frame: %@)", self.accessibilityLabel, NSStringFromCGRect(self.frame));
    
    [super layoutSubviews];
    
//    [self arrangeSubviews];
}


- (void) updateConstraints {
    
    
//    NSLog(@"StackView (%@) - updateConstraints", self.accessibilityLabel);
    
    [self arrangeSubviews];
    
    [super updateConstraints];

}


//- (CGSize) intrinsicContentSize {
//    
//    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
////    return self.frame.size;
//}


//- (CGSize) systemLayoutSizeFittingSize:(CGSize)targetSize {
//    
//    return UILayoutFittingCompressedSize;
//}


- (void) prepareForInterfaceBuilder {
    
    [self arrangeSubviews];
}

@end
