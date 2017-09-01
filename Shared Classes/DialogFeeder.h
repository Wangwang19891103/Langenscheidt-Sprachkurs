//
//  DialogFeeder.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogAudioPlayer.h"
#import "Lesson.h"


@protocol DialogFeederDelegate;

@interface DialogFeeder : NSObject <AudioPlayerDelegate> {
    
    NSArray* _dialogs;
    
    DialogAudioPlayer* _player;
    
    NSInteger _currentDialogIndex;
    
    BOOL _playerAssetsLoaded;
    
}

@property (nonatomic, assign) id<DialogFeederDelegate> delegate;



- (id) initWithDialogLines:(NSArray*) dialogs withLesson:(Lesson*) lesson;

- (void) scheduleNextBatchWhenReady;

- (BOOL) hasNextBatch;

- (void) stop;

@end


@protocol DialogFeederDelegate <NSObject>

- (BOOL) dialogFeederReadyForNextBatch:(DialogFeeder*) feeder;

- (void) dialogFeeder:(DialogFeeder*) feeder willPlayNextPartWithIndex:(NSInteger) index;

- (void) dialogFeeder:(DialogFeeder*) feeder didEndPlayingPartWithIndex:(NSInteger) index;

- (void) dialogFeederDidEndPlayingBatch:(DialogFeeder*) feeder;

- (void) dialogFeederFinishedAllBatches:(DialogFeeder*) feeder;

- (void) dialogFeeder:(DialogFeeder*) feeder willPlayArtificialDelayWithIndex:(NSInteger) index;

- (void) dialogFeeder:(DialogFeeder*) feeder didEndPlayingArtificialDelayWithIndex:(NSInteger) index;

@end