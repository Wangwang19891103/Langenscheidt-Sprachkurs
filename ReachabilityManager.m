//
//  ReachabilityManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 31.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ReachabilityManager.h"

@implementation ReachabilityManager


#pragma mark - Init

+ (instancetype)  instance {
    
    static id __instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __instance = [[self alloc] init];
    });
    
    return __instance;
}


#pragma mark - Reachability

- (BOOL) canConnectToInternet {
    
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus status = reachability.currentReachabilityStatus;
    
    return status != NotReachable;
}


//- (BOOL) canConnectToHost:(NSString*) hostName {
//    
//    Reachability* reachability = [Reachability reachabilityWithHostName:hostName];
//    
//    NetworkStatus status = reachability.currentReachabilityStatus;
//    
//    return status != NotReachable;
//}



@end
