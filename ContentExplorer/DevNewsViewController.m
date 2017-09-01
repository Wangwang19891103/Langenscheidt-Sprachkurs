//
//  DevNewsViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "DevNewsViewController.h"
@import WebKit;


#define FILE        @"devnews.html"


@implementation DevNewsViewController

@synthesize webview;


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self createView];
}

- (void) createView {

    NSString* filePath = [[NSBundle mainBundle] pathForResource:FILE ofType:nil];
    NSString* HTMLString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    webview = [[WKWebView alloc] init];
    webview.navigationDelegate = self;
    [webview loadHTMLString:HTMLString baseURL:nil];
    webview.backgroundColor = [UIColor redColor];
    webview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:webview];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webview]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(webview)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[webview]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(webview)]];
}


- (void) viewDidLayoutSubviews {
    
    
}


//- (void) webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];
//}

@end
