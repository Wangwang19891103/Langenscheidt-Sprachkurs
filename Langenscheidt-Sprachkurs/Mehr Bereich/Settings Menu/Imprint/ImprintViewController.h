//
//  ImprintViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ImprintViewController : UIViewController <UIWebViewDelegate> {
    
    UIWebView* _topWebView;
    UIWebView* _bottomWebView;
}

@property (strong, nonatomic) IBOutlet UIView *topContainer;

@property (strong, nonatomic) IBOutlet UIView *bottomContainer;

@end
