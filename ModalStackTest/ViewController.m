//
//  ViewController.m
//  ModalStackTest
//
//  Created by Stefan Ueter on 27.07.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ViewController.h"
#import "ModalStackViewController.h"
#import "Screen1VC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction) showPopup {
    
    Screen1VC* screen1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Screen1"];
    
    NSLog(@"presenting ModalStackVC (instant)...");
    
    [self presentViewController:[ModalStackViewController instanceWithName:@"a"] animated:NO completion:^{
        
        NSLog(@"presenting done.");
        
        [[ModalStackViewController instanceWithName:@"a"] addViewController:screen1 withConfiguration:@{}];
        
    }];
    
}




@end
