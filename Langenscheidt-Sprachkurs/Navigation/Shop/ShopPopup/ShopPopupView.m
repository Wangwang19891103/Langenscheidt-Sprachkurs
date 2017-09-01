

#import "ShopPopupView.h"
#import "RoundedRectImage.h"
#import "ContentManager.h"
#import "UIColor+ProjectColors.h"


#define BACKGROUND_COLOR     [UIColor whiteColor]
#define BORDER_COLOR         [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
#define BORDER_WIDTH        2.0
#define CORNER_RADIUS       5.0
#define INSETS      UIEdgeInsetsMake(CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS)




@implementation ShopPopupView

@synthesize closeBlock;



- (id) init {
    
    self = [super init];
    
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

//    _fadeView = [[FadeView alloc] init];
//    _fadeView.translatesAutoresizingMaskIntoConstraints = NO;
//    _fadeView.clipsToBounds = YES;
//    [self addSubview:_fadeView];
//
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage* buttonImage = [UIImage imageNamed:@"Navigation Bar Close Button"];
    [_closeButton setImage:buttonImage forState:UIControlStateNormal];
    _closeButton.contentMode = UIViewContentModeCenter;
    [_closeButton addTarget:self action:@selector(actionClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
    
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    _titleLabel.textColor = [UIColor projectBlueColor];
    _titleLabel.text = @"Freischalten";
    [self addSubview:_titleLabel];
    
    
//    UIImage* iconImage = [UIImage imageNamed:@"Popup"];
//    _iconImageView = [[UIImageView alloc] initWithImage:iconImage];
//    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:_iconImageView];
    
    _shopViewController = [[UIStoryboard storyboardWithName:@"ShopViewController" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    [self addSubview:_shopViewController.view];
    
    _shopViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
}


- (void) updateConstraints {

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[_closeButton(40)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_closeButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_closeButton(40)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_closeButton)]];

//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_iconImageView]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_iconImageView)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_iconImageView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_iconImageView)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_closeButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    
    UIView* shopView = _shopViewController.view;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[shopView]-(0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(shopView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[shopView]-10-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(shopView)]];

//    [self addConstraint:[NSLayoutConstraint constraintWithItem:_okButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    

    
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



- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR cornerRadius:CORNER_RADIUS borderWidth:0 borderColor:nil] resizableImageWithCapInsets:INSETS resizingMode:UIImageResizingModeStretch];
    
    [image drawInRect:rect];
}


- (void) actionClose {

    NSLog(@"close");
    
    self.closeBlock();
}



- (void) dealloc {
    
    NSLog(@"ShopPopupView - dealloc");
}



@end
