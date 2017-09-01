//
//  ImprintViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ImprintViewController.h"
#import "LTracker.h"



#define TOP_HTML_FILE           @"imprint1.html"
#define BOTTOM_HTML_FILE        @"imprint2.html"

#define POPUP_TEMPLATE_FILE     @"template_imprint.html"
#define POPUP_TEMPLATE_STRING   @"<!-- CONTENT -->"



@implementation ImprintViewController


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}


#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Einstellungen - Impressum");
    GATrackingSetTrackScreenViews(YES);

    
    
    self.navigationItem.title = @"Impressum";
    
    [self _createWebViews];
}


- (void) updateViewConstraints {
    
    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_topWebView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_topWebView)]];

    [self.topContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_topWebView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_topWebView)]];

    
    [self.bottomContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bottomWebView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_bottomWebView)]];
    
    [self.bottomContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bottomWebView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_bottomWebView)]];

    [super updateViewConstraints];
}



#pragma mark - WebViews

- (void) _createWebViews {

    // top web view
    {
        _topWebView = [[UIWebView alloc] init];
        _topWebView.backgroundColor = [UIColor clearColor];
        _topWebView.opaque = NO;
        _topWebView.translatesAutoresizingMaskIntoConstraints = NO;
        _topWebView.delegate = self;
        _topWebView.scrollView.scrollEnabled = NO;
        [self.topContainer addSubview:_topWebView];
        
        NSString* fullFilePath = [[NSBundle mainBundle] pathForResource:TOP_HTML_FILE ofType:nil];
        
        NSError* error = nil;
        NSString* string = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            
            NSLog(@"error: %@", error);
        }
        
        NSString* HTMLString = [self _createHTMLStringWithString:string];
        
        NSLog(@"HTMLString: %@", HTMLString);
        
        [_topWebView loadHTMLString:HTMLString baseURL:nil];
    }
    
    
    // bottom web view
    {
        _bottomWebView = [[UIWebView alloc] init];
        _bottomWebView.backgroundColor = [UIColor clearColor];
        _bottomWebView.opaque = NO;
        _bottomWebView.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomWebView.delegate = self;
        _bottomWebView.scrollView.scrollEnabled = NO;
        [self.bottomContainer addSubview:_bottomWebView];
        
        NSString* fullFilePath = [[NSBundle mainBundle] pathForResource:BOTTOM_HTML_FILE ofType:nil];
        
        NSError* error = nil;
        NSString* string = [NSString stringWithContentsOfFile:fullFilePath encoding:NSASCIIStringEncoding error:&error];
        
        if (error) {
            
            NSLog(@"error: %@", error);
        }
        
        NSString* HTMLString = [self _createHTMLStringWithString:string];
        
        NSLog(@"HTMLString: %@", HTMLString);
        
        [_bottomWebView loadHTMLString:HTMLString baseURL:nil];
    }
}


- (NSString*) _createHTMLStringWithString:(NSString*) string {
    
    NSString* templatePath = [[NSBundle mainBundle] pathForResource:POPUP_TEMPLATE_FILE ofType:nil];
    NSString* templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:POPUP_TEMPLATE_STRING withString:string];
    
    return templateString;
}




#pragma mark - UIWebViewDelegate

- (void) webViewDidFinishLoad:(UIWebView *)webView {

    webView.frame = ({
    
        CGRect newRect = webView.frame;
        newRect.size.height = 1;
        
        newRect;
    });

    webView.frame = ({
        
        CGRect newRect = webView.frame;
        newRect.size = [webView sizeThatFits:CGSizeZero];
        
        newRect;
    });


    [webView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[webView(height)]"
                                                                    options:0
                                                                    metrics:@{
                                                                              @"height" : @(webView.frame.size.height)
                                                                              }
                                                                      views:NSDictionaryOfVariableBindings(webView)]];

    [webView setNeedsLayout];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [webView layoutIfNeeded];
    }];
    

    
//    CGSize size = [webView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];


    [self.view setNeedsLayout];
}


- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[UIApplication sharedApplication] openURL:[request URL]];
        
        return NO;
    }
    else return YES;
}



#pragma mark - Dealloc

- (void) dealloc {
    
}

@end
