//
//  InviteFriendsHandler.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import MessageUI;


extern NSString* const kInviteFriendsHandlerErrorDomain;

extern NSInteger const kInviteFriendsHandlerErrorNoInternet;
extern NSInteger const kInviteFriendsHandlerErrorCantSendMail;
extern NSInteger const kInviteFriendsHandlerErrorFailedToSend;



@interface InviteFriendsHandler : NSObject <MFMailComposeViewControllerDelegate> {
    
    UIViewController* _parentController;
}

- (void) openWithParentViewController:(UIViewController*) parentController;

@end
