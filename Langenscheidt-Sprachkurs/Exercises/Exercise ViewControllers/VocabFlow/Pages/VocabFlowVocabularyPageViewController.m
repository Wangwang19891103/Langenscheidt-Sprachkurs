//
//  VocabFlowGrammarPageViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "VocabFlowVocabularyPageViewController.h"
#import "UILabel+HTML.h"
#import "ContentDataManager.h"
#import "VocabularyFormatter.h"
#import "ContentManager.h"


@implementation VocabFlowVocabularyPageViewController

@synthesize labelLang1;
@synthesize labelLang2;
@synthesize dict;
//@synthesize a;


- (void) viewDidLoad {
    
    [super viewDidLoad];

    NSString* idString = self.dict[@"field1"];
    NSInteger vocabularyID = [idString integerValue];
    self.vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
    
//    self.labelLang1.text = [NSString stringWithFormat:@"%@%@", self.vocabulary.prefixLang1 ? [NSString stringWithFormat:@"%@ ", self.vocabulary.prefixLang1] : @"", self.vocabulary.textLang1];
//    self.labelLang2.text = [NSString stringWithFormat:@"%@%@", self.vocabulary.prefixLang2 ? [NSString stringWithFormat:@"%@ ", self.vocabulary.prefixLang2] : @"", self.vocabulary.textLang2];

    self.labelLang1.text = [VocabularyFormatter formattedStringForLanguage:Lang1 withVocabulary:self.vocabulary];
    self.labelLang2.text = [VocabularyFormatter formattedStringForLanguage:Lang2 withVocabulary:self.vocabulary];
    
    [self.labelLang1 parseHTML];
    [self.labelLang2 parseHTML];
    
    NSString* photoFile = self.vocabulary.imageFile;
//    photoFile = [photoFile stringByDeletingPathExtension];
//    photoFile = [[photoFile stringByAppendingString:@"_large"] stringByAppendingPathExtension:@"jpg"];

//    NSString* photosFolder = [[NSBundle mainBundle] pathForResource:@"Photos/large" ofType:nil];
//    NSString* fullPath = [photosFolder stringByAppendingPathComponent:photoFile];
//    UIImage* image = [UIImage imageWithContentsOfFile:fullPath];
    
//    Course* course = [[ContentDataManager instance] courseForVocabulary:_vocabulary];
    Lesson* lesson = [[ContentDataManager instance] lessonForVocabulary:_vocabulary];
    UIImage* image = [[ContentManager instance] largeVocabularyImageNamed:photoFile forLesson:lesson];
    
    self.imageView.image = image;
    
    if (!image) {
        
        self.debugLabel.text = photoFile;
        self.debugLabel.hidden = NO;
    }
}


- (IBAction) actionAudio {
    
    NSLog(@"audio");
    
    NSString* audioFile = self.vocabulary.audioFile;

//    audioFile = [audioFile stringByAppendingPathExtension:@"mp3"];
//    NSString* audioFolder = [[NSBundle mainBundle] pathForResource:@"Vocabularies" ofType:nil];
//    NSString* fullPath = [audioFolder stringByAppendingPathComponent:audioFile];

//    Course* course = [[ContentDataManager instance] courseForVocabulary:_vocabulary];
    Lesson* lesson = [[ContentDataManager instance] lessonForVocabulary:_vocabulary];
    NSString* fullPath = [[ContentManager instance] vocabularyAudioPathForFileName:audioFile forLesson:lesson];
    
    [self _playAudioWithPath:fullPath];
}


- (void) _playAudioWithPath:(NSString*) path {
    
    NSURL* fileURL = [NSURL fileURLWithPath:path];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    _player.delegate = self;
    [_player play];
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    _player = nil;
}

@end
