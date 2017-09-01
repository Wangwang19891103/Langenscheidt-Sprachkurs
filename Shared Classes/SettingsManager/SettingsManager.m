//
//  SettingsManager.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 19.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsManager.h"



//#define DEFAULTS_FILE           @"defaultUserSettings"
//#define DICTIONARY_KEY          @"UserSettings"



@implementation SettingsManager




- (id) initWithName:(NSString*) name {
    
    if ((self = [super init])) {
        
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        _userDict = [NSMutableDictionary dictionaryWithDictionary:[_userDefaults dictionaryForKey:name]];
        
        _name = [name copy];
        
        if (_userDict.allKeys.count == 0) {
            
//            NSLog(@"creating user dictionary");
            
            _userDict = [NSMutableDictionary dictionaryWithDictionary:[self defaultSettings]];
            
            [self saveSettings];
        }
        
        [self print];
    }
    
    return self;
}


+ (instancetype) instanceNamed:(NSString *)name {
    
    static NSMutableDictionary* __instances = nil;
    
    @synchronized(self) {
        
        if (!__instances) {
            
            __instances = [NSMutableDictionary dictionary];
            
        }
        
        if (!__instances[name]) {
            
            id newInstance = [[self new] initWithName:name];
            [__instances setObject:newInstance forKey:name];
        }
    }
    
    return __instances[name];
}


- (void) saveSettings {
    
    [_userDefaults setObject:_userDict forKey:_name];
    [_userDefaults synchronize];
    
    [self print];
}


- (id) valueForUndefinedKey:(NSString *)key {
    
//    if ([_userDict.allKeys containsObject:key]) {
    
        return _userDict[key];
//    }
//    else {
//        
//        return [super valueForUndefinedKey:key];
//    }
}


- (void) setValue:(id)value forUndefinedKey:(NSString *)key {
    
//    if ([_userDict.allKeys containsObject:key]) {
    
        [_userDict setValue:value forKey:key];
        [self saveSettings];
//    }
//    else {
//        
//        [super setValue:value forUndefinedKey:key];
//    }
}


- (NSDictionary*) defaultSettings {
    
    NSString* defaultsPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_default", _name] ofType:@"plist"];
    
    if (defaultsPath) {

        return [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    }
    else {
        
        return [NSDictionary dictionary];
    }
}


- (void) print {
    
//    NSLog(@"--------- USER SETTINGS ---------");
    
    for (NSString* key in _userDict.allKeys) {
        
//        NSLog(@"%@ = %@", key, _userDict[key]);
    }

//    NSLog(@"---------------------------------");
}






@end
