//
//  DialogAudioPlayer.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 01.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioPlayer.h"
#import "Lesson.h"


@interface DialogAudioPlayer : AudioPlayer {
    
    NSArray* _dialogLines;
    NSInteger _currentIndex;
    NSDictionary* _exerciseDict;
}



- (id) initWithDialogLines:(NSArray*) dialogLines withLesson:(Lesson*) lesson;

- (id) initWithExerciseDict:(NSDictionary*) exerciseDict;

- (void) playNextBatch;

- (BOOL) hasNextBatch;

- (void) playExerciseAudio;

- (void) skipCurrentIndex;

@end
