//
//  LogViewController.m
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 03.07.14.
//  Copyright (c) 2014 mobilinga. All rights reserved.
//

#import "LogViewController.h"


#define FONT                        [UIFont fontWithName:@"CourierNewPSMT" size:10]
#define DEFAULT_COLOR               [UIColor blackColor]
#define CONTENT_MARGIN_LEFT         30
#define CONTENT_MARGIN_RIGHT        10
#define SEPARATOR_COLOR             [UIColor lightGrayColor]
#define TOP_BUTTON_SIZE             CGSizeMake(20,20)


@implementation LogViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];

    _posY = 0;
    _entryCount = 1;
    
    
    // scroll view
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
    [self.view addSubview:_scrollView];
    
    
    // content view
    
    _contentView = [[UIView alloc] initWithFrame:_scrollView.bounds];
    [_scrollView addSubview:_contentView];
    [_scrollView setContentSize:_contentView.frame.size];
    
    
    // scroll to top button
    
    UIButton* topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    topButton.backgroundColor = [UIColor blueColor];
    topButton.frame = CGRectMake(self.view.frame.size.width - TOP_BUTTON_SIZE.width, self.view.frame.size.height - TOP_BUTTON_SIZE.height, TOP_BUTTON_SIZE.width, TOP_BUTTON_SIZE.height);
    [topButton addTarget:self action:@selector(scrollToTop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topButton];
}


- (void) addEntry:(NSString *)string withColor:(UIColor *)color {

    if (!color) color = DEFAULT_COLOR;
    

    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : FONT,
                                 NSForegroundColorAttributeName : color,
                                 NSParagraphStyleAttributeName : paragraph
                                 };

    // number label
    
    {
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%3.d", _entryCount] attributes:attributes];
    
        CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, _posY, textRect.size.width, textRect.size.height)];
        label.attributedText = attributedString;
        [_contentView addSubview:label];
        
    }
    
    
    
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    float contentWidth = _contentView.frame.size.width - CONTENT_MARGIN_LEFT - CONTENT_MARGIN_RIGHT;
    
    CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_MARGIN_LEFT, _posY, contentWidth, textRect.size.height)];
    label.numberOfLines = 0;
    label.attributedText = attributedString;
    [_contentView addSubview:label];
    
    _posY += label.frame.size.height;
    
    
    // add separator
    
    UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, _posY, _contentView.frame.size.width, 1)];
    separatorView.backgroundColor = SEPARATOR_COLOR;
    [_contentView addSubview:separatorView];
    
    _posY += separatorView.frame.size.height;
    
    
    // adjust content view
    
    CGRect newContentViewFrame = _contentView.frame;
    newContentViewFrame.size.height = _posY;
    _contentView.frame = newContentViewFrame;
    [_scrollView setContentSize:_contentView.frame.size];

    
    // scroll to bottom
    
    float offset = MAX(0, _contentView.frame.size.height - _scrollView.frame.size.height);
    [_scrollView setContentOffset:CGPointMake(0, offset) animated:true];
    
    
    // forcing run loop
    
//    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    
    
    ++_entryCount;
}


- (void) scrollToTop {
    
    [_scrollView setContentOffset:CGPointZero animated:true];
}

@end
