//
//  TabbarController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "TabbarController.h"
#import "NavigationController.h"
#import "CourseViewController.h"
#import "PearlViewController.h"

#import "ContentDataManager.h"

#import "ClusterEventViewController.h"
#import "DevSettingsController.h"
#import "UserProgressManager.h"
#import "SettingsManager.h"

#import "Onboarding1ViewController.h"

#import "MoreMenuViewController.h"



#define ITEM_TAG_YOUR_LESSON            1001
#define ITEM_TAG_COURSES                1002

#define SEPARATOR_COLOR             [UIColor colorWithWhite:0.7 alpha:1.0]


@implementation TabbarController


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.delegate = self;
    
    return self;
}



#pragma mark - View

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self _createControllers];
    
    [self _addSeparators];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [self _showOnboarding];
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
//    [self _showOnboarding];

}




- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Onboarding"]) {
        
        __weak UIViewController* weakSelf = self;

        Onboarding1ViewController* controller = (Onboarding1ViewController*) segue.destinationViewController;
        controller.nextBlock = ^(void) {
            
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                
                
            }];
        };
    }
}



#pragma mark - Create Tabs

- (void) _createControllers {
    
    NSMutableArray* controllers = [NSMutableArray array];
    
    
    // tab 1: Deine Lektion
    {
        _userLessonNavigationController = [[UserLessonNavigationController alloc] init];
        
        [controllers addObject:_userLessonNavigationController];
        
        UIImage* image = [UIImage imageNamed:@"Tab Bar Item Image Your Lesson"];
        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Deine Lektion" image:image tag:ITEM_TAG_YOUR_LESSON];
        _userLessonNavigationController.tabBarItem = item;
        
        [controllers addObject:_userLessonNavigationController];
    }
    
    
    // tab 2: Kurse
    {
        CourseViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Course Menu"];
        
        _courseNavigationController = [[NavigationController alloc] initWithRootViewController:controller];

        UIImage* image = [UIImage imageNamed:@"Tab Bar Item Image Courses"];
        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Kurse" image:image tag:ITEM_TAG_COURSES];
        _courseNavigationController.tabBarItem = item;

        [controllers addObject:_courseNavigationController];
    }

    
    // tab 3: Mehr
    {
        UIStoryboard* moreStoryboard = [UIStoryboard storyboardWithName:@"more" bundle:[NSBundle mainBundle]];
        
        MoreMenuViewController* controller = [moreStoryboard instantiateInitialViewController];
        
        NavigationController* navigationController = [[NavigationController alloc] initWithRootViewController:controller];
        
        UIImage* image = [UIImage imageNamed:@"Tab Bar Item Image More"];
        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Mehr" image:image tag:ITEM_TAG_COURSES];
        navigationController.tabBarItem = item;
        
        [controllers addObject:navigationController];
    }

    
//    // many more controllers
//    
//    for (int i = 0; i < 10; ++i) {
//        
//        CourseViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Course Menu"];
//        
//        NavigationController* navigationController = [[NavigationController alloc] initWithRootViewController:controller];
//        
//        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Kurse" image:nil tag:1003 + i];
//        navigationController.tabBarItem = item;
//        
//        [controllers addObject:navigationController];
//    }
    
    
    
    
    
//    // DEV: cluster events
//    {
//        ClusterEventViewController* controller = [[ClusterEventViewController alloc] init];
//        
//        NavigationController* navigationController = [[NavigationController alloc] initWithRootViewController:controller];
//        
//        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Übungs-Events" image:nil tag:2000];
//        navigationController.tabBarItem = item;
//        
//        [controllers addObject:navigationController];
//    }
//
//    
//    // DEV: dev settings
//    {
//        DevSettingsController* controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Dev Settings"];
//        
//        NavigationController* navigationController = [[NavigationController alloc] initWithRootViewController:controller];
//        
//        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Entwickler-Einstellungen" image:nil tag:2001];
//        navigationController.tabBarItem = item;
//        
//        [controllers addObject:navigationController];
//    }

    
    
    [self setViewControllers:controllers];
}



#pragma mark - Separators

- (void) _addSeparators {

    // find buttons
    
    NSMutableArray* buttons = [NSMutableArray array];
    
    for (UIView* subview in self.tabBar.subviews) {
        
        if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            
            [buttons addObject:subview];
        }
    }
    
    
    // iterate buttons and add separators between them
    
    UIView* previousView = nil;
    
    for (int i = 0; i < buttons.count; ++i) {
        
        UIView* button = buttons[i];
        
        if (previousView) {  // insert separator before current button (only if its not the first button)
            
            [self _addSeparatorBetweenButton:previousView andButton:button];
        }
        
        previousView = button;
    }
}


- (void) _addSeparatorBetweenButton:(UIView*) button1 andButton:(UIView*) button2 {

    CGRect separatorFrame;
    
    separatorFrame.origin.x = (button1.frame.origin.x + button1.frame.size.width) + (button2.frame.origin.x - (button1.frame.origin.x + button1.frame.size.width)) * 0.5;
    separatorFrame.origin.y = 0;
    separatorFrame.size.width = 0.5;
    separatorFrame.size.height = self.tabBar.frame.size.height;
    
    
    UIView* separator = [[UIView alloc] init];
//    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = SEPARATOR_COLOR;
    separator.frame = separatorFrame;
    
    [self.tabBar addSubview:separator];
    
    
//    UIView* spacerLeft = [[UIView alloc] init];
//    spacerLeft.translatesAutoresizingMaskIntoConstraints = NO;
//    spacerLeft.backgroundColor = [UIColor clearColor];
//
//    UIView* spacerRight = [[UIView alloc] init];
//    spacerRight.translatesAutoresizingMaskIntoConstraints = NO;
//    spacerRight.backgroundColor = [UIColor clearColor];
//
//    
//    
//    [self.tabBar addSubview:separator];
//    [self.tabBar addSubview:spacerLeft];
//    [self.tabBar addSubview:spacerRight];
//    
//    [self.tabBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button1][spacerLeft][separator][spacerRight(==spacerLeft)][button2]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(button1, spacerLeft, separator, spacerRight, button2)]];
//    [self.tabBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[separator]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(separator)]];
}




#pragma mark - Tabbar Delegate

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    NSInteger tag = item.tag;
    
    switch (tag) {
        
        case ITEM_TAG_YOUR_LESSON:
        {
            [_userLessonNavigationController updateIfNeeded];
        }
            break;
            
        case ITEM_TAG_COURSES:
        {
//            [self _resetCourseNavigation];
        }
            break;
            
        default:
            break;
    }
    
}



//- (void) _resetCourseNavigation {
//
//    BOOL resetCourses = [[[SettingsManager instanceNamed:@"dev"] valueForKey:@"resetCourses"] boolValue];
//
//    if (resetCourses) {
//        
//        [_courseNavigationController popToRootViewControllerAnimated:NO];
//    }
//}


#pragma mark - Delegate




@end
