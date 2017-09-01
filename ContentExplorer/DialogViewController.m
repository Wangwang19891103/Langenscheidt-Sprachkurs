//
//  DialogViewControler.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "DialogViewController.h"
#import "PearlTitle.h"
#import "ContentDataManager.h"
//#import "Dialog.h"


#define TOP_MARGIN  20
#define BOTTOM_MARGIN   20
#define PADDING_BELOW_SPEAKER   10


@implementation DialogViewController

@synthesize pearl;
@synthesize prototypeSpeakerLabel;
@synthesize prototypeTextLang1Button;
@synthesize prototypeTextLang2Label;
@synthesize scrollView;
@synthesize contentView;


- (void) awakeFromNib {
    
    [super awakeFromNib];
    
//    self.prototypeSpeakerLabel.translatesAutoresizingMaskIntoConstraints = YES;
//    self.prototypeTextLang1Label.translatesAutoresizingMaskIntoConstraints = YES;
//    self.prototypeTextLang2Label.translatesAutoresizingMaskIntoConstraints = YES;
}


- (void) setPearl:(Pearl *)p_pearl {
    
    pearl = p_pearl;
    
    _dialogs = [[ContentDataManager instance] dialogsForPearl:pearl];
    _posY = TOP_MARGIN;
    
    Dialog* firstDialog = _dialogs[0];
    NSString* audioFile = firstDialog.audioFile;
    NSURL* fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:audioFile ofType:@"mp3"]];

//    assert(audioFile);
    
    NSLog(@"audioFile: %@", audioFile);
    
    _player = [[AudioPlayer alloc] initWithURL:fileURL times:@[]];
    _player.fadeInDuration = 0.3;
    _player.fadeOutDuration = 0.3;

}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = [PearlTitle titleForPearl:pearl];
    
    [self.prototypeSpeakerLabel removeFromSuperview];
    [self.prototypeTextLang1Button removeFromSuperview];
    [self.prototypeTextLang2Label removeFromSuperview];
    
    
    NSString* currentSpeaker = nil;
    
    for (Dialog* dialog in _dialogs) {
        
        NSString* newSpeaker = dialog.speaker;
        
        if (![newSpeaker isEqualToString:currentSpeaker]) {
            
            currentSpeaker = newSpeaker;
            
            [self insertSpeaker:currentSpeaker];
        }
        
        NSString* textLang1 = dialog.textLang1;
        NSString* textLang2 = dialog.textLang2;
        
        [self insertTextLang1:textLang1 withID:dialog.id];
        [self insertTextLang2:textLang2];
    }
    
    [self resizeContentViewToFit];
    self.scrollView.contentSize = self.contentView.bounds.size;
}


- (void) insertView:(UIView*) label withOffset:(CGFloat) offset {
    
    CGRect newFrame = label.frame;
    newFrame.origin.y = _posY;
    label.frame = newFrame;
    
    [self.contentView addSubview:label];
    
    _posY += label.frame.size.height;
    
    label.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-marginLeft-[label]-marginRight-|"
                                                                  options:0
                                                                  metrics:@{@"marginLeft" : @(label.frame.origin.x),
                                                                            @"marginRight" : @(label.frame.origin.x)}
                                                                    views:NSDictionaryOfVariableBindings(label)]];

    if (_lastView) {
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lastView]-offset-[label]"
                                                                    options:0
                                                                     metrics:@{@"offset" : @(offset)}
                                                                       views:NSDictionaryOfVariableBindings(_lastView, label)]];
        
    }
    else {
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-offset-[label]"
                                                                                 options:0
                                                                                 metrics:@{@"offset" : @(TOP_MARGIN)}
                                                                                   views:NSDictionaryOfVariableBindings(label)]];
        
    }
    
    _lastView = label;
    
//    label.backgroundColor = [UIColor yellowColor];

}


- (void) resizeContentViewToFit {

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lastView]-margin-|"
                                                                            options:0
                                                                             metrics:@{@"margin" : @(BOTTOM_MARGIN)}
                                                                               views:NSDictionaryOfVariableBindings(_lastView)]];
    
//    CGFloat newHeight = 0;
//    
////    for (UIView* subview in self.contentView.subviews) {
////        
////        newHeight = MAX(newHeight, subview.frame.origin.y + subview.frame.size.height);
////    }
//
//    newHeight = _lastView.frame.origin.y + _lastView.frame.size.height;
//    
//    newHeight += BOTTOM_MARGIN;
//    
//    CGRect newFrame = self.contentView.frame;
//    newFrame.size.height = newHeight;
//    self.contentView.frame = newFrame;
}


- (void) resizeLabelHeightToFit:(UILabel*) label {
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : label.font,
                                 NSParagraphStyleAttributeName : paragraph
                                 };
    
    CGRect textRect = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGRect newFrame = label.frame;
    newFrame.size.height = textRect.size.height;
    label.frame = newFrame;
}


- (void) resizeButtonHeightToFit:(UIButton*) button {
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : button.titleLabel.font,
                                 NSParagraphStyleAttributeName : paragraph
                                 };
    
    CGRect textRect = [[button titleForState:UIControlStateNormal] boundingRectWithSize:CGSizeMake(button.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    CGRect newFrame = button.frame;
    newFrame.size.height = textRect.size.height;
    button.frame = newFrame;
}


- (void) insertSpeaker:(NSString*) speaker {
    
    UILabel* label = [self copyLabel:self.prototypeSpeakerLabel];
    label.text = speaker;
    [self resizeLabelHeightToFit:label];
    
//    CGRect newFrame = label.frame;
//    newFrame.size.height += PADDING_BELOW_SPEAKER;
//    label.frame = newFrame;
    
    [self insertView:label withOffset:PADDING_BELOW_SPEAKER];
}


- (void) insertTextLang1:(NSString*) text withID:(uint) id {

    UIButton* button = [self copyButton:self.prototypeTextLang1Button];
    [button setTitle:text forState:UIControlStateNormal];
    [self resizeButtonHeightToFit:button];
    [self insertView:button withOffset:0];
    button.tag = id;
    [button addTarget:self action:@selector(actionAudio:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) insertTextLang2:(NSString*) text {

    UILabel* label = [self copyLabel:self.prototypeTextLang2Label];
    label.text = text;
    [self resizeLabelHeightToFit:label];
    [self insertView:label withOffset:0];

}


- (UILabel*) copyLabel:(UILabel*) label {
    
    // kindova hack
    
    id labelCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:label]];
    
    return labelCopy;
}


- (UIButton*) copyButton:(UIButton*) button {
    
    // kindova hack
    
    UIButton* buttonCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:button]];
    
    return buttonCopy;
}


- (IBAction) actionAudio:(UIButton *)sender {
    
    NSLog(@"audio (%ld)", sender.tag);
    
    Dialog* dialog = [[ContentDataManager instance] dialogForPearl:[_dialogs[0] pearl] withID:(int)sender.tag];
    NSString* audioRange = dialog.audioRange;
    
    NSArray* times = [self timesFromString:audioRange];
    CMTime startTime = [times[0] CMTimeValue];
    CMTime endTime = [times[1] CMTimeValue];
    

    
    [_player playWithTimes:@[[NSValue valueWithCMTime:startTime], [NSValue valueWithCMTime:endTime]]];
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


@end
