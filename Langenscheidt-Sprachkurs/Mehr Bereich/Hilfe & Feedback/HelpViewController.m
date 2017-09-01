//
//  HelpViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpCell.h"
#import "ReachabilityManager.h"
#import "ErrorMessageManager.h"
#import "DeviceUtil.h"
#import "LTracker.h"


NSString* const kHelpViewControllerErrorDomain = @"HelpViewControllerErrorDomain";

NSInteger const kHelpViewControllerErrorNoInternet = 501;
NSInteger const kHelpViewControllerErrorCantSendMail = 502;
NSInteger const kHelpViewControllerErrorFailedToSend = 503;





@implementation HelpViewController



#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Hilfe & Feedback");
    GATrackingSetTrackScreenViews(YES);
    
    
    self.navigationItem.title = @"Hilfe & Feedback";
    
    self.tableView.alwaysBounceVertical = NO;
}



#pragma mark - UITableViewDelegate/dataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 165;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak HelpViewController* weakself = self;
    
    
    if (indexPath.row == 0) {
        
        HelpCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SupportCell"];
        cell.buttonBlock = ^() {
          
            [weakself _contactSupport];
        };
        
        return cell;
    }
    else {
        
        HelpCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"RateCell"];
        cell.buttonBlock = ^() {
          
            [weakself _rateApp];
        };
        
        return cell;
    }
}




#pragma mark - Contact Support

- (void) _contactSupport {
    
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
    
    NSString* recipient = @"LSprachkurs-app@langenscheidt.de";
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:@[recipient]];
    [controller setSubject:subject];
    [controller setMessageBody:bodyString isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}


- (NSString*) _subjectText {
    
    NSString* versionString = [self _appVersion];
    NSString* string = [NSString stringWithFormat:@"L Sprachkurs App - Version %@", versionString];
    
    return string;
}


- (NSString*) _appVersion {
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* bundleVersion = infoDict[@"CFBundleShortVersionString"];
    
    return bundleVersion;
}


- (NSString*) _bodyText {
    
    NSMutableString* string = [NSMutableString string];
    
    NSString* deviceName = [DeviceUtil hardwareDescription];
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    
    [string appendFormat:@"Gerätetyp: %@\n", deviceName];
    [string appendFormat:@"iOS-Version: %@\n", systemVersion];
    
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}





#pragma mark - Rate App

- (void) _rateApp {
    
    NSLog(@"rate app");
    
    NSURL* iTunesURL = [NSURL URLWithString:@"itms://itunes.apple.com/app/id1115211558"];
    NSURL* webURL = [NSURL URLWithString:@"http://itunes.apple.com/app/id1115211558"];
    
    [[UIApplication sharedApplication] openURL:iTunesURL];
}




#pragma mark - Error / Message Handling

- (void) _handleSentSuccessfully {

    NSString* title = @"Support-Anfrage erfolgreich";
    NSString* message = @"Deine Support-Anfrage wurde erfolgreich abgeschickt. Wir kümmern uns sofort darum. ";
    
    [[ErrorMessageManager instance] showErrorPopupWithTitle:title message:message parentViewController:self completionBlock:^{
        
        
    }];
}


- (void) _handleNoInternet {
    
    NSError* error = [self _errorWithCode:kHelpViewControllerErrorNoInternet];
    
    [self _reportError:error];
}


- (void) _handleCantSendMail {
    
    NSError* error = [self _errorWithCode:kHelpViewControllerErrorCantSendMail];
    
    [self _reportError:error];
}


- (void) _handleFailedToSend {
    
    NSError* error = [self _errorWithCode:kHelpViewControllerErrorFailedToSend];
    
    [self _reportError:error];
}


- (NSError*) _errorWithCode:(NSInteger) errorCode {
    
    NSError* error = [NSError errorWithDomain:kHelpViewControllerErrorDomain code:errorCode userInfo:nil];
    
    return error;
}


- (void) _reportError:(NSError*) error {
    
    [[ErrorMessageManager instance] handleError:error withParentViewController:self completionBlock:^{
        
        
    }];
}






@end
