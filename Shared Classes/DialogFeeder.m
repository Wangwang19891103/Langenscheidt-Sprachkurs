//
//  DialogFeeder.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "DialogFeeder.h"


#define DialogFeeder_DEBUG      NO

#define ARTIFICIAL_DELAY        3.0



//#define DIALOG_DEBUG



@implementation DialogFeeder

- (id) initWithDialogLines:(NSArray*) dialogs withLesson:(Lesson*) lesson {
    
    self = [super init];
    
    _dialogs = dialogs;
    _player = [[DialogAudioPlayer alloc] initWithDialogLines:_dialogs withLesson:lesson];
    _player.fadeInDuration = 0.3;
    _player.fadeOutDuration = 0.3;
    _player.delegate = self;
    _currentDialogIndex = 0;
    _playerAssetsLoaded = NO;
    
    return self;
}


- (void) scheduleNextBatchWhenReady {

    
    BOOL selfReady = [self _readyForNextBatch];
    BOOL delegateReady = YES;
    
#ifdef DIALOG_DEBUG
    
    selfReady = YES;
    
#endif
    
    if ([self.delegate respondsToSelector:@selector(dialogFeederReadyForNextBatch:)]) {
        
        delegateReady = [self.delegate dialogFeederReadyForNextBatch:self];
    }

    if (DialogFeeder_DEBUG) NSLog(@"scheduleNextBatchWhenReady (self = %d, delegate = %d)", selfReady, delegateReady);

    if (selfReady && delegateReady) {
        
        if ([self hasNextBatch]) {
        
            [self _processNextBatch];
        }
//        else {
//            
//            [self _reportDidFinishAllBatches];
//        }
    }
}


- (BOOL) hasNextBatch {
    
    BOOL hasNext = _currentDialogIndex < _dialogs.count;
    
    if (DialogFeeder_DEBUG) NSLog(@"hasNextbatch (%d)", hasNext);
    
    return hasNext;
}




#pragma mark - Stop

- (void) stop {

    [_player stop];
    _player.delegate = nil;
    _player = nil;
}



#pragma mark - Private

- (void) _processNextBatch {

    if (DialogFeeder_DEBUG) NSLog(@"processNextBatch");

#ifdef DIALOG_DEBUG
    
//    [self audioPlayerWillBeginPlayingPart:nil];
//    
//    [self audioPlayerDidEndPlayingPart:nil];
//    
//    [self scheduleNextBatchWhenReady];
    
#else
    
    if ([self _nextDialogHasAudio]) {
        
        [_player playNextBatch];
    }
    else {
        
        [self _playArtificialDelay];
    }
    
#endif
}


- (void) _reportNextPartWillBegin {
    
    if (DialogFeeder_DEBUG) NSLog(@"reportNextPartWillBegin (_currentDialogIndex = %ld)", _currentDialogIndex);

    if ([self.delegate respondsToSelector:@selector(dialogFeeder:willPlayNextPartWithIndex:)]) {
        
        [self.delegate dialogFeeder:self willPlayNextPartWithIndex:_currentDialogIndex];
    }
}


- (void) _reportPartDidEndPlaying {
    
    if (DialogFeeder_DEBUG) NSLog(@"reportDidEndPlayingPart (_currentDialogIndex = %ld)", _currentDialogIndex);
    
    if ([self.delegate respondsToSelector:@selector(dialogFeeder:didEndPlayingPartWithIndex:)]) {
        
        [self.delegate dialogFeeder:self didEndPlayingPartWithIndex:_currentDialogIndex];
    }
}


- (void) _reportBatchDidEndPlaying {

    if ([self.delegate respondsToSelector:@selector(dialogFeederDidEndPlayingBatch:)]) {
        
        [self.delegate dialogFeederDidEndPlayingBatch:self];
    }
}


- (void) _reportDidFinishAllBatches {
    
    if ([self.delegate respondsToSelector:@selector(dialogFeederFinishedAllBatches:)]) {
        
        [self.delegate dialogFeederFinishedAllBatches:self];
    }
}


- (void) _reportWillPlayArtificialDelay {
    
    if ([self.delegate respondsToSelector:@selector(dialogFeeder:willPlayArtificialDelayWithIndex:)]) {
        
        [self.delegate dialogFeeder:self willPlayArtificialDelayWithIndex:_currentDialogIndex];
    }
}


- (void) _reportDidEndPlayingArtificialDelayWithIndex:(NSNumber*) index {
    

    
    if ([self.delegate respondsToSelector:@selector(dialogFeeder:didEndPlayingArtificialDelayWithIndex:)]) {
        
        [self.delegate dialogFeeder:self didEndPlayingArtificialDelayWithIndex:[index integerValue]];
    }
}


- (BOOL) _readyForNextBatch {
    
    BOOL ready = _playerAssetsLoaded && !_player.isPlaying;
    
    return ready;
}




#pragma mark - Artificial Delay (narrator bubbles without audio)

- (BOOL) _nextDialogHasAudio {
    
    NSDictionary* nextDialog = _dialogs[_currentDialogIndex];
    NSString* audioRange = nextDialog[@"audioRange"];
    
    return audioRange.length > 0;
}


- (void) _playArtificialDelay {
    

    
    [_player skipCurrentIndex];
    
    [self _reportWillPlayArtificialDelay];
    
    [self performSelector:@selector(_reportDidEndPlayingArtificialDelayWithIndex:) withObject:@(_currentDialogIndex) afterDelay:ARTIFICIAL_DELAY];
    
    ++_currentDialogIndex;

}



#pragma mark - Delegate

- (void) audioPlayerDidFinishLoadingAsset:(AudioPlayer *)player {
    
    _playerAssetsLoaded = YES;
    
    [self scheduleNextBatchWhenReady];
}


- (void) audioPlayerWillBeginPlayingPart:(AudioPlayer *)player {

    if (DialogFeeder_DEBUG) NSLog(@"audioPlayerWillBeginPlayingPart (_currentDialogIndex = %ld)", _currentDialogIndex);

    [self _reportNextPartWillBegin];
}


- (void) audioPlayerDidEndPlayingPart:(AudioPlayer *)player {
    
    if (DialogFeeder_DEBUG) NSLog(@"audioPlayerDidEndPlayingPart (_currentDialogIndex = %ld)", _currentDialogIndex);

    [self _reportPartDidEndPlaying];
    
    ++_currentDialogIndex;
}


- (void) audioPlayerDidEndPlayingBatch:(AudioPlayer *)player {
    
    [self _reportBatchDidEndPlaying];
    
    if (![_player hasNextBatch]) {
        
        [self _reportDidFinishAllBatches];
    }
}


- (void) audioPlayerDidEndPlaying:(AudioPlayer *)player {
    
    if (DialogFeeder_DEBUG) NSLog(@"audioPlayerDidEndPlaying");
    
//    [self scheduleNextBatchWhenReady];
}




#pragma mark - Dealloc 

- (void) dealloc {
    
    NSLog(@"DialogFeeder - dealloc");
}



@end
