//
//  ViewController.h
//  AudioTest1
//
//  Created by Stefan Ueter on 23.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface ViewController : UIViewController <AVAudioPlayerDelegate>

- (IBAction) play;

@end

