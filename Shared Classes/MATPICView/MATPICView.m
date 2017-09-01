//
//  MATPICVIew.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "MATPICView.h"
#import "MATPICItem.h"
#import "UIView+RemoveConstraints.h"
#import "NSArray+Extensions.h"
#import "VocabularyFormatter.h"
#import "ContentManager.h"
@import AVFoundation;


#define ITEMS_PER_ROW       2

#define ANIMATION_DURATION  0.3

#define MAX_NUMBER_OF_SAME_INDEXES_AFTER_RANDOMIZATION      0

#define SHOW_STATE_DURATION         2

#define DELAY_BEFORE_NEXT_ROUND     0.3


#define SCORE_PER_CORRECT_ANSWER        2



@implementation MATPICView

@synthesize vocabularySets;

@synthesize fontName;
@synthesize fontSize;
@synthesize fontColor;
@synthesize imageWidth;
@synthesize labelSpacing;
@synthesize horizontalSpacing;
@synthesize verticalSpacing;
@synthesize animating;
@synthesize delegate;



#pragma mark - Init

- (id) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
//    self.backgroundColor = [UIColor blueColor];
    self.roundDelay = SHOW_STATE_DURATION;
    self.backgroundColor = [UIColor clearColor];
    
    _currentRound = -1;
}



#pragma mark - View, Layout, Constraints

- (void) createView {

    [self _createInnerView];
    
    [self _randomizeVocabularySets];

    [self _createItems];

    [self _reset];
    
    [self _startNextRound];
}


- (void) layoutSubviews {
    
    NSLog(@"matpic layout");
    
    [super layoutSubviews];
}


- (void) updateConstraints {

    NSLog(@"matpic constraints");
    
//    [super layoutSubviews];
    
    [_innerView setNeedsLayout];
    [_innerView layoutIfNeeded];  // i really dont get autolayout...! System goes into this method (updateconstraints) twice. At this point, at first call it layouts innerview and second call it layouts the items... okay. This is in ios 8.4. In ios 9.3 [super layoutSubviews] suffices.
    
    [self _arrangeSubviews];
    
    [self invalidateIntrinsicContentSize];
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (void) _arrangeSubviews {

    uint col = 0;
    UIView* previousView = nil;
    UIView* highestViewInCurrentRow = nil;
    UIView* highestViewInPreviousRow = nil;
    

    for (UIView* subview in _innerView.subviews) {
        
        [_innerView removeConstraintsAffectingSubview:subview];
    }
    
    for (UIView* subview in _innerView.subviews) {
        
        NSLog(@"subview frame: %@", NSStringFromCGRect(subview.frame));
        
        if (col == 0) {  // new row
            
            highestViewInPreviousRow = highestViewInCurrentRow;
            highestViewInCurrentRow = nil;
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[subview]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
            
            if (highestViewInPreviousRow) {
                
                [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[highestViewInPreviousRow]-(spacing)-[subview]" options:0 metrics:@{@"spacing" : @(self.verticalSpacing)} views:NSDictionaryOfVariableBindings(subview, highestViewInPreviousRow)]];
            }
            else {
                
                [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[subview]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
            }
        }
        else {  // same row
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]-(spacing)-[subview]" options:NSLayoutFormatAlignAllTop metrics:@{@"spacing" : @(self.horizontalSpacing)} views:NSDictionaryOfVariableBindings(subview, previousView)]];
        }
        
        if (col == ITEMS_PER_ROW - 1) {  // last item in row
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
            
            col = 0;
        }
        else {
            
            ++col;
        }
        
        if (previousView) {
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview(previousView)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(previousView, subview)]];
        }
        
        
        previousView = subview;
        highestViewInCurrentRow = (subview.frame.size.height > highestViewInCurrentRow.frame.size.height) ? subview : highestViewInCurrentRow;
    }
    
    
    if (highestViewInCurrentRow) {
        
        [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[highestViewInCurrentRow]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(highestViewInCurrentRow)]];
    }
}

- (void) _createInnerView {

    _innerView = [[UIView alloc] init];
//    _innerView.backgroundColor = [UIColor whiteColor];
    _innerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_innerView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_innerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_innerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_innerView)]];
}


- (void) _createItems {
    
    uint tag = 0;
    
    NSMutableArray* items = [NSMutableArray array];
    _maxScore = 0;
    
    for (NSDictionary* vocabularySet in vocabularySets) {
        
//        NSString* textLang2 = vocabularySet[@"textLang2"];
        NSString* imageName = vocabularySet[@"image"];
        
        UIFont* font = [UIFont fontWithName:self.fontName size:self.fontSize];
        
        NSDictionary* attributes = @{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName : self.fontColor
                                     };
        
//        NSString* photoFile = imageName;
        
        
        
//        photoFile = [photoFile stringByDeletingPathExtension];
//        photoFile = [[photoFile stringByAppendingString:@"_small"] stringByAppendingPathExtension:@"jpg"];
//        NSString* photosFolder = [[NSBundle mainBundle] pathForResource:@"Photos/small" ofType:nil];
//        NSString* fullPath = [photosFolder stringByAppendingPathComponent:photoFile];
//        UIImage* image = [UIImage imageWithContentsOfFile:fullPath];

        UIImage* image = [[ContentManager instance] smallVocabularyImageNamed:imageName forLesson:self.lesson];
        
        NSString* string = [VocabularyFormatter formattedStringForLanguage:Lang2 withDictionary:vocabularySet];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        
        MATPICItem* item = [[MATPICItem alloc] init];
        item.image = image;
        item.imageWidth = self.imageWidth;
        item.attributedString = attributedString;
        item.spacing = self.labelSpacing;
        item.tag = tag++;
        item.delegate = self;
        
        [item createView];

        [items addObject:item];
        
        _maxScore += SCORE_PER_CORRECT_ANSWER;
    }
    
    NSArray* randomItems = [NSArray randomizedArrayFromArray:items];
    
    for (UIView* view in randomItems) {
        
        [_innerView addSubview:view];
    }
}



#pragma mark - Reordering Logic

- (void) _reorderItemsWithCompletionBlock:(void (^)(void)) completionBlock {
    
    NSArray* orderBefore = [NSArray arrayWithArray:_innerView.subviews];
    
    do {
    
        NSLog(@"randomizing");
        
        NSArray* subviewRefs = [NSArray arrayWithArray:_innerView.subviews];
        
        for (UIView* subview in subviewRefs) {
            
            enum {Front, Back} place = arc4random() % 2;
            
            if (place == Front) {
                
                [_innerView bringSubviewToFront:subview];
            }
            else {
                
                [_innerView sendSubviewToBack:subview];
            }
        }
        
    } while (![self _arrayRandomizedEnough:_innerView.subviews reference:orderBefore]);
    
    
    [self setNeedsUpdateConstraints];
    
    animating = YES;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        animating = NO;
        
        [self _performBlock:completionBlock afterDelay:DELAY_BEFORE_NEXT_ROUND];
    }];
}


- (BOOL) _arrayRandomizedEnough:(NSArray*) array reference:(NSArray*) reference {
    
    uint numberOfSameIndexes = 0;
    
    for (id object in array) {
        
        NSInteger index1 = [array indexOfObject:object];
        NSInteger index2 = [reference indexOfObject:object];
        
        if (index1 == index2) ++numberOfSameIndexes;
    }
    
    return (numberOfSameIndexes <= MAX_NUMBER_OF_SAME_INDEXES_AFTER_RANDOMIZATION);
}



#pragma mark - Round Logic

- (void) _randomizeVocabularySets {
    
    self.vocabularySets = [NSArray randomizedArrayFromArray:self.vocabularySets];
}


- (void) _reset {
    
    _currentRound = -1;
    _scoreAfterFinish = 0;
}


- (void) _startNextRound {
    
    if (![self _hasNextRound]) {
        
        return;
    }
    
    
    ++_currentRound;
    
    NSDictionary* vocabularySet = [self _currentVocabularySet];
    
    if ([self.delegate respondsToSelector:@selector(matpicView:didStartNewRoundWithVocabularySet:)]) {
        
        [self.delegate matpicView:self didStartNewRoundWithVocabularySet:vocabularySet];
    }
}


- (BOOL) _hasNextRound {
    
    return _currentRound < (int)self.vocabularySets.count - 1;
}


- (NSDictionary*) _currentVocabularySet {
    
    return self.vocabularySets[_currentRound];
}


- (void) _checkItem:(MATPICItem*) item {
    
    [self _blockInteraction];
    
    
    MATPICItemState state;
    
    state = [self _itemIsCorrect:item] ? Correct : Wrong;
    
    if (state == Correct) {
    
        [self playCorrectSound];
        
        _scoreAfterFinish += SCORE_PER_CORRECT_ANSWER;
    }
    
    
    if (state == Wrong) {
        
        [self playWrongSound];
        
        MATPICItem* missedItem = [self _missedItem];
        
        [self _showItem:missedItem withState:Missed completionBlock:^{
            
            missedItem.state = Normal;
        }];
    }
    
    
    __weak MATPICView* weakself = self;
    
    [self _showItem:item withState:state completionBlock:^{

        item.state = Normal;
        
        if ([weakself _hasNextRound]) {
        
            [weakself _reorderItemsWithCompletionBlock:^{
                
                [weakself _startNextRound];
                
                [weakself _unblockInteraction];
            }];
        }
        else {
            
            if ([weakself.delegate respondsToSelector:@selector(matpicViewDidFinishLastRound:)]) {
                
                [weakself.delegate matpicViewDidFinishLastRound:weakself];
            }
        }
    }];
}


- (MATPICItem*) _missedItem {
    
    for (UIView* subview in _innerView.subviews) {
        
        if ([subview isKindOfClass:[MATPICItem class]]) {
            
            MATPICItem* item = (MATPICItem*)subview;
            
            if ([self _itemIsCorrect:item]) {
                
                return item;
            }
        }
    }
    
    NSLog(@"Error: Missed item not found!");
    
    return nil;
}


- (BOOL) _itemIsCorrect:(MATPICItem*) item {
    
    return item.tag == _currentRound;
}


- (void) _showItem:(MATPICItem*) item withState:(MATPICItemState) state completionBlock:(void (^)(void)) completionBlock {
    
    item.state = state;
    
    [self _performBlock:completionBlock afterDelay:self.roundDelay];
}


- (void) playCorrectSound {
    
    NSURL* soundsURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    NSURL* URL = [soundsURL URLByAppendingPathComponent:@"nano/Stockholm_Haptic.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)URL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}


- (void) playWrongSound {
    
    NSURL* soundsURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    NSURL* URL = [soundsURL URLByAppendingPathComponent:@"nano/StockholmFailure_Haptic.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)URL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}


- (void) _blockInteraction {
    
    _interactionBlocked = YES;
}


- (void) _unblockInteraction {
    
    _interactionBlocked = NO;
}




#pragma mark - Delegate

- (BOOL) itemShouldProcessTap:(MATPICItem*) item {
    
    return (!_interactionBlocked);
}


- (void) itemDidGetTapped:(MATPICItem *)item {
    
    NSLog(@"%ld", item.tag);
    
    [self _checkItem:item];
}




#pragma mark - Utility

- (void) _performBlock:(void (^)(void)) block afterDelay:(CGFloat) seconds {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}




#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
//    self.vocabularySets = @[
//                       @[@"Fine, thanks.", @"Danke, gut.", @"MATPIC_DUMMY_01"],
//                       @[@"Good morning.", @"Good morning.", @"MATPIC_DUMMY_02"],
//                       @[@"How are you?", @"Wie geht's dir/Ihnen?", @"MATPIC_DUMMY_03"],
//                       @[@"Where are you from?", @"Woher kommst du/kommen Sie?", @"MATPIC_DUMMY_04"],
//                       ];
//    
//    [self createView];
}



- (void) dealloc {
    
    NSLog(@"MATPICView - Dealloc");
}



@end
