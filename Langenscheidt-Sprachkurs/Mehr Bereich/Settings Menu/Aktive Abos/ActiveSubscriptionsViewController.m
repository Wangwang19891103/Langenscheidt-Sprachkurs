//
//  ActiveSubscriptionsViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ActiveSubscriptionsViewController.h"
#import "ActiveSubscriptionCell.h"
#import "ErrorMessageManager.h"
#import "LTracker.h"


@implementation ActiveSubscriptionsViewController


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [[SubscriptionManager instance] addObserver:self];
    
    return self;
}


#pragma mark - UIViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];

    
    GATrackingSetScreenName(@"Einstellungen - Aktive Abos");
    GATrackingSetTrackScreenViews(YES);

    
    
    self.navigationItem.title = @"Aktive Abos";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(_getActiveSubInfo)
                  forControlEvents:UIControlEventValueChanged];
    
    [self _reset];

}


- (void) viewDidAppear:(BOOL)animated {
    
    NSLog(@"ActiveSubscriptionsViewController - viewDidAppear");
    
    _shouldHandleEvents = YES;
    
    NSLog(@"ActiveSubscriptionsViewController - shouldHandleEvents = %d", _shouldHandleEvents);
    
    
    [super viewDidAppear:animated];
    
    
    [self _getActiveSubInfo];
}


- (void) viewWillDisappear:(BOOL)animated {
    
    NSLog(@"ActiveSubscriptionsViewController - viewDidAppear");
    
    _shouldHandleEvents = NO;
    
    NSLog(@"ActiveSubscriptionsViewController - shouldHandleEvents = %d", _shouldHandleEvents);
    
    
    [super viewWillDisappear:animated];
}




#pragma mark - Reset

- (void) _reset {  // reset between update requests
    
    _loading = YES;
    _hasError = NO;
}



#pragma mark - Active Sub Info

- (void) _getActiveSubInfo {  // sends request to SubManager

    [self _reset];
    
    [[SubscriptionManager instance] requestUpdateHasActiveSubscriptionForceValidation:YES];
    
    [self.tableView reloadData];
}


- (void) _updateSubscriptionInfo {  // updates tableview with information requested to update

    NSLog(@"updateSubscriptionInfo");
    
    
    _loading = NO;
    
    _hasActiveSubscription = [[SubscriptionManager instance] hasActiveSubscription];
    _productID = nil;
    _expirationDate = nil;
    
    if (_hasActiveSubscription) {
        
        _productID = [self _titleForProductID:[[SubscriptionManager instance] activeProductIdentifier]];
        _expirationDate = [self _stringForDate:[[SubscriptionManager instance] currentExpirationDate]];
    }
    
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}


- (NSString*) _titleForProductID:(NSString*) productID {
    
    return [[SubscriptionManager instance] longTitleForProductID:productID];
}


- (NSString*) _stringForDate:(NSDate*) date {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"];
    formatter.dateFormat = @"dd'.'MM'.'yyyy '-' HH':'mm'";
    formatter.locale = [NSLocale currentLocale];
    
    return [formatter stringFromDate:date];
}




#pragma mark - UITableViewDelegate/datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_loading) {
        
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        
        return cell;
    }
    else if (_hasError) {
        
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ErrorCell"];
        
        return cell;
    }
    else if (_hasActiveSubscription) {
        
        ActiveSubscriptionCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ActiveSubCell"];
        
        cell.titleLabel.text = _productID;
        cell.expiresLabel.text = [NSString stringWithFormat:@"Gültig bis %@", _expirationDate];
        
        return cell;
    }
    else {
        
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoSubsCell"];
        
        return cell;
    }
}







#pragma mark - SubscriptionManagerDelegate

- (BOOL) shouldHandleSubscriptionManagerEvents {
    
    return _shouldHandleEvents;
}


- (void) subscriptionManagerDidUpdateSubscriptionStatusValidating:(BOOL)validating {
    
    __weak ActiveSubscriptionsViewController* weakself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"ActiveSubscriptionViewController - subscriptionManagerDidUpdateSubscriptionStatusValidating (validating: %d)", validating);
        
        
        if (!validating) {  // if not doing full update -> update UI immediately, otherwise wait for next call
            
            [weakself _updateSubscriptionInfo];
        }
    });
    
}


- (void) subscriptionManagerDidReportError:(NSError *)error {

    __weak ActiveSubscriptionsViewController* weakself = self;

    _hasError = YES;
    _loading = NO;
    
    [[ErrorMessageManager instance] handleError:error withParentViewController:self completionBlock:^{
        
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"reload tableview");
        
        [weakself.tableView reloadData];
        [weakself.refreshControl endRefreshing];
    });
}




#pragma mark - Dealloc 

- (void) dealloc {
    
    [[SubscriptionManager instance] removeObserver:self];
}



@end
