//
//  SettingsMenuViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "SettingsMenuViewController.h"
#import "SubscriptionManager.h"


#define ROW_RESTORE_PRODUCTS        4



@implementation SettingsMenuViewController

#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Einstellungen";
    self.tableView.alwaysBounceVertical = NO;
}



#pragma mark - UITableViewDelegate / UITableViewDatasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 6;
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

        case 5:
            identifier = @"Cell6";
            break;

        default:
            break;
    }
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    return cell;
}



- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == ROW_RESTORE_PRODUCTS) {
        
        [[SubscriptionManager instance] restoreProductsWithParentViewController:self];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}





#pragma mark - dealloc

- (void) dealloc {
    
    NSLog(@"SEttingsMenuViewController - dealloc");
    
    [[SubscriptionManager instance] removeRestoreHandler];
}


@end
