//
//  ParallaxingTableView.m
//  TTZSensorikTest
//
//  Created by Stefan Ueter on 10.07.14.
//  Copyright (c) 2014 stue. All rights reserved.
//

#import "ParallaxingTableViewController.h"
#import "ParallaxingTableView.h"


// WICHTIG: self.tableView muss vom Typ ParallaxingTableView sein, damit die Position von self.tableHeaderView nicht während des Scrollens (in layoutSubviews von UITableView) zurückgesetzt wird.



@implementation ParallaxingTableViewController


@synthesize parallaxingHeaderEnabled;
@synthesize parallaxingFooterEnabled;
@synthesize parallaxingRatio;
@synthesize parallaxingHeaderCap;


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

    parallaxingHeaderEnabled = true;
    parallaxingFooterEnabled = true;
    parallaxingRatio = 0.25;
    parallaxingHeaderCap = MAXFLOAT;
    _shouldUpdateParallaxing = NO;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateParallaxing) name:UIKeyboardDidHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateParallaxing) name:UIKeyboardWillHideNotification object:nil];

}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self scheduleUpdateParallaxing];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self scheduleUpdateParallaxing];
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
//    NSLog(@"didlayoutsubviews");
    
    [self scheduleUpdateParallaxing];
}


- (void) scheduleUpdateParallaxing {

    [self updateParallaxing];
    
//    _shouldUpdateParallaxing = YES;
//    __weak ParallaxingTableViewController* weakSelf = self;
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        if (_shouldUpdateParallaxing) {
//            
//            _shouldUpdateParallaxing = NO;
//            
//            [weakSelf updateParallaxing];
//        }
//    });
}


- (void) updateParallaxing {

    CGFloat offsetY = self.tableView.contentOffset.y;
    
//    NSLog(@"offset: %f", offsetY);
    
    if (self.parallaxingHeaderEnabled && self.tableView.tableHeaderView) {
        
        CGFloat parallaxingOffset = offsetY * parallaxingRatio;
        
        if (offsetY < 0) {
            
            parallaxingOffset = 0;
        }
        else if (offsetY > 0) {
            
            if (parallaxingOffset > parallaxingHeaderCap) {
                
                parallaxingOffset = parallaxingHeaderCap;
            }
        }
        
//        [self.tableView.tableHeaderView setFrameX:0];
//        [self.tableView.tableHeaderView setFrameY:offsetY - parallaxingOffset];

        self.tableView.tableHeaderView.frame = ({  // ... because AutoLayout is such a buggy POS
        
            CGRect newRect = self.tableView.tableHeaderView.frame;
            newRect.origin.x = 0;
            
            newRect;
        });
        
        // edit 21.4.16 for langenscheidt
        
        [self updateHeaderWithOffsetY:offsetY - parallaxingOffset ];
    }
    
    
    if (self.parallaxingFooterEnabled && self.tableView.tableFooterView) {
        
        CGFloat contentHeight = self.tableView.contentSize.height;
        CGFloat tableViewHeight = self.tableView.frame.size.height;
        CGFloat footerHeight = self.tableView.tableFooterView.frame.size.height;
        CGFloat defaultFooterPositionY = MAX(contentHeight, tableViewHeight - self.tableView.tableHeaderView.frame.size.height) - footerHeight;
        CGFloat footerParallaxingEnterPositionY = contentHeight - (footerHeight / self.parallaxingRatio);
        
        CGFloat parallaxingOffset = 0;
        
        CGFloat overdragging = offsetY - (contentHeight - tableViewHeight);
        
        if (overdragging > 0) {
            
            parallaxingOffset = overdragging;
        }
        else if (offsetY + tableViewHeight > footerParallaxingEnterPositionY) {
            
            CGFloat visibleBottomLine = (offsetY + tableViewHeight);
            
            // difference between visible bottom most line of content inside tableview and footerParallaxingEnterPositionY (will be between 0 and footerHeight / self.parallaxingRatio, increases while scrolling down)
            CGFloat difference = visibleBottomLine - footerParallaxingEnterPositionY;
            
            parallaxingOffset = -((contentHeight - visibleBottomLine) + difference * self.parallaxingRatio) + footerHeight;
        }
        
//        [self.tableView.tableFooterView setFrameY:defaultFooterPositionY + parallaxingOffset];
        
        self.tableView.tableFooterView.frame = ({
        
            CGRect newRect = self.tableView.tableFooterView.frame;
            newRect.origin.y = defaultFooterPositionY + parallaxingOffset;
            
            newRect;
        });
    }
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    NSLog(@"didscroll");
    
    [self scheduleUpdateParallaxing];
}


- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

//    NSLog(@"didenddragging");

    [self scheduleUpdateParallaxing];
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
//    NSLog(@"didenddecelerating");

    [self scheduleUpdateParallaxing];
}


- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
//    NSLog(@"didendscrollinganimation");

    
    [self scheduleUpdateParallaxing];
}



- (void) updateHeaderWithOffsetY:(CGFloat)offsetY {
    
//    [self.tableView.tableHeaderView setFrameY:offsetY];
    
    self.tableView.tableHeaderView.frame = ({
        
        CGRect newRect = self.tableView.tableHeaderView.frame;
        newRect.origin.y = offsetY;
        
        newRect;
    });
}



- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end