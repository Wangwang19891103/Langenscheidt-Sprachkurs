//
//  DevMoreViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DevMoreViewController.h"
#import "ClusterEventViewController.h"
#import "SoundListViewController.h"


@implementation DevMoreViewController


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Mehr";
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* identifier = nil;
    
    switch (indexPath.row) {
        
        case 0:
            identifier = @"EventsCell";
            break;
            
        case 1:
            identifier = @"DevSettingsCell";
            break;

        case 2:
            identifier = @"SoundListCell";
            break;

        default:
            break;
    }
    
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UIViewController* controller = nil;
    
    switch (indexPath.row) {
            
        case 0:
        {
            controller = [[ClusterEventViewController alloc] init];
        }
            break;
            
        case 1:
        {
            controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Dev Settings"];
        }
            break;


        default:
            break;
    }

    [self.navigationController pushViewController:controller animated:YES];

}

@end
