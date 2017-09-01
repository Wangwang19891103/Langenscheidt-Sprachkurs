//
//  NavigationController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface NavigationController : UINavigationController {
    
    UIView* _backgroundView;
}


- (void) forcePushViewController:(UIViewController*) viewController;

@end
