//
//  ReorderableLineLayoutView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "LineLayoutView.h"
#import "ReorderableViewProtocol.h"


@interface ReorderableLineLayoutView : LineLayoutView {
    
    UIView<ReorderableViewProtocol>* _draggedView; // the original view
    UIView* _dragView;  // the drag proxy
}

@property (nonatomic, readonly) BOOL animating;

- (BOOL) viewIsMovable:(UIView*) view;
- (BOOL) viewIsReorderable:(UIView*) view;

@end
