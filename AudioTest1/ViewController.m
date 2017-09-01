//
//  ViewController.m
//  AudioTest1
//
//  Created by Stefan Ueter on 23.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ViewController.h"
#import "AudioPlayer.h"


#define FADE_IN_DURATION        0.5
#define FADE_OUT_DURATION       0.5


@interface ViewController () {

//    AVPlayer* _player;
    AudioPlayer* _player;
    int _index;
    NSArray* _audioData;
    NSDictionary* _currentDict;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

//    AVPlayerItem* item = [AVPlayerItem playerItemWithURL:fileURL];
//    _player = [[AVPlayer alloc] initWithPlayerItem:item];
    
    
    NSString* fileName = @"audio.plist";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    _audioData = [NSArray arrayWithContentsOfURL:fileURL];

    fileName = @"full_track.mp3";
    filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    fileURL = [NSURL fileURLWithPath:filePath];

    NSArray* times = [self getTimes];
    _player = [[AudioPlayer alloc] initWithURL:fileURL times:times];
    _player.fadeInDuration = FADE_IN_DURATION;
    _player.fadeOutDuration = FADE_OUT_DURATION;

    _index = -1;
}


- (IBAction) play {
    
    if ([_player hasNext]) {
        
        [_player playNext];
    }
    
    return;
    
    // ---------------
    
    NSLog(@"play");
    
    [self getNext];
    
    if (_index == -1) {
        
        NSLog(@"end playing.");
        
        return;
    }
    
    NSString* timeString = _currentDict[@"time"];
    timeString = [timeString stringByReplacingOccurrencesOfString:@" " withString:@""];  // kill spaces
    NSArray* comps = [timeString componentsSeparatedByString:@"-"];
    NSAssert(comps.count == 2, @"comps must be 2");
    NSString* startTimeString = comps[0];
    NSString* endTimeString = comps[1];
    
    CMTime startTime = [self timeFromString:startTimeString];
    CMTime endTime = [self timeFromString:endTimeString];
    
    NSLog(@"time: %f -> %f", CMTimeGetSeconds(startTime), CMTimeGetSeconds(endTime));
    
    __weak ViewController* weakSelf = self;
    __weak AVPlayer* weakPlayer = _player;
    
    [_player addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:endTime]] queue:NULL usingBlock:^{
        
        [weakPlayer pause];
        
        [weakSelf didEndPlaying];
    }];
    
    [_player seekToTime:startTime completionHandler:^(BOOL finished) {
        
        [_player play];
    }];
}


- (NSArray*) getTimes {
    
    NSMutableArray* finalTimes = [NSMutableArray array];
    
    CMTime currentStartTime;
    CMTime currentEndTime;
    BOOL shouldConcat = NO;

    CMTime startTime2;
    CMTime endTime2;
    
    for (NSDictionary* dict in _audioData) {
        
        NSString* timeString = dict[@"time"];
        BOOL hasGap = [dict[@"hasGap"] boolValue];
        
        NSArray* times = [self timesFromString:timeString];
        CMTime startTime = [times[0] CMTimeValue];
        CMTime endTime = [times[1] CMTimeValue];

        currentEndTime = endTime;
        
        // different cases
        
        if (hasGap) {

            endTime2 = endTime;
            
            if (shouldConcat) {
                
                startTime2 = currentStartTime;
            }
            else {
                
                startTime2 = startTime;
            }
            
            shouldConcat = NO;  // reset to NO
            
            // save times to array
            
            [finalTimes addObject:[NSValue valueWithCMTime:startTime2]];
            [finalTimes addObject:[NSValue valueWithCMTime:endTime2]];
        }
        else {
            
            if (shouldConcat) {
                
                // wait for gap to finish concat
            }
            else {
                
                currentStartTime = startTime;
                shouldConcat = YES;  // starting concat
            }
        }
    }
    
    if (shouldConcat) {
        
        // save times to array
        
        [finalTimes addObject:[NSValue valueWithCMTime:currentStartTime]];
        [finalTimes addObject:[NSValue valueWithCMTime:currentEndTime]];
    }
    
    return finalTimes;
}


- (NSArray*) timesFromString:(NSString*) string {
    
    NSString* timeString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];  // kill spaces
    NSArray* comps = [timeString componentsSeparatedByString:@"-"];
    NSRange rangeOfColon = [string rangeOfString:@":"];
    NSAssert(rangeOfColon.location != NSNotFound, @"...");
    
    NSMutableArray* times = [NSMutableArray array];
    
    for (NSString* comp in comps) {
        
        NSString* minuteString = [comp substringWithRange:NSMakeRange(0, rangeOfColon.location)];
        NSString* secondString = [comp substringWithRange:NSMakeRange(rangeOfColon.location + 1, comp.length - rangeOfColon.location - 1)];
        
        CGFloat minutes = [minuteString floatValue];
        CGFloat seconds = [secondString floatValue];
        
        CGFloat totalMilliseconds = (minutes * 60 + seconds) * 1000;
        
        CMTime time = CMTimeMake(totalMilliseconds, 1000);
        
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    return times;
}


- (CMTime) timeFromString:(NSString*) string {
    
    NSRange rangeOfColon = [string rangeOfString:@":"];
//    NSRange rangeOfPeriod = [string rangeOfString:@"."];
    NSAssert(rangeOfColon.location != NSNotFound, @"...");
//    NSAssert(rangeOfPeriod.location != NSNotFound, @"...");
    
    NSString* minuteString = [string substringWithRange:NSMakeRange(0, rangeOfColon.location)];
    NSString* secondString = [string substringWithRange:NSMakeRange(rangeOfColon.location + 1, string.length - rangeOfColon.location - 1)];
    
    CGFloat minutes = [minuteString floatValue];
    CGFloat seconds = [secondString floatValue];
    
    CGFloat totalMilliseconds = (minutes * 60 + seconds) * 1000;
    
    CMTime time = CMTimeMake(totalMilliseconds, 1000);
    
    return time;
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"did finish");
    
    BOOL hasGap = [_currentDict[@"hasGap"] boolValue];
}


- (void) didEndPlaying {
    
    NSLog(@"did end playing");
    
    [self play];
}


- (void) getNext {
    
    _index++;
    
    if (_audioData.count < _index + 1) {
        
        _index = -1;
    }
    else {

        _currentDict = _audioData[_index];
    }
}



@end
