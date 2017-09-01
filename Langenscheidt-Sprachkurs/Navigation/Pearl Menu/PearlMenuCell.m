//
//  PearlMenuCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "PearlMenuCell.h"
#import "PearlTitle.h"
#import "UILabel+HTML.h"

#import "UserProgressManager.h"


@implementation PearlMenuCell

@synthesize pearl;
@synthesize titleLabel;
@synthesize progressRing;


//- (void) didMoveToSuperview {
//    
//    [super didMoveToSuperview];
//    
//    if (self.superview) {
//
//        [self _updateView];
//    }
//}


- (void) updateView {

    self.titleLabel.text = [PearlTitle titleForPearl:self.pearl];
    [self.titleLabel parseHTML];

    [self updateProgress];
    
    [self _updateConnectors];
}


- (void) updateProgress {
    
    CGFloat percentage = [[UserProgressManager instance] progressForPearl:self.pearl];
    progressRing.percentage = percentage;
}


- (void) _updateConnectors {
    
    BOOL topVisible = NO;
    BOOL bottomVisible = NO;
    
    switch (self.position) {
        
        case PearlMenuCellPositionFirst:
            topVisible = NO;
            bottomVisible = YES;
            break;

        case PearlMenuCellPositionLast:
            topVisible = YES;
            bottomVisible = NO;
            break;

        case PearlMenuCellPositionMiddle:
            topVisible = YES;
            bottomVisible = YES;
            break;

        default:
            break;
    }
    
    self.connectorTop.hidden = !topVisible;
    self.connectorBottom.hidden = !bottomVisible;
}

@end
