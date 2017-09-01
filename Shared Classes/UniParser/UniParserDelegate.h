//
//  UniParserDelegate.h
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 30.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#ifndef StueStandardLibrary_UniParserDelegate_h
#define StueStandardLibrary_UniParserDelegate_h


@class UniParser;


@protocol UniParserDelegate <NSObject>

- (void) parser:(UniParser*) parser didCaptureObject:(id) object withKey:(NSString*) key;

@end


#endif
