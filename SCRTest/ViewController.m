//
//  ViewController.m
//  SCRTest
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize dropView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    dropView.string = @"check-in-desk";
    
    [dropView createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
//    NSArray* asd = [dropView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
    
}

@end
