//
//  Screen1VC.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.07.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Screen2VC.h"
#import "ModalStackViewController.h"
#import "Screen3VC.h"


@implementation Screen2VC


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


- (IBAction) closeStack {
    
    [[ModalStackViewController instanceWithName:@"a"] dismissStackWithCompletionBlock:^{
        
        
    }];
}


- (IBAction) next {
    
    Screen3VC* screen3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen3"];
    
    [[ModalStackViewController instanceWithName:@"a"] addViewController:screen3 withConfiguration:@{}];
}

@end
