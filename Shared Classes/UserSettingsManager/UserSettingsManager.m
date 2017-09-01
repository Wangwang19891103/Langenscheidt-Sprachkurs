//
//  UserSettingsManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UserSettingsManager.h"



#define INSTANCE_NAME               @"user"

#define NOT_FIRST_RUN_KEY           @"notFirstRun"



NSString* const kUserSettingsSendStatisticsData = @"sendStatisticsData";



@implementation UserSettingsManager


+ (instancetype) instance {
    
    return [UserSettingsManager instanceNamed:INSTANCE_NAME];
}


- (id) initWithName:(NSString *)name {
    
    self = [super initWithName:name];
    
    [self _setDefaultSettingsIfNeeded];
    
    return self;
}



#pragma mark - Keyed Subscripting

- (id)objectForKeyedSubscript:(id)key {
    
    return [self valueForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    
    [self setValue:obj forKey:key];
}



#pragma mark - Default Settings

- (void) _setDefaultSettingsIfNeeded {
    
    BOOL firstRun = ![self[NOT_FIRST_RUN_KEY] boolValue];
    
    if (firstRun) {
        
        self[NOT_FIRST_RUN_KEY] = @(YES);
        self[kUserSettingsSendStatisticsData] = @(YES);
    }
}


@end
