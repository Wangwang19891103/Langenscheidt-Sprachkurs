//
//  TabbarController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "UserLessonNavigationController.h"


@interface TabbarController : UITabBarController <UITabBarControllerDelegate> {
    
    UserLessonNavigationController* _userLessonNavigationController;
    
    NavigationController* _courseNavigationController;
}

@end
