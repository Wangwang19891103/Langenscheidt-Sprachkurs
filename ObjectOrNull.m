//
//  ObjectOrNil.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 06.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ObjectOrNull.h"


id ObjectOrNull(id object) {
    
    return object ?: [NSNull null];
}
