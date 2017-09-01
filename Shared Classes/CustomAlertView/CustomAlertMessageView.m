//
//  CustomAlertMessageView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 31.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "CustomAlertMessageView.h"
#import "UILabel+HTML.h"


@implementation CustomAlertMessageView


#pragma mark - Init

- (id) initWithTitle:(NSString*) title message:(NSString*) message {

    return [self initWithTitle:title message:message okButton:YES];
}


- (id) initWithTitle:(NSString*) title message:(NSString*) message okButton:(BOOL) displayOKButton {
    
    NSInteger index = displayOKButton ? 0 : 1;
    
    self = [[UINib nibWithNibName:@"CustomAlertMessageView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil][index];
    
    _titleLabel.text = title;
    [_titleLabel parseHTML];
    
    _messageLabel.text = message;
    [_messageLabel parseHTML];
    
    return self;
}


- (IBAction)actionOkay:(id)sender {

    _okayBlock();
}


@end
