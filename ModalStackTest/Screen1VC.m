//
//  Screen1VC.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.07.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Screen1VC.h"
#import "ModalStackViewController.h"
#import "Screen2VC.h"

@implementation Screen1VC


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
    
    Screen2VC* screen2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen2"];
    
    [[ModalStackViewController instanceWithName:@"a"] addViewController:screen2 withConfiguration:@{}];
}

@end
