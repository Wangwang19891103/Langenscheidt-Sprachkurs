//
//  ContentManagerInstallPopup.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 12.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ContentManagerInstallPopupController.h"
#import "ContentManager.h"
#import "ErrorMessageManager.h"


#define STEP1_LABEL_FORMAT      [NSString stringWithFormat:@"Möchtest Du alle Lektionen von %@ herunterladen?"]



@implementation ContentManagerInstallPopupController


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    _progress = 0;

    [[ContentManager instance] addObserver:self];
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self _applyTexts];
    
    [self _updateProgress];
    
    [self _layoutStepViews];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    _blendView = [[UIView alloc] init];
    _blendView.translatesAutoresizingMaskIntoConstraints = NO;
    _blendView.backgroundColor = [UIColor blackColor];
    _blendView.alpha = 0.3;
    [self.view insertSubview:_blendView belowSubview:self.containerView];
    
//    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    _effectView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view insertSubview:_effectView belowSubview:_blendView];
    
    [self _showStepView:self.step1View animated:NO];
}


- (void) _applyTexts {

    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 4.0;
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary* textAttributesNormal = @{
                                           NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14],
                                           NSForegroundColorAttributeName : [UIColor colorWithWhite:0.13 alpha:1.0],
                                           NSParagraphStyleAttributeName : paragraph
                                           };
    NSDictionary* textAttributesBold = @{
                                           NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14],
                                           NSForegroundColorAttributeName : [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0],
                                           NSParagraphStyleAttributeName : paragraph

                                           };
    
    // step1 label

    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] init];

    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Möchtest Du alle Lektionen von " attributes:textAttributesNormal]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:self.courseTitle attributes:textAttributesBold]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" herunterladen?" attributes:textAttributesNormal]];

    self.step1Label.attributedText = attributedString;
    
    
    // step2 label

    // Lektionen von Aufbaukurs für jeden Tag werden heruntergeladen.

    attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Lektionen von " attributes:textAttributesNormal]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:self.courseTitle attributes:textAttributesBold]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" werden heruntergeladen." attributes:textAttributesNormal]];
    
    self.step2Label.attributedText = attributedString;

    
    // step3 label
    
    // Lektionen von Aufbaukurs für jeden Tag werden heruntergeladen.
    
    attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:self.courseTitle attributes:textAttributesBold]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" wurde erfolgreich heruntergeladen." attributes:textAttributesNormal]];
    
    self.step3Label.attributedText = attributedString;

    
}


- (void) _layoutStepViews {
    
    self.step1View.translatesAutoresizingMaskIntoConstraints = NO;
    self.step2View.translatesAutoresizingMaskIntoConstraints = NO;
    self.step3View.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [self.step1View setNeedsLayout];
//    [self.step1View layoutIfNeeded];
//
//    [self.step2View setNeedsLayout];
//    [self.step2View layoutIfNeeded];
}


- (void) _updateProgress {
    
    [self _updateStep2ProgressBar];
    [self _updateStep2ProgressLabel];
}


- (void) _showInstalling {
    
    self.step2ProgressLabel.text = @"Wird installiert...";
    
    // force run loop to process UI update

    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    
}


- (void) _updateStep2ProgressLabel {
    
    // step2 progress label
    
    self.step2ProgressLabel.text = [NSString stringWithFormat:@"%.0f %% geladen", _progress * 100];
}


- (void) _updateStep2ProgressBar {
    
    self.step2ProgressBar.percentage = _progress;
}


- (void) _showStepView:(UIView*) stepView animated:(BOOL) animated {

    NSTimeInterval blendOutDuration = 0.2;
    NSTimeInterval resizeDuration = 0.2;
    NSTimeInterval blendInDuration = 0.2;
    
    
    
    
    // inline blocks

    void(^fadeOut)(UIView*, BOOL);
    __block void(^addNextView)(UIView*, BOOL);
    __block void(^resize)(UIView*, BOOL);
    __block void(^fadeIn)(UIView*, BOOL);
    
    
    fadeOut = ^void(UIView* stepView, BOOL animated) {
        
        UIView* previousView = (self.containerView.subviews.count > 0) ? self.containerView.subviews[0] : nil;
        
        if (previousView) {
            
            if (animated) {
                
                previousView.alpha = 1.0;
                
                [UIView animateWithDuration:blendOutDuration
                                 animations:^{
                                     
                                     previousView.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     [previousView removeFromSuperview];
                                     
                                     addNextView(stepView, animated);
                                     
                                     resize(stepView, animated);
                                 }];
            }
            else {
                
                [previousView removeFromSuperview];
                
                addNextView(stepView, animated);
                
                resize(stepView, animated);
            }
        }
        else {
            
            addNextView(stepView, animated);
            
            resize(stepView, animated);
        }
    };

    addNextView = ^void(UIView* stepView, BOOL animated) {
        
        [self.containerView addSubview:stepView];
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[stepView]-|" options:0 metrics:@{@"left" : @(self.containerView.layoutMargins.left), @"right" : @(self.containerView.layoutMargins.right)} views:NSDictionaryOfVariableBindings(stepView)]];
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=top)-[stepView]-(>=bottom)-|" options:0 metrics:@{@"top" : @(self.containerView.layoutMargins.top), @"bottom" : @(self.containerView.layoutMargins.bottom)} views:NSDictionaryOfVariableBindings(stepView)]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stepView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        
        [stepView setNeedsLayout];
        [stepView layoutIfNeeded];
        
        stepView.alpha = 0.0;
        
        
        [self.containerView setNeedsUpdateConstraints];
    };

    
    resize = ^void(UIView* stepView, BOOL animated) {
        
        if (animated) {
            
            
            [UIView animateWithDuration:resizeDuration delay:0 options:0
                             animations:^{
                                 
                                 [self.containerView layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 
                                 fadeIn(stepView, animated);
                             }];
        }
        else {
            
            [self.containerView layoutIfNeeded];
            
            fadeIn(stepView, animated);
        }
    };
    
    
    fadeIn = ^void(UIView* stepView, BOOL animated) {
        
        if (animated) {
            
            [UIView animateWithDuration:blendInDuration delay:0 options:0
                             animations:^{
                                 
                                 stepView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        else {
            
            stepView.alpha = 1.0;
        }
    };
    
    
    
    fadeOut(stepView, animated);
    
    
}


- (void) _showCompletionView {
    
    [self _showStepView:self.step3View animated:YES];
}



- (void) updateViewConstraints {
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    
    [super updateViewConstraints];
}


- (void) _deactivateStep2CancelButton {
    
    [self.step2CancelButton setEnabled:NO];
}


- (BOOL) prefersStatusBarHidden {
    
    return NO;
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}



- (IBAction)actionCancelClose:(id)sender {

    self.cancelCloseBlock();
}

- (IBAction)actionConfirmDownload:(id)sender {

    [self _showStepView:self.step2View animated:YES];
    
    _confirmDownloadBlock();
}

- (IBAction)actionCancelDownload:(id)sender {
    
    if (_downloadFinished) return;
    
    
    self.cancelDownloadBlock();
    
    [self _showStepView:self.step3View animated:YES];
}

- (IBAction)actionConfirmClose:(id)sender {

    self.confirmDownloadCompleteBlock();
}





#pragma mark - ContentManagerObserver

- (void) contentManagerUpdatedProgress:(float)progress forDownloadingContentForLesson:(Lesson *)lesson {
    
    _progress = progress;
    
    [self _updateProgress];
}


- (void) contentManagerFinishedDownloadingContentForLesson:(Lesson *)lesson {

//    [self _deactivateStep2CancelButton];
    
    _downloadFinished = YES;
    
    NSLog(@"Download finished. Begin installing.");
    
    [self _showInstalling];
}


- (void) contentManagerFinishedInstallingContentForLesson:(Lesson *)lesson {
    
    NSLog(@"Installing finished.");
    
    [self performSelector:@selector(_showCompletionView) withObject:nil afterDelay:0.0];
}


- (void) contentManagerAbortedInstallationWithError:(NSError *)error {
    
    [[ErrorMessageManager instance] handleError:error withParentViewController:self completionBlock:^{
        
        self.cancelCloseBlock();
    }];
    
}



#pragma mark - Dealloc 

- (void) dealloc {
    
    [[ContentManager instance] removeObserver:self];
}

@end
