//
//  InviteFriendsHandler.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "InviteFriendsHandler.h"
#import "ReachabilityManager.h"
#import "ErrorMessageManager.h"



NSString* const kInviteFriendsHandlerErrorDomain = @"InviteFriendsHandlerErrorDomain";

NSInteger const kInviteFriendsHandlerErrorNoInternet = 601;
NSInteger const kInviteFriendsHandlerErrorCantSendMail = 602;
NSInteger const kInviteFriendsHandlerErrorFailedToSend = 603;




@implementation InviteFriendsHandler


- (void) openWithParentViewController:(UIViewController *)parentController {

    _parentController = parentController;
    
    
    NSLog(@"contact support");
    
    BOOL hasInternet = [[ReachabilityManager instance] canConnectToInternet];
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    
    if (!hasInternet) {
        
        [self _handleNoInternet];
        return;
    }
    else if (!canSendMail) {
        
        [self _handleCantSendMail];
        return;
    }
    
    
    NSString* subject = [self _subjectText];
    NSString* bodyString = [self _bodyText];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:subject];
    [controller setMessageBody:bodyString isHTML:NO];
    
    [parentController presentViewController:controller animated:YES completion:^{
        
    }];
}


- (NSString*) _subjectText {
    
    NSString* string = [NSString stringWithFormat:@"L Sprachkurs von Langenscheidt"];
    
    return string;
}


- (NSString*) _bodyText {
    
    NSString* string =  @"Hallo,\n"
                        "ich lerne Englisch mit der L Sprachkurs App von Langenscheidt. Das könnte dir auch gefallen.\n"
                        "http://onelink.to/l-sprachkurs-app";
    
    return string;
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
            
        case MFMailComposeResultFailed: {
            
            [self _handleFailedToSend];
        }
            break;
            
        case MFMailComposeResultSent: {
            
            [self _handleSentSuccessfully];
        }
            break;
            
        default:
            break;
    }
    
    [_parentController dismissViewControllerAnimated:YES completion:^{
        
    }];
}




#pragma mark - Error / Message Handling

- (void) _handleSentSuccessfully {
    
    NSString* title = @"Einladung versandt";
    NSString* message = @"Deine Einladung wurde erfolgreich abgeschickt.";
    
    [[ErrorMessageManager instance] showErrorPopupWithTitle:title message:message parentViewController:_parentController completionBlock:^{
        
        
    }];
}


- (void) _handleNoInternet {
    
    NSError* error = [self _errorWithCode:kInviteFriendsHandlerErrorNoInternet];
    
    [self _reportError:error];
}


- (void) _handleCantSendMail {
    
    NSError* error = [self _errorWithCode:kInviteFriendsHandlerErrorCantSendMail];
    
    [self _reportError:error];
}


- (void) _handleFailedToSend {
    
    NSError* error = [self _errorWithCode:kInviteFriendsHandlerErrorFailedToSend];
    
    [self _reportError:error];
}


- (NSError*) _errorWithCode:(NSInteger) errorCode {
    
    NSError* error = [NSError errorWithDomain:kInviteFriendsHandlerErrorDomain code:errorCode userInfo:nil];
    
    return error;
}


- (void) _reportError:(NSError*) error {
    
    [[ErrorMessageManager instance] handleError:error withParentViewController:_parentController completionBlock:^{
        
        
    }];
}



@end
