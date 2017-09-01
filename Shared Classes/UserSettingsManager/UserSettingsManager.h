//
//  UserSettingsManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"


extern NSString* const kUserSettingsSendStatisticsData;


@interface UserSettingsManager : SettingsManager


+ (instancetype) instance;


- (id)objectForKeyedSubscript:(id)key;

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
