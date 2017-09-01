//
//  CourseCompletionViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface CourseCompletionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (copy, nonatomic) NSString* title;

@property (nonatomic, strong) void(^nextBlock)();


- (void) fadeOut;


- (IBAction)actionButton:(id)sender;

@end
