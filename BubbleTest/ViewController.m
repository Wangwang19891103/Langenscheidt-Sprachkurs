//
//  ViewController.m
//  BubbleTest
//
//  Created by Stefan Ueter on 04.03.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ViewController.h"
#import "DialogBubble.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    DialogBubble* bubble = [[DialogBubble alloc] init];
    bubble.textLang1 = @"[I'm from] Stuttgart - in the south of Germany.";
    bubble.textLang2 = @"Ich bin aus Stuttgart - im Süden von Deutschland.";
    bubble.color = 0;
    bubble.side = 0;
    bubble.speaker = @"Paula";
    
    [self.view addSubview:bubble];
    
    [bubble createView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bubble]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(bubble)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(100)-[bubble]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(bubble)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
