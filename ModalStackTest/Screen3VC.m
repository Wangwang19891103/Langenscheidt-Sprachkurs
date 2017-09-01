//
//  Screen1VC.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.07.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Screen3VC.h"
#import "ModalStackViewController.h"


@implementation Screen3VC


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


@end
