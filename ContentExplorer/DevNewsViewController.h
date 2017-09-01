//
//  DevNewsViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import WebKit;

@interface DevNewsViewController : UIViewController <WKNavigationDelegate>


@property (strong, nonatomic) IBOutlet WKWebView *webview;

@end
