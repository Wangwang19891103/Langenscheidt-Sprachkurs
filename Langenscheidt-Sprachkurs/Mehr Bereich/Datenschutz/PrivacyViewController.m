//
//  PrivacyViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "PrivacyViewController.h"
#import "LTracker.h"


#define HTML_FILE           @"privacy.html"
#define TEMPLATE_FILE       @"template_privacy.html"
#define POPUP_TEMPLATE_STRING   @"<!-- CONTENT -->"


@implementation PrivacyViewController


#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Einstellungen - Datenschutz");
    GATrackingSetTrackScreenViews(YES);

    
    
    self.navigationItem.title = @"Datenschutz";
    
    [self _loadWebView];
}



#pragma mark - WebView

- (void) _loadWebView {
    
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.delegate = self;
    
    NSString* fullFilePath = [[NSBundle mainBundle] pathForResource:HTML_FILE ofType:nil];
    
    NSError* error = nil;
    NSString* string = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        
        NSLog(@"error: %@", error);
    }
    
    NSString* HTMLString = [self _createHTMLStringWithString:string];
    
    NSLog(@"HTMLString: %@", HTMLString);
    
    [_webView loadHTMLString:HTMLString baseURL:nil];

}


- (NSString*) _createHTMLStringWithString:(NSString*) string {
    
    NSString* templatePath = [[NSBundle mainBundle] pathForResource:TEMPLATE_FILE ofType:nil];
    NSString* templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    templateString = [templateString stringByReplacingOccurrencesOfString:POPUP_TEMPLATE_STRING withString:string];
    
    return templateString;
}




#pragma mark - UIWebViewDelegate

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
}


- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[UIApplication sharedApplication] openURL:[request URL]];
        
        return NO;
    }
    else return YES;
}


@end
