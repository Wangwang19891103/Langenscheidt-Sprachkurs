//
//  VocabFlowGrammarPageViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "VocabFlowGrammarPageViewController.h"
#import "UILabel+HTML.h"


@implementation VocabFlowGrammarPageViewController

@synthesize labelLang1;
@synthesize labelLang2;
@synthesize dict;
//@synthesize aaa;
//@synthesize a;
//@synthesize pageIndex;


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.labelLang1.text = self.dict[@"field1"];
    self.labelLang2.text = self.dict[@"field2"];
//    self.aaa.text = [NSString stringWithFormat:@"%d", self.a];
    
    [self.labelLang1 parseHTML];
    [self.labelLang2 parseHTML];
}

@end
