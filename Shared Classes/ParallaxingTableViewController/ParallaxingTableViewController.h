//
//  ParallaxingTableView.h
//  TTZSensorikTest
//
//  Created by Stefan Ueter on 10.07.14.
//  Copyright (c) 2014 stue. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ParallaxingTableViewController: UITableViewController {
    
    UIView* _parallaxingHeaderView;
    
    BOOL _shouldUpdateParallaxing;
}


@property (nonatomic, assign) BOOL parallaxingHeaderEnabled;

@property (nonatomic, assign) BOOL parallaxingFooterEnabled;

@property (nonatomic, assign) CGFloat parallaxingRatio;

@property (nonatomic, assign) CGFloat parallaxingHeaderCap;


- (void) updateHeaderWithOffsetY:(CGFloat) offsetY;

@end
