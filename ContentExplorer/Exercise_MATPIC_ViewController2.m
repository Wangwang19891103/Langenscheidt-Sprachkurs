//
//  Exercise_MATPIC_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "Exercise_MATPIC_ViewController.h"
#import "NSArray+Extensions.h"


#define INSTRUCTION_TEXT        @"Finde die richtige Übersetzung"



@implementation Exercise_MATPIC_ViewController

@synthesize pearl;
@synthesize textView;
@synthesize vocabularyLabel;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (id) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
}


#pragma mark - View

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self createView];
}


- (void) createView {
    
    self.textView.text = INSTRUCTION_TEXT;
    
    [self _createVocabularies];
}


- (void) _createVocabularies {
    
    _vocabularies = [NSArray randomizedArrayFromArray:self.pearl.vocabularies.allObjects];
}




@end
