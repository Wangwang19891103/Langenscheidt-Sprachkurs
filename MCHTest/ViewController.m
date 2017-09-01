//
//  ViewController.m
//  MCHTest
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mchView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    

    mchView.answers = @[
                        @"[in London yesterday morning, in London yesterday morning]",
                        @"morning yesterday in London",
                        @"London yesterday in morning"
                        ];
    
    [mchView createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
