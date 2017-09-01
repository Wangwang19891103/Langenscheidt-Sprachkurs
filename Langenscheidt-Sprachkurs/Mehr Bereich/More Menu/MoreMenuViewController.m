//
//  MoreMenuViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "MoreMenuViewController.h"
#import "DevMoreViewController.h"
#import "LTracker.h"



#define DEV_SETTINGS   // also in app delegate




@implementation MoreMenuViewController



#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Mehr-Bereich-Menü");
    GATrackingSetTrackScreenViews(YES);
    
    
    self.navigationItem.title = @"Mehr";
    self.tableView.alwaysBounceVertical = NO;
}



#pragma mark - UITableViewDelegate / UITableViewDatasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
#ifdef DEV_SETTINGS
    
    return 5;
    
#else
    
    return 4;
    
#endif
    
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString* identifier = nil;
    
    switch (indexPath.row) {
            
        case 0:
            identifier = @"Cell1";
            break;

        case 1:
            identifier = @"Cell2";
            break;

        case 2:
            identifier = @"Cell3";
            break;

        case 3:
            identifier = @"Cell4";
            break;

        case 4:
            identifier = @"Cell5";
            break;

        default:
            break;
    }

    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        
        [self _handleInviteFriends];
        
    }
    
    if (indexPath.row == 4) {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        UIViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"Dev More"];

        [self.navigationController pushViewController:controller animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}




#pragma mark - Invite Friends

- (void) _handleInviteFriends {
    
    _inviteHandler = [[InviteFriendsHandler alloc] init];
    [_inviteHandler openWithParentViewController:self];
}

@end
