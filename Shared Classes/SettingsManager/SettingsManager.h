//
//  SettingsManager.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 19.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsManager : NSObject {
    
    NSUserDefaults* _userDefaults;
    
    NSMutableDictionary* _userDict;
    
    NSString* _name;
}

- (id) initWithName:(NSString*) name;



+ (instancetype) instanceNamed:(NSString*) name;


@end
