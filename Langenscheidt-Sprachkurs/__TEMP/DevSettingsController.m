//
//  DevSettingsController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DevSettingsController.h"
#import "UserDataManager.h"



#define SKIPTOSCORESCREEN       @"skipToScoreScreen"
#define BROWSESETSUSERLESSON    @"browseSetsUserLesson"
#define RESETCOURSES            @"resetCourses"
#define MAXSCROLLOFFSET         @"maxScrollOffset"
#define SCROLLSPEED             @"scrollSpeed"
#define MATPICDELAY             @"matpicDelay"
#define SHOWONBOARDING          @"showOnboarding"
#define SUBSCRIPTIONCHECKINTERVAL       @"subscriptionCheckInterval"
#define SUBSCRIPTIONS_ENABLED       @"subscriptionsEnabled"
#define SIMULATEERROR           @"simulateError"


@implementation DevSettingsController


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    _settingsManager = [SettingsManager instanceNamed:@"dev"];
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

    self.navigationItem.title = @"Entwickler-Einstellungen";
    
    
    
    [self _updateUI];
}


- (void) _updateUI {
    
    [self _updateSwitchSkipToScoreScreen];

    [self _updateSwitchBrowseSetsUserLesson];
    
    [self _updateSwitchResetCourses];
    
    [self _updateSliderMaxScrollOffset];
    [self _updateLabelMaxScrollOffset];
    
    [self _updateSliderScrollSpeed];
    [self _updateLabelScrollSpeed];
    
    [self _updateSliderMatpicDelay];
    [self _updateLabelMatpicDelay];
    
    [self _updateSwitchShowOnboarding];
    
    [self _updateSwitchSubscriptionsEnabled];
    
    [self _updateSwitchSimulateError];
}





#pragma mark - Reset User DB

- (IBAction)actionReset:(id)sender {
    
    [[UserDataManager instance] reset];
}



#pragma mark - Skip to Score Screen

- (IBAction)actionSkipToScoreScreen:(id)sender {

    BOOL skipToScoreScreen = self.switchSkipToScoreScreen.on;
    
    [_settingsManager setValue:@(skipToScoreScreen) forKey:SKIPTOSCORESCREEN];
    
//    [self _updateUI];
}


- (void) _updateSwitchSkipToScoreScreen {
    
    BOOL skipToScoreScreen = [[_settingsManager valueForKey:SKIPTOSCORESCREEN] boolValue];
    
    self.switchSkipToScoreScreen.on = skipToScoreScreen;
}



#pragma mark - Browse sets user lesson

- (IBAction)actionBrowseSetsUserLesson:(id)sender {
    
    BOOL browseSetsUserLesson = self.switchBrowseSetsUserLesson.on;
    
    [_settingsManager setValue:@(browseSetsUserLesson) forKey:BROWSESETSUSERLESSON];
    
//    [self _updateUI];
}


- (void) _updateSwitchBrowseSetsUserLesson {
    
    BOOL browseSetsUserLesson = [[_settingsManager valueForKey:BROWSESETSUSERLESSON] boolValue];
    
    self.switchBrowseSetsUserLesson.on = browseSetsUserLesson;
}




#pragma mark - Browse sets user lesson

- (IBAction)actionResetCourses:(id)sender {
    
    BOOL resetCourses = self.switchResetCourses.on;
    
    [_settingsManager setValue:@(resetCourses) forKey:RESETCOURSES];
    
//    [self _updateUI];
}


- (void) _updateSwitchResetCourses {
    
    BOOL resetCourses = [[_settingsManager valueForKey:RESETCOURSES] boolValue];
    
    self.switchResetCourses.on = resetCourses;
}




#pragma mark - Menu Image Max Scroll offset

- (IBAction)actionMenuImageMaxScrollOffset:(id)sender {
    
    float maxScrollOffset = self.sliderMenuImageMaxScrollOffset.value;
    
    [_settingsManager setValue:@(maxScrollOffset) forKey:MAXSCROLLOFFSET];
    
    [self _updateLabelMaxScrollOffset];
}


- (void) _updateSliderMaxScrollOffset {
    
    float maxScrollOffset = [[_settingsManager valueForKey:MAXSCROLLOFFSET] floatValue];
    
    self.sliderMenuImageMaxScrollOffset.value = maxScrollOffset;
}


- (void) _updateLabelMaxScrollOffset {
    
    self.labelMaxScrollOffset.text = [NSString stringWithFormat:@"%0.0f", self.sliderMenuImageMaxScrollOffset.value];
}



#pragma mark - Menu Image Relative Scroll Speed

- (IBAction) actionMenuImageScrollSpeed:(id) sender {
    
    float scrollSpeed = self.sliderMenuImageScrollSpeed.value;
    
    [_settingsManager setValue:@(scrollSpeed) forKey:SCROLLSPEED];
    
    [self _updateLabelScrollSpeed];
}

- (void) _updateSliderScrollSpeed {
    
    float scrollSpeed = [[_settingsManager valueForKey:SCROLLSPEED] floatValue];
    
    self.sliderMenuImageScrollSpeed.value = scrollSpeed;
}


- (void) _updateLabelScrollSpeed {
    
    self.labelMenuImageScrollSpeed.text = [NSString stringWithFormat:@"%0.0f%%", self.sliderMenuImageScrollSpeed.value];
}



#pragma mark - MATPIC delay

- (IBAction)actionMatpicDelay:(id)sender {
    
    float delay = self.sliderMatpicDelay.value;
    
    [_settingsManager setValue:@(delay) forKey:MATPICDELAY];
    
    [self _updateLabelMatpicDelay];
}


- (void) _updateSliderMatpicDelay {
    
    float delay = [[_settingsManager valueForKey:MATPICDELAY] floatValue];
    
    self.sliderMatpicDelay.value = delay;
}


- (void) _updateLabelMatpicDelay {
    
    self.labelMatpicDuration.text = [NSString stringWithFormat:@"%0.1f", self.sliderMatpicDelay.value / 1000.0];
}



#pragma mark - Onboarding

- (IBAction) actionShowOnboarding:(id)sender {
    
    BOOL show = self.switchShowOnboarding.on;
    
    [_settingsManager setValue:@(show) forKey:SHOWONBOARDING];
}



- (void) _updateSwitchShowOnboarding {
    
    BOOL show = [[_settingsManager valueForKey:SHOWONBOARDING] boolValue];
    
    self.switchShowOnboarding.on = show;
}



//#pragma mark - Subscription Check Interval
//
//- (IBAction) actionSubscriptionCheckInterval:(id)sender {
//    
//    float interval = self.sliderSubscriptionCheckIntervall.value;
//    
//    [_settingsManager setValue:@(interval) forKey:SUBSCRIPTIONCHECKINTERVAL];
//    
//    [self _updateLabelMatpicDelay];
//}
//
//
//- (void) _updateLabelSubscriptionCheckInterval {
//    
//    self.labelSubscriptionCheckInterval.text = [NSString stringWithFormat:@"%0.1f", self.sliderMatpicDelay.value / 1000.0];
//
//}


#pragma mark - Subscriptions Enabled

- (IBAction)actionSubscriptionsEnabled:(id)sender {
    
    BOOL enabled = self.switchSubscriptionsEnabled.on;
    
    [_settingsManager setValue:@(enabled) forKey:SUBSCRIPTIONS_ENABLED];
}



- (void) _updateSwitchSubscriptionsEnabled {
    
    BOOL enabled = [[_settingsManager valueForKey:SUBSCRIPTIONS_ENABLED] boolValue];
    
    self.switchSubscriptionsEnabled.on = enabled;
}



#pragma mark - Onboarding

- (IBAction)actionSwitchSimulateError:(id)sender {
    
    BOOL show = self.switchSimulateError.on;
    
    [_settingsManager setValue:@(show) forKey:SIMULATEERROR];
}



- (void) _updateSwitchSimulateError {
    
    BOOL show = [[_settingsManager valueForKey:SIMULATEERROR] boolValue];
    
    self.switchSimulateError.on = show;
}



@end
