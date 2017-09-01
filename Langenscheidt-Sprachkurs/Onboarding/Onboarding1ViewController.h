//
//  Onboarding1ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Onboarding1ViewController : UIViewController


@property (nonatomic, strong) void(^nextBlock)();


- (IBAction) actionNext:(id)sender;

@end
