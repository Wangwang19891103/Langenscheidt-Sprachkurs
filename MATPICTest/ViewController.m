//
//  ViewController.m
//  MATPICTest
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize label;
@synthesize matpicView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    matpicView.vocabularySets = @[
                                  @{
                                      @"textLang1" : @"Fine, thanks.",
                                      @"textLang2" : @"Danke, gut.",
                                      @"image" : @"MATPIC_DUMMY_01"
                                      },
                                  @{
                                      @"textLang1" : @"Good morning.",
                                      @"textLang2" : @"Good morning.",
                                      @"image" : @"MATPIC_DUMMY_02"
                                      },
                                  @{
                                      @"textLang1" : @"How are you?",
                                      @"textLang2" : @"Wie geht's dir/Ihnen?",
                                      @"image" : @"MATPIC_DUMMY_03"
                                      },
                                  @{
                                      @"textLang1" : @"Where are you from?",
                                      @"textLang2" : @"Woher kommst du/kommen Sie?",
                                      @"image" : @"MATPIC_DUMMY_04"
                                      }
                                  ];
                                  
  
    [matpicView createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) matpicView:(MATPICView *)matpicView didStartNewRoundWithVocabularySet:(NSDictionary *)vocabularySet {
    
    self.restartButton.hidden = YES;
    
    NSString* textLang1 = vocabularySet[@"textLang1"];
    
    self.label.text = textLang1;
}


- (void) matpicViewDidFinishLastRound:(MATPICView *)matpicView {

    self.restartButton.hidden = NO;
}


- (IBAction) handleRestart {
    
    [self.matpicView createView];
    
}

@end
