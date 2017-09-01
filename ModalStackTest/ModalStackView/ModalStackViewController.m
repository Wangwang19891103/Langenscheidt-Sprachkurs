//
//  ModalStackView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.07.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ModalStackViewController.h"


static NSMutableDictionary* __instances = nil;



@implementation ModalStackViewController


- (id) init {
    
    self = [super init];
    
    _viewControllers = [NSMutableArray array];
    _configurations = [NSMutableDictionary dictionary];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


+ (instancetype) instanceWithName:(NSString *)name {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __instances = [NSMutableDictionary dictionary];
    });
    
    ModalStackViewController* instance = __instances[name];
    
    if (!instance) {
        
        NSLog(@"ModalStackViewController - creating instance named '%@'", name);
        
        instance = [self new];
        instance.name = name;
        
        [__instances setObject:instance forKey:name];
    }
    
    return instance;
}


+ (void) destroyInstanceWithName:(NSString*) name {
    
    if (__instances) {
        
        if (__instances[name]) {

            NSLog(@"ModalStackViewController - destroying instance named '%@'", name);

            [__instances removeObjectForKey:name];
        }
        else {
            
            NSLog(@"ModalStackViewController - destroy - ERROR: no instance named '%@'", name);
            
        }
    }
}


#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = @"ModalStackViewController - view";
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}




#pragma mark - Is Presented

- (BOOL) isPresented {
    
    return self.presentingViewController != nil;
}



#pragma mark - Add ViewController

- (void) addViewController:(UIViewController *)controller withConfiguration:(nonnull NSDictionary *)configDict completionBlock:(void (^)()) completionBlock {
    
    NSValue* nonretainedController = [NSValue valueWithNonretainedObject:controller];
    
    [self _presentViewController:controller withCompletionBlock:completionBlock];


    // add VC after presentation has been initiated
    
    [_viewControllers addObject:nonretainedController];
    [_configurations setObject:[configDict copy] forKey:nonretainedController];
}


- (void) addViewController:(UIViewController *)controller withConfiguration:(nonnull NSDictionary *)configDict {

    [self addViewController:controller withConfiguration:configDict completionBlock:nil];
}


- (void) _presentViewController:(UIViewController*) controller withCompletionBlock:(void (^)()) completionBlock {
    
    NSValue* nonretainedController = [NSValue valueWithNonretainedObject:controller];
    NSDictionary* configDict = [_configurations objectForKey:nonretainedController];
    
    
    // fade out top VC before presenting new one
    
    [self _fadeOutTopViewController];

    
    UIViewController* presentingVC = [self _topViewControllerOrSelf];
    
    NSLog(@"presenting...");
    
    [presentingVC presentViewController:controller animated:YES completion:^{
        
        NSLog(@"presenting done.");
        
        if (completionBlock) {
            
            completionBlock();
        }
    }];
}



#pragma mark - Fade Out Top ViewController

- (void) _fadeOutTopViewController {
    
    UIViewController* topViewController = [self _topViewController];
    
    if (topViewController) {
        
        [UIView animateWithDuration:0.3 animations:^{

            NSLog(@"Fading out top ViewController (%@)...", topViewController.view.accessibilityIdentifier);
            
            topViewController.view.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
            NSLog(@"Fading out done.");
        }];
    }
}




#pragma mark - Dismiss Stack

- (void) dismissStackWithCompletionBlock:(void (^)()) completionBlock {
    
    __weak UIViewController* weakSelfPresentingVC = self.presentingViewController;
    
    
    UIViewController* topViewController = [self _topViewController];
    
    UIViewController* topPresentingVC = topViewController.presentingViewController;
    
    
    NSLog(@"dismissing top ViewController (%@)", topViewController.view.accessibilityIdentifier);
    
    [topPresentingVC dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"dismissing done");
        
        NSLog(@"dismissing modal stack VC (instant)...");
        
        [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
            
            [weakSelfPresentingVC dismissViewControllerAnimated:YES completion:^{
                
                NSLog(@"dismissing done.");
                
                [_viewControllers removeAllObjects];
                [_configurations removeAllObjects];
                
                completionBlock();
                
                [self _destroy];
            }];
            
        } completion:^(BOOL finished) {
            
            
        }];

    }];

    
    

    
//    [weakSelfPresentingVC dismissViewControllerAnimated:YES completion:^{
//
//        NSLog(@"dismissing done.");
//        
//        [_viewControllers removeAllObjects];
//        [_configurations removeAllObjects];
//        
//        completionBlock();
//        
//        [self _destroy];
//    }];
    
    
    
    
}



#pragma mark - Top ViewController

- (UIViewController*) _topViewController {
    
    UIViewController* topViewController = [_viewControllers.lastObject nonretainedObjectValue];
    
    return topViewController;
}


- (UIViewController*) _topViewControllerOrSelf {
    
    UIViewController* topViewController = [self _topViewController];
    
    if (topViewController) return topViewController;
    else return self;
}



#pragma mark - Destroy ModalStackViewController

- (void) _destroy {
    
    [ModalStackViewController destroyInstanceWithName:self.name];
}

@end
