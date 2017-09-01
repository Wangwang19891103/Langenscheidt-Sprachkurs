//
//  ExercisePopupView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExercisePopupView.h"
#import "RoundedRectImage.h"
#import "ContentManager.h"


#define BACKGROUND_COLOR     [UIColor whiteColor]
#define BORDER_COLOR         [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
#define BORDER_WIDTH        2.0
#define CORNER_RADIUS       5.0
#define INSETS      UIEdgeInsetsMake(CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS)

#define POPUP_TEMPLATE_FILE     @"popup_template.html"
#define POPUP_TEMPLATE_STRING   @"<!-- CONTENT -->"

#define BUTTON_TINT_COLOR       [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]


@implementation ExercisePopupView

@synthesize closeBlock;



- (id) initWithFile:(NSString*) file {
    
    self = [super init];
    
    _file = [file copy];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
//    self.clipsToBounds = YES;
    
    return self;
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) createView {

    _fadeView = [[FadeView alloc] init];
    _fadeView.translatesAutoresizingMaskIntoConstraints = NO;
    _fadeView.clipsToBounds = YES;
    _fadeView.enabled = YES;
    [self addSubview:_fadeView];

    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage* buttonImage = [UIImage imageNamed:@"Navigation Bar Close Button"];
    [_closeButton setImage:buttonImage forState:UIControlStateNormal];
    _closeButton.contentMode = UIViewContentModeCenter;
    [_closeButton addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
    
    UIImage* iconImage = [UIImage imageNamed:@"Popup"];
    _iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_iconImageView];
    
    _webView = [[WKWebView alloc] init];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.scrollView.clipsToBounds = NO;
    _webView.clipsToBounds = NO;
    _webView.navigationDelegate = self;
    [_fadeView addSubview:_webView];
    
//    NSString* path = [[[NSBundle mainBundle] pathForResource:@"Popups" ofType:nil] stringByAppendingPathComponent:_file];
    
    NSString* fullFilePath = [[ContentManager instance] popupPathForFileName:_file forLesson:self.lesson];
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];
    NSError* error;
    NSString* string = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
    
    if (!string) {
        
//        string = [NSString stringWithFormat:@"<p>Datei nicht gefunden (%@).</p>", _file];
    }
    
    NSString* HTMLString = [self _createHTMLStringWithString:string];
    
    [_webView loadHTMLString:HTMLString baseURL:nil];
    
    _okButton = [self _createOKButton];
    [self addSubview:_okButton];
    
    _fadeView.viewToFade = _webView;
    _fadeView.topLimitView = _iconImageView;
    _fadeView.bottomLimitView = _okButton;
    _fadeView.adjustmentTopLimit = 40;
    _fadeView.adjustmentBottomLimit = 40;
    _fadeView.adjustmentTopReach = 10;
    _fadeView.adjustmentBottomReach = 10;
    _fadeView.minimumAlpha = 0.03;
    
    [_fadeView createView];

}


- (NSString*) _createHTMLStringWithString:(NSString*) string {
    
    NSString* templatePath = [[NSBundle mainBundle] pathForResource:POPUP_TEMPLATE_FILE ofType:nil];
    NSString* templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:POPUP_TEMPLATE_STRING withString:string];
    
    return templateString;
}


- (void) updateConstraints {

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(border)-[_fadeView]-(border)-|" options:0 metrics:@{@"border" : @(BORDER_WIDTH)} views:NSDictionaryOfVariableBindings(_fadeView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(border)-[_fadeView]-(border)-|" options:0 metrics:@{@"border" : @(BORDER_WIDTH)} views:NSDictionaryOfVariableBindings(_fadeView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_closeButton(40)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_closeButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[_closeButton(40)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_closeButton)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_iconImageView]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_iconImageView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_iconImageView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_iconImageView)]];

    
    [_fadeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[_webView]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_webView)]];
    [_fadeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[_webView]-100-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_webView)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_okButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [_okButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_okButton(80)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_okButton)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_okButton(40)]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_okButton)]];

    
//    UIView* scrollView = _webView.scrollView;
//    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [_webView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(scrollView)]];
//    [_webView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(scrollView)]];
//
//    
//    UIView* contentView = scrollView.subviews[0];
//    contentView.translatesAutoresizingMaskIntoConstraints = NO;
//
//    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(contentView, _webView)]];
//    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(contentView)]];

    
    [super updateConstraints];
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    [self _layout];
}


- (void) _layout {
    
}


- (RoundedRectButton*) _createOKButton {
    
    RoundedRectButton* button = [[RoundedRectButton alloc] init];
    button.tintColor = BUTTON_TINT_COLOR;
    button.cornerRadius = 5.0;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR] resizableImageWithCapInsets:INSETS resizingMode:UIImageResizingModeStretch];
    
    [image drawInRect:rect];
}


- (void) actionClose {

    NSLog(@"close");
    
    self.closeBlock();
}


- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [super layoutSubviews];
    
    [self _layout];
}


@end
