//
//  HelpViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import MessageUI;



extern NSString* const kHelpViewControllerErrorDomain;

extern NSInteger const kHelpViewControllerErrorNoInternet;
extern NSInteger const kHelpViewControllerErrorCantSendMail;
extern NSInteger const kHelpViewControllerErrorFailedToSend;




@interface HelpViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@end
