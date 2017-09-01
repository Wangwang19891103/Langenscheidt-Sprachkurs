//
//  ShopPopupViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "ShopPopupViewController.h"
//#import "ShopViewController.h"
#import "ErrorMessageManager.h"



@implementation ShopPopupViewController

@synthesize closeBlock;


- (id) init {
    
    self = [super init];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
//    [[SubscriptionManager instance] addObserver:self];
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _effectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_effectView];
    
    _blendView = [[UIView alloc] init];
    _blendView.translatesAutoresizingMaskIntoConstraints = NO;
    _blendView.backgroundColor = [UIColor blackColor];
    _blendView.alpha = 0.5;
    [self.view addSubview:_blendView];
    
    _popupView = [[ShopPopupView alloc] init];
    _popupView.closeBlock = self.closeBlock;
    [self.view addSubview:_popupView];
    
    [_popupView createView];
    
    __weak ShopPopupView* weakPopup = _popupView;
    __weak ShopPopupViewController* weakself = self;
    
    _popupView.shopViewController.purchaseCompleteBlock = ^() {
        
        if (weakPopup.shopViewController.presentingPopup) {
            
            [weakPopup.shopViewController dismissPopupWithCompletionBlock:^() {
                
                NSLog(@"ShopPopupViewController - dismissing");
                
                weakself.closeBlock();
            }];
        }
        
    };
}


- (void) updateViewConstraints {
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_effectView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_effectView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_effectView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_effectView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_popupView]-(10)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_popupView]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupView)]];
    
    
    
    [super updateViewConstraints];
}



- (BOOL) prefersStatusBarHidden {
    
    return YES;
}




//#pragma mark - SubscriptionManagerObserver
//
//- (void) subscriptionManagerDidReportError:(NSError *)error {
//    
//    [self _handleSubscriptionManagerError:error];
//}
//
//
//- (void) subscriptionManagerPurchaseFailedForProduct:(SKProduct *)product {
//    
//    
//}


//- (void) subscriptionManagerDidFinishPurchasingProduct:(SKProduct *)product {
//    
//    NSString* title = @"Abonnement erfolgreich abgeschlossen";
//    NSString* message = @"Vielen Dank und viel Spaß beim Lernen.";
//    
//    [[ErrorMessageManager instance] showErrorPopupWithTitle:title message:message parentViewController:self completionBlock:^{
//        
//        self.closeBlock();
//    }];
//}




//#pragma mark - Error Handling
//
//- (void) _handleSubscriptionManagerError:(NSError*) error {
//    
//    [[ErrorMessageManager instance] handleError:error withParentViewController:self completionBlock:^{
//        
//        NSLog(@"completion block after error message");
//        
//        self.closeBlock();
//    }];
//}




- (void) dealloc {
    
    NSLog(@"ShopPopupViewController - dealloc");
    
//    [[SubscriptionManager instance] removeObserver:self];

}

@end
