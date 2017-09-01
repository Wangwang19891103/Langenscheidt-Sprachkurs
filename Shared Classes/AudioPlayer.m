//
//  AudioPlayer.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "AudioPlayer.h"


#define STUPID_APPLE_TOLERANCE      100   // in ms


@implementation AudioPlayer


@synthesize fadeInDuration;
@synthesize fadeOutDuration;
@synthesize isPlaying = _isPlaying;


- (id) initWithURL:(NSURL *)url times:(NSArray *)times {

    AVURLAsset* asset = [AVURLAsset.alloc initWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @YES}];
    _playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [_playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    self = [super initWithPlayerItem:_playerItem];

    _times = times;
    _currentPart = 0;
    _isPlaying = NO;
    
    return self;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {

    if ([object isKindOfClass:[AVPlayerItem class]]) {
        
        AVPlayerItem* item = (AVPlayerItem*)object;
        
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            
            if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishLoadingAsset:)]) {
                
                [self.delegate audioPlayerDidFinishLoadingAsset:self];
            }
        }
    }
}


- (void) handleTimeBreak {

    [self removeTimeObserver:_timeObserver];
    [self removeTimeObserver:_partObserver];
    [self removeTimeObserver:_startObserver];
    
    _isPlaying = NO;

    NSLog(@"Stopping.");
    
    [self pause];
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidEndPlaying:)]) {
        
        [self.delegate audioPlayerDidEndPlaying:self];
    }
}


- (void) handlePartDidEndPlaying {

//    NSLog(@"Did end playing part");
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidEndPlayingPart:)]) {
        
        [self.delegate audioPlayerDidEndPlayingPart:self];
    }
}


- (void) handlePartWillBeginPlaying {
    
    //    NSLog(@"Did end playing part");
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerWillBeginPlayingPart:)]) {
        
        [self.delegate audioPlayerWillBeginPlayingPart:self];
    }
}


- (void) handleBatchDidEndPlaying {
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidEndPlayingBatch:)]) {
        
        [self.delegate audioPlayerDidEndPlayingBatch:self];
    }
}



- (void) playNext {
    
    if ([self hasNext]) {
    
        if (_isPlaying) {
            
            NSLog(@"already playing. discarding play command.");
            
            return;
        }
        
        ++_currentPart;

        NSArray* times = [self timesForCurrentPart];
        __block CMTime startTime = [times[0] CMTimeValue];
        __block CMTime endTime = [times[1] CMTimeValue];
        
        NSLog(@"Playing part %ld from %f sec to %f sec.", _currentPart, CMTimeGetSeconds(startTime), CMTimeGetSeconds(endTime));
        
        __weak AudioPlayer* weakself = self;
//        __weak id weakObserver = _timeObserver;
        
        _timeObserver = [self addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:endTime]] queue:NULL usingBlock:^{
            
            [weakself handleTimeBreak];
        }];

        [self seekToTime:startTime completionHandler:^(BOOL finished) {

            [self applyFadeInAndOutForStartTime:startTime endTime:endTime];
            
            _isPlaying = YES;

            [self play];
        }];
    }
    else {
        
        NSLog(@"No more parts to play.");
    }
}


- (void) playWithTimes:(NSArray*) times {

    if (_isPlaying) {
        
        NSLog(@"already playing. discarding play command.");
        
        return;
    }
    
    __block CMTime startTime = [times[0] CMTimeValue];
    __block CMTime endTime = [times.lastObject CMTimeValue];

    NSLog(@"Playing from %f sec to %f sec.", CMTimeGetSeconds(startTime), CMTimeGetSeconds(endTime));
    
    __weak AudioPlayer* weakself = self;
    
    _timeObserver = [self addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:endTime]] queue:NULL usingBlock:^{
        
        [weakself handleTimeBreak];
    }];
   
    
    // start times
    
    NSMutableArray* startTimes = [NSMutableArray array];
    
    {
        
        for (NSInteger index = 0; index < times.count; index += 2) {

            CMTime startTime = [times[index] CMTimeValue];
            CMTime newStartTime = CMTimeAdd(startTime, CMTimeMake(STUPID_APPLE_TOLERANCE, 1000));
            
            [startTimes addObject:[NSValue valueWithCMTime:newStartTime]];
        }
    }
    
    _startObserver = [self addBoundaryTimeObserverForTimes:startTimes queue:NULL usingBlock:^{
        
        [weakself handlePartWillBeginPlaying];
    }];
    
    // --
    
    
    // end times
    
    NSMutableArray* endTimes = [NSMutableArray array];
    
    {
    
        for (NSInteger index = 1; index < times.count; index += 2) {
            
            CMTime endTime = [times[index] CMTimeValue];
            CMTime newEndTime = CMTimeSubtract(endTime, CMTimeMake(STUPID_APPLE_TOLERANCE, 1000));
            
            [endTimes addObject:[NSValue valueWithCMTime:newEndTime]];
        }
    }

    _partObserver = [self addBoundaryTimeObserverForTimes:endTimes queue:NULL usingBlock:^{
        
        [weakself handlePartDidEndPlaying];
    }];
    
    // --
    
    
    // batch end
    
    {
        NSValue* batchEndTime = endTimes.lastObject;
        
        _batchObserver = [self addBoundaryTimeObserverForTimes:@[batchEndTime] queue:NULL usingBlock:^{
           
            [weakself handleBatchDidEndPlaying];
        }];
        
    }
    
    
    
    [self seekToTime:startTime completionHandler:^(BOOL finished) {
        
        [self applyFadeInAndOutForStartTime:startTime endTime:endTime];
        
        _isPlaying = YES;
        
        [self play];
    }];
    
}


- (void) applyFadeInAndOutForStartTime:(CMTime) startTime endTime:(CMTime) endTime {
 
    CMTime timeAfterFadeIn = CMTimeAdd(startTime, CMTimeMake(self.fadeInDuration * 1000, 1000));
    CMTime timeBeforeFadeOut = CMTimeSubtract(endTime, CMTimeMake(self.fadeOutDuration * 1000, 1000));
    
    AVMutableAudioMixInputParameters* fadeInAndOut = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:self.currentItem.tracks.firstObject.assetTrack];
//    [fadeInAndOut setVolume:0 atTime:startTime];
//    [fadeInAndOut setVolume:1 atTime:timeAfterFadeIn];
//    [fadeInAndOut setVolume:1 atTime:timeBeforeFadeOut];
//    [fadeInAndOut setVolume:0 atTime:endTime];

    [fadeInAndOut setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:CMTimeRangeFromTimeToTime(startTime, timeAfterFadeIn)];
    [fadeInAndOut setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:CMTimeRangeFromTimeToTime(timeBeforeFadeOut, endTime)];
    
    AVMutableAudioMix* audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = @[fadeInAndOut];
    self.currentItem.audioMix = audioMix;
}


- (NSArray*) timesForCurrentPart {
    
    // 1 -> 0
    // 2 -> 2
    // 3 -> 4
    // 4 -> 6
    // 5 -> 8
    // 6 -> 10
    
    return [_times subarrayWithRange:NSMakeRange((_currentPart * 2) - 2, 2)];
}


- (BOOL) hasNext {
    
    return (_currentPart < (NSInteger)_times.count + 1);
}



- (void) stop {
    
    [super pause];
}


- (void) dealloc {
    
    NSLog(@"AudioPlayer - Dealloc");
    
    [_playerItem removeObserver:self forKeyPath:@"status"];
    
//    if (_timeObserver) {
//
//        [self removeTimeObserver:_timeObserver];
//    }
}

@end
