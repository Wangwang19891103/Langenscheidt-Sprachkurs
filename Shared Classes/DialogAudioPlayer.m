//
//  DialogAudioPlayer.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 01.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "DialogAudioPlayer.h"
#import "ContentManager.h"
#import "ContentDataManager.h"


@implementation DialogAudioPlayer

- (id) initWithDialogLines:(NSArray*) dialogLines withLesson:(Lesson *)lesson {
    
    NSString* fileName = [self _findAudioFileInDialogLines:dialogLines];

    NSString* filePath = [[ContentManager instance] dialogAudioPathForFileName:fileName forLesson:lesson];
    
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    
    _dialogLines = dialogLines;
    
//    NSArray* times = [self _getTimesForDialogs:dialogs];
    
    self = [super initWithURL:fileURL times:nil];
    
    return self;
}


- (id) initWithExerciseDict:(NSDictionary *)exerciseDict {
    
    NSString* audioFile = exerciseDict[@"audioFile"];
    
    Exercise* exercise = exerciseDict[@"exerciseObject"];
//    Course* course = [[ContentDataManager instance] courseForExerciseCluster:exercise.cluster];
    Lesson* lesson = [[ContentDataManager instance] lessonForExerciseCluster:exercise.cluster];
    
    NSString* filePath = [[ContentManager instance] dialogAudioPathForFileName:audioFile forLesson:lesson];
    
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:audioFile ofType:@"mp3"];
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    
    self = [super initWithURL:fileURL];
    
    _exerciseDict = exerciseDict;
    
    return self;
}



#pragma mark - Find audio file

- (NSString*) _findAudioFileInDialogLines:(NSArray*) dialogLines {
    
    NSString* audioFile = nil;
    
    for (NSDictionary* line in dialogLines) {
        
        if (line[@"audioFile"]) {
            
            audioFile = line[@"audioFile"];
            break;
        }
    }
    
    NSAssert(audioFile, @"no audio file found");
    
    return audioFile;
}


//Drink, Paula?	Etwas zu trinken, Paula?		cd1_11_Track11#	0:01.53 - 0:04.27
//Oh. Yes, please. [Where’s the waiter]?	Oh. Ja, gerne. Wo ist der Kellner?	1010		0:04.27 - 0:08.88
//
//Waiter? There isn’t a waiter in a [pub]. 	Kellner? Es gibt keinen Kellner in einem Pub.	1050		0:08.88 - 0:12.91
//
//We go and [get] our [drink]s at the bar.	Wir gehen unsere Getränke an der Theke holen.	1100, 1060		0:12.91 - 0:15.70
//
//And [when do you pay?]	Und wann zahlt man?	1020		0:15.70 - 0:17.51
//
//We pay when we get the drinks – [at the bar]. 	Wir zahlen, wenn wir die Getränke holen – an der Theke.	1080		0:17.51 - 0:21.30
//
//[Each time], for the first, second, third drink …	Jedes Mal: für das erste Getränk, das zweite, dritte …	1110		0:21.30 - 0:25.45
//
//Oh. It’s [different] in Germany. We pay before we [leave].	Ach so. Es ist anders in Deutschland. Wir zahlen, bevor wir gehen.	1120, 1090		0:25.45 - 0:31.11
//
//Really? Well, I’d like a pint. [What about you?]	Echt? Also, ich möchte ein pint. Was ist mit dir?	1030		0:31.11 - 0:36.55
//
//[I’d like] a gin tonic, please.	Ich möchte einen Gin Tonic, bitte.	1040		0:36.55 - 0:39.56
//
//A <i>gin and tonic<i>, we say.	Einen Gin und Tonic sagen wir.			0:39.56 - 0:42.98
//But <i>gin tonic<i> is English!	Aber Gin Tonic ist Englisch.			0:42.98 - 0:46.06
//Yes, but we don’t say it like that. [Just a minute] …	Ja, aber wir sagen es nicht so. Einen Augenblick …	1070		0:46.06 - 0:50.48
//
//Here you are, Paula, your G and T.	Bitte schön, Paula, dein G und T.			0:50.48 - 0:54.00


- (void) playNextBatch {
    
    if (![self hasNextBatch]) {
        
        
    return;
    }
    
    NSLog(@"playNextBatch");
    
    NSArray* times = [self _getTimesForNextBatch];
    
   [self playWithTimes:times];
}


- (void) playExerciseAudio {
    
    NSString* audioRange = _exerciseDict[@"audioRange"];
    NSArray* times = [self timesFromString:audioRange];
    
    [self playWithTimes:times];
}


- (BOOL) hasNextBatch {
    
    return _currentIndex < _dialogLines.count;
}


- (NSArray*) _getTimesForNextBatch {
    
    NSMutableArray* finalTimes = [NSMutableArray array];
    
    BOOL hasGap = NO;
    
    while (!hasGap && _currentIndex < _dialogLines.count) {
        
        NSDictionary* dialogLine = _dialogLines[_currentIndex++];
        
        NSString* timeString = dialogLine[@"audioRange"];
        
        
        // case no audio range (narrator bubble without audio)
        
        if (timeString.length == 0) {

            break;
        }
        
        
        // case has audio range
        
        else {
            
            hasGap = [self hasGapsForDialogLine:dialogLine];
            
            NSArray* times = [self timesFromString:timeString];
            CMTime startTime = [times[0] CMTimeValue];
            CMTime endTime = [times[1] CMTimeValue];
            
            [finalTimes addObject:[NSValue valueWithCMTime:startTime]];
            [finalTimes addObject:[NSValue valueWithCMTime:endTime]];
            
            if (hasGap) {
                
                return finalTimes;
            }
        }
        
        
    }
    
    return finalTimes;
}



//- (NSArray*) _getTimesForDialogs:(NSArray*) dialogs {
//    
//    NSMutableArray* finalTimes = [NSMutableArray array];
//    
//    CMTime currentStartTime;
//    CMTime currentEndTime;
//    BOOL shouldConcat = NO;
//    
//    CMTime startTime2;
//    CMTime endTime2;
//    
//    for (Dialog* dialog in dialogs) {
//        
//        NSString* timeString = dialog.audioRange;
//        BOOL hasGap = [self hasGapsForDialog:dialog];
//        
//        NSArray* times = [self timesFromString:timeString];
//        CMTime startTime = [times[0] CMTimeValue];
//        CMTime endTime = [times[1] CMTimeValue];
//        
//        currentEndTime = endTime;
//        
//        // different cases
//        
//        if (hasGap) {
//            
//            endTime2 = endTime;
//            
//            if (shouldConcat) {
//                
//                startTime2 = currentStartTime;
//            }
//            else {
//                
//                startTime2 = startTime;
//            }
//            
//            shouldConcat = NO;  // reset to NO
//            
//            // save times to array
//            
//            [finalTimes addObject:[NSValue valueWithCMTime:startTime2]];
//            [finalTimes addObject:[NSValue valueWithCMTime:endTime2]];
//        }
//        else {
//            
//            if (shouldConcat) {
//                
//                // wait for gap to finish concat
//            }
//            else {
//                
//                currentStartTime = startTime;
//                shouldConcat = YES;  // starting concat
//            }
//        }
//    }
//    
//    if (shouldConcat) {
//        
//        // save times to array
//        
//        [finalTimes addObject:[NSValue valueWithCMTime:currentStartTime]];
//        [finalTimes addObject:[NSValue valueWithCMTime:currentEndTime]];
//    }
//    
//    return finalTimes;
//}


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


- (BOOL) hasGapsForDialogLine:(NSDictionary*) dialogLine {
    
    return [dialogLine[@"textLang1"] rangeOfString:@"["].location != NSNotFound;
}


- (void) skipCurrentIndex {
    
    ++_currentIndex;
}




@end
