

#import <Foundation/Foundation.h>
@import UIKit;
@import WebKit;
#import "RoundedRectButton.h"
//#import "FadeView.h"
#import "Course.h"
#import "ShopViewController.h"


@interface ShopPopupView : UIView <WKNavigationDelegate> {
    
    WKWebView* _webView;
    UIButton* _closeButton;
    UILabel* _titleLabel;
//    UIImageView* _iconImageView;
//    RoundedRectButton* _okButton;
//    FadeView* _fadeView;
    
    NSString* _file;
    
}

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, strong) Course* course;

@property (nonatomic, strong)     ShopViewController* shopViewController;



- (id) initWithFile:(NSString*) file;
- (void) createView;


@end
