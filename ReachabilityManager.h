//
//  ReachabilityManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 31.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SingletonObject.h"
#import "Reachability.h"



@interface ReachabilityManager : NSObject


+ (instancetype)  instance;


- (BOOL) canConnectToInternet;

//- (BOOL) canConnectToHost:(NSString*) hostName;

@end
