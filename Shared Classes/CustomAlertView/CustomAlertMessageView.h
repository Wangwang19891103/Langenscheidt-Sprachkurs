//
//  CustomAlertMessageView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 31.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface CustomAlertMessageView : UIView {
    
}

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* messageLabel;

@property (nonatomic, copy) void(^okayBlock)();


- (id) initWithTitle:(NSString*) title message:(NSString*) message;

- (id) initWithTitle:(NSString*) title message:(NSString*) message okButton:(BOOL) displayOKButton;


- (IBAction)actionOkay:(id)sender;


@end
