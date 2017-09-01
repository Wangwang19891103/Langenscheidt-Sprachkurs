//
//  NSDictionary+Extensions.m
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 11.04.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import "NSDictionary+Extensions.h"
#import "NSArray+Extensions.h"


@implementation NSDictionary (Extensions)


- (uint) deepCount {

    uint count = 0;
    
    for (id obj in self.allValues) {
        
        if ([obj isKindOfClass:[NSArray class]]) {
            
            count += [(NSArray*)obj deepCount];
        }
        else if ([obj isKindOfClass:[NSDictionary class]]) {
            
            count += [(NSDictionary*)obj deepCount];
        }
        else ++count;
    }
    
    return count;
}


@end
