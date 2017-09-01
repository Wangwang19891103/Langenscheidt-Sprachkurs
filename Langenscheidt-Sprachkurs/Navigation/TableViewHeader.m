//
//  TableViewHeader.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

/*
 * Purpose of this class:
 *
 * Adding a table view header in interface builder directly does not work because it will not get its correct frame before layout process has finished. When the header is added to the view tree it has no correct frame and it appears that the table view layout process ignores the frame that is produced during the actual table view layout process. Instead the frame is taken (height) from when the header was added to the view tree originally (with the incorrect frame).
 *
 * This class will perform the layout process on itself (and subviews) to apply the correct frame.
 *
 * Usage:
 * - Create and design a header view (with this class) in interface builder. Do not assign it as the table view header but instead put it as a loose view.
 * - In viewDidLayoutSubviews of the view controller assign the view as the self.tableView.tableHeaderView (if its been nil)
 *
 */


#import "TableViewHeader.h"

@implementation TableViewHeader

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
}


- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];

    if (self.superview) {
    
        NSLog(@"header superview: %@", self.superview);
        
        [self _setProperFrame];
    }
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
}


- (void) _setProperFrame {
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGSize fittingSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    self.frame = ({
        
        CGRect newFrame = CGRectMake(0, 0, 0, 0);
        newFrame.size = fittingSize;
        newFrame;
    });
    
    NSLog(@"header new frame: %@", NSStringFromCGRect(self.frame));
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


@end
