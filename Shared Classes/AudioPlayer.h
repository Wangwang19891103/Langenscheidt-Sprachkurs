//
//  AudioPlayer.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;


@protocol AudioPlayerDelegate;


@interface AudioPlayer : AVPlayer {

    NSArray* _times;
    NSInteger _currentPart;
    id _timeObserver;
    id _partObserver;  // when part ends
    id _startObserver;
    id _batchObserver;  // when batch ends
    BOOL _isPlaying;
    AVPlayerItem* _playerItem;
}

@property (nonatomic, assign) CGFloat fadeInDuration;

@property (nonatomic, assign) CGFloat fadeOutDuration;

@property (nonatomic, assign) id<AudioPlayerDelegate> delegate;

@property (nonatomic, readonly) BOOL isPlaying;

- (id) initWithURL:(NSURL*) url times:(NSArray*) times;

- (void) playNext;
- (void) playWithTimes:(NSArray*) times;

- (BOOL) hasNext;

- (void) stop;

@end



@protocol AudioPlayerDelegate <NSObject>

- (void) audioPlayerDidFinishLoadingAsset:(AudioPlayer*) player;

- (void) audioPlayerDidEndPlaying:(AudioPlayer*) player;

- (void) audioPlayerDidEndPlayingPart:(AudioPlayer*) player;

- (void) audioPlayerDidEndPlayingBatch:(AudioPlayer*) player;

- (void) audioPlayerWillBeginPlayingPart:(AudioPlayer*) player;

@end