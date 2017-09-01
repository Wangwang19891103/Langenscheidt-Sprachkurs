//
//  ViewController.m
//  MatcherTest
//
//  Created by Stefan Ueter on 21.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ViewController.h"




@interface ViewController ()

@end

@implementation ViewController

@synthesize matcherView;




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    matcherView.pairs = @[
                          @[@"Einzeiliges Label" , @"einzeilig"],
                          @[@"Dies ist ein dreizeiliges, längeres Label.", @"dreizeilig"],
                          @[@"Dieses Label ist zweizeilig", @"zweizeilig"],
//                          @[@"vierzeilig", @"Dies ist ein vierzeiliges Label, diesmal sogar auf der anderen Seite"]
                          ];
    
    [matcherView createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
