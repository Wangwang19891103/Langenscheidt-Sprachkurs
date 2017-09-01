//
//  ViewController.m
//  SnakeTest
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize snakeView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    snakeView.string = @"usually";
    [snakeView createView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
