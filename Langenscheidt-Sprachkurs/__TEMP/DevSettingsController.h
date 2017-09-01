//
//  DevSettingsController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SettingsManager.h"


@interface DevSettingsController : UIViewController {
    
    SettingsManager* _settingsManager;
}

@property (strong, nonatomic) IBOutlet UISwitch *switchSkipToScoreScreen;

@property (strong, nonatomic) IBOutlet UISwitch *switchBrowseSetsUserLesson;
@property (strong, nonatomic) IBOutlet UISwitch *switchResetCourses;
@property (strong, nonatomic) IBOutlet UISlider *sliderMenuImageMaxScrollOffset;
@property (strong, nonatomic) IBOutlet UILabel *labelMaxScrollOffset;
@property (strong, nonatomic) IBOutlet UISlider *sliderMenuImageScrollSpeed;
@property (strong, nonatomic) IBOutlet UILabel *labelMenuImageScrollSpeed;
@property (strong, nonatomic) IBOutlet UISlider *sliderMatpicDelay;
@property (strong, nonatomic) IBOutlet UILabel *labelMatpicDuration;

@property (strong, nonatomic) IBOutlet UISwitch *switchShowOnboarding;

@property (strong, nonatomic) IBOutlet UILabel *labelSubscriptionCheckInterval;
@property (strong, nonatomic) IBOutlet UISlider *sliderSubscriptionCheckIntervall;
@property (strong, nonatomic) IBOutlet UISwitch *switchSubscriptionsEnabled;

@property (strong, nonatomic) IBOutlet UISwitch *switchSimulateError;

- (IBAction)actionSkipToScoreScreen:(id)sender;
- (IBAction)actionBrowseSetsUserLesson:(id)sender;
- (IBAction)actionResetCourses:(id)sender;
- (IBAction)actionMenuImageMaxScrollOffset:(id)sender;
- (IBAction) actionMenuImageScrollSpeed:(id) sender;
- (IBAction)actionMatpicDelay:(id)sender;
- (IBAction)actionShowOnboarding:(id)sender;
- (IBAction)actionSubscriptionCheckInterval:(id)sender;
- (IBAction)actionSubscriptionsEnabled:(id)sender;
- (IBAction)actionSwitchSimulateError:(id)sender;
@end
