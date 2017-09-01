//
//  LogManager.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 03.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogManager.h"


@implementation LogManager

@synthesize name, contents;




+ (LogManager*) instanceNamed:(NSString *)name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
        
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
        
        if ([_instances objectForKey:name]) {
            
            return [_instances objectForKey:name];
        }
        else {
            
            LogManager* newManager = [[LogManager alloc] initWithName:name];
            [_instances setObject:newManager forKey:name];
            return newManager;
        }
        
    }
}



- (id) initWithName:(NSString *)theName {
    
    if (self = [super init]) {
        
        self.name = theName;
        self.contents = [NSMutableString string];
    }
    
    return self;
}


- (void) appendStringToLog:(NSString *)string {
    
    [self.contents appendString:string];
    [self.contents appendString:@"\n"];
}


- (void) writeLogToFile {
    
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [pathArray lastObject];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"__LOG__%@.txt", self.name]];
    
    NSLog(@"writing to file: %@", filePath);
    
    [self.contents writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
}


- (void) writeLogToFile:(NSString *)fileName {
    
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [pathArray lastObject];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSLog(@"writing to file: %@", filePath);
    
    [self.contents writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
}

- (void) purge {
    
    self.contents = [NSMutableString string];
}


@end
