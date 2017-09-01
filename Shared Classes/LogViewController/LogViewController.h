//
//  LogViewController.h
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 03.07.14.
//  Copyright (c) 2014 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface LogViewController : UIViewController {
    
    UIScrollView* _scrollView;
    
    UIView* _contentView;
    
    float _posY;
    
    uint _entryCount;
}


- (void) addEntry:(NSString*) string withColor:(UIColor*) color;

@end
