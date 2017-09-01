//
//  LogManager.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 03.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>




#define LogM(name, ...) [[LogManager instanceNamed:name] appendStringToLog:[NSString stringWithFormat:__VA_ARGS__]]

#define LogM_write(name) [[LogManager instanceNamed:name] writeLogToFile]

#define LogM_write2(name, filename) [[LogManager instanceNamed:name] writeLogToFile:filename]

#define LogM_purge(name) [[LogManager instanceNamed:name] purge];









@interface LogManager : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) NSMutableString* contents;


+ (LogManager*) instanceNamed:(NSString*) name;

- (id) initWithName:(NSString*) theName;

- (void) appendStringToLog:(NSString*) string;

- (void) writeLogToFile;

- (void) writeLogToFile:(NSString*) fileName;

- (void) purge;

@end
