//
//  GeneralSettingsViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "GeneralSettingsViewController.h"
#import "GeneralSettingsCell.h"
#import "UserProgressManager.h"
#import "AppVersionCell.h"
#import "SettingsManager.h"
#import "AnalyticsCell.h"
#import "GAI.h"
#import "LTracker.h"


@implementation GeneralSettingsViewController


#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];

    
    GATrackingSetScreenName(@"Einstellungen - Allgemein");
    GATrackingSetTrackScreenViews(YES);

    
    
    self.navigationItem.title = @"Allgemein";
    self.tableView.alwaysBounceVertical = NO;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}





#pragma mark - UITableViewDelegate / UITableViewDatasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height;
    
    switch (indexPath.row) {
            
        case 0:
            height = 61;
            break;
            
        case 1:
            height = 155;
            break;
            
        case 2:
            height = 121;
            break;
            
        default:
            break;
    }
    
    return height;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.row) {
            
        case 0: {
            AppVersionCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AppVersionCell"];
            
            cell.versionLabel.text = [self _appVersion];
            
            return cell;
        }
            break;
            
            
        case 1: {
            AnalyticsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"AnalyticsCell"];
            cell.activated = [self _analyticsActivated];
            
            __weak GeneralSettingsViewController* weakself = self;
            
            cell.buttonBlock = ^(BOOL active) {
                
                [weakself _setAnalytics:active];
            };
            
            return cell;
        }
            break;

            
        case 2: {
            GeneralSettingsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell3"];

            __weak UIViewController* weakController = self;
            
            cell.resetDataBlock = ^void() {
                
                [[UserProgressManager instance] resetUserDataWithParentViewController:weakController];
            };

            return cell;
        }
            break;
            
            
        default:
            break;
    }

    
    return nil;
}




#pragma mark - App Version

- (NSString*) _appVersion {
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* bundleVersion = infoDict[@"CFBundleShortVersionString"];
    
    return bundleVersion;
}




#pragma mark - Google Analytics

- (BOOL) _analyticsActivated {
    
    BOOL analyticsActivated = [[[SettingsManager instanceNamed:@"general"] valueForKey:@"analyticsActivated"] boolValue];

    return analyticsActivated;
}


- (void) _setAnalytics:(BOOL) activated {
    
    [[SettingsManager instanceNamed:@"general"] setValue:@(activated) forKey:@"analyticsActivated"];
    
    BOOL analyticsActivated = [[[SettingsManager instanceNamed:@"general"] valueForKey:@"analyticsActivated"] boolValue];
    
    NSLog(@"analytics: %d", analyticsActivated);
    
    
    NSLog(@"setting GA opt-out to: %d", !activated);

    [[GAI sharedInstance] setOptOut:!activated];

}









@end
