//
//  VocabularyPageViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "VocabularyPageViewController.h"

@implementation VocabularyPageViewController

@synthesize index;
@synthesize label1;
@synthesize label2;
@synthesize vocabulary;


- (void) setVocabulary:(Vocabulary *)p_vocabulary {
    
    vocabulary = p_vocabulary;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

    NSString* string1 = [NSString stringWithFormat:@"%@%@",
                         vocabulary.prefixLang1 ? [NSString stringWithFormat:@" %@", vocabulary.prefixLang1] : @"",
                         vocabulary.textLang1];
    NSString* string2 = [NSString stringWithFormat:@"%@%@",
                         vocabulary.prefixLang2 ? [NSString stringWithFormat:@" %@", vocabulary.prefixLang2] : @"",
                         vocabulary.textLang2];
    
    self.label1.text = string1;
    self.label2.text = string2;

}


- (void) dealloc {

    NSLog(@"page dealloc");
}

@end
