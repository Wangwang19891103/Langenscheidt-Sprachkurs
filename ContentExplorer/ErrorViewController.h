//
//  ErrorViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ErrorViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *label;



- (void) setErrorDescription:(NSString*) description;

@end
