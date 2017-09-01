//
//  NSArray+Extensions.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 16.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation NSArray (Extensions)

+ (NSArray*) randomizedArrayFromArray:(NSArray*) array {

    NSMutableArray* randomizedArray = [NSMutableArray array];
    
    for (int i = 0; i < [array count]; ++i) {
        [randomizedArray addObject:[array objectAtIndex:i]];
    }
    
    id temp;
    
    for (int i = 0; i < [randomizedArray count]; ++i) {
        
        int newIndex = arc4random() % [randomizedArray count];
        temp = [randomizedArray objectAtIndex:newIndex];
        [randomizedArray replaceObjectAtIndex:newIndex withObject:[randomizedArray objectAtIndex:i]];
        [randomizedArray replaceObjectAtIndex:i withObject:temp];
    }
        
    return randomizedArray;                                   
}

- (NSArray*) sortUsingNumberArray:(NSArray**) array ascending:(BOOL)ascending {
    
    if (self.count == 0) {
        NSLog(@"[sortUsingNumbersArray:ascending] Error: self array is empty");
        return nil;
    }
    else if ((*array).count == 0) {
        NSLog(@"[sortUsingNumbersArray:ascending] Error: number array is empty");
        return nil;
    }
    
    
//    NSLog(@"first item: %@", array);
    
    if ([self count] != [*array count]) {
        NSLog(@"NSArray error: sortUsingNumberArray, different array lenghts");
        return nil;
    }
    else if (![[*array objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
        NSLog(@"NSArray error: sortUsingNumberArray, sorting array does not contain NSNumber objects");
    }
    
    NSMutableArray* newArray = [*array mutableCopy];
    NSMutableArray* newArray2 = [NSMutableArray arrayWithArray:self];
    
//    for (int i = 0; i < [*array count]; ++i) {
//        NSLog(@"player: %@, score: %@", [[newArray2 objectAtIndex:i] name], [newArray objectAtIndex:i]);
//    }
    
    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSNumber* temp = [newArray objectAtIndex:i];
        id temp2 = [newArray2 objectAtIndex:i];
        int i2 = i;

//        NSLog(@"i = %d, temp = %@", i, temp);
        
        while (i2 >= 1 && [[newArray objectAtIndex:i2 - 1] intValue] > [temp intValue]) {
//            NSLog(@"...");
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            [newArray2 replaceObjectAtIndex:i2 withObject:[newArray2 objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
        [newArray2 replaceObjectAtIndex:i2 withObject:temp2];
    }
    
//    for (int i = 0; i < [*array count]; ++i) {
//        NSLog(@"player: %@, score: %@", [[newArray2 objectAtIndex:i] name], [newArray objectAtIndex:i]);
//    }
    
//    NSLog(@"array in sort method: %@", *array);
    
    NSArray* returnedArray = nil;
    
    switch (ascending) {
        
        case TRUE:
            *array = [[NSArray alloc] initWithArray:newArray copyItems:TRUE];        
            returnedArray =  newArray2;
            break;
            
        case FALSE:
            *array = [[NSArray alloc] initWithArray:[newArray reversedArray] copyItems:TRUE];
            returnedArray =  [newArray2 reversedArray];
            break;
            
        default:
            break;
    }

    return returnedArray;
}








- (NSArray*) sort2DimensionalArrayUsingNumberAtIndex:(int)sortIndex ascending:(BOOL)ascending {

    NSMutableArray* newArray = [self mutableCopy];
    
    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSArray* temp = [newArray objectAtIndex:i];
        int i2 = i;
        
        NSLog(@"i = %d, temp = %@", i, temp);
        
        while (i2 >= 1 && [[[newArray objectAtIndex:i2 - 1] objectAtIndex:sortIndex] intValue] > [[temp objectAtIndex:sortIndex] intValue]) {
            NSLog(@"...");
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
    }
    
    switch (ascending) {
        
        case TRUE:
            return newArray;
            break;
            
        case FALSE:
            return [newArray reversedArray];
            break;
            
        default:
            break;
    }
    
    return nil;  // dummy
}




- (NSArray*) reversedArray {    
    
    NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (int i = [self count] - 1; i >= 0; --i) {
        [newArray addObject:[self objectAtIndex:i]];
    }
    
    return newArray;
}


- (NSArray*) copyArrayExcludingObjectsFromArray:(NSArray *)array {
    
    NSMutableArray* newArray = [self mutableCopy];
    
    for (id object in array) {
        [newArray removeObject:object];
    }
    
    return newArray;
}


- (NSArray*) sortByLengthOfStringsAscending:(BOOL)ascending {
    
    if (![[self objectAtIndex:0] isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSMutableArray* stringLengths = [NSMutableArray arrayWithCapacity:[self count]];
    
    for (NSString* string in self) {
        
        [stringLengths addObject:[NSNumber numberWithInt:string.length]];
    }
    
    return [self sortUsingNumberArray:&stringLengths ascending:ascending];
}


// nicht geprüft!
- (BOOL) containsObject:(id)object inSubArrayAtIndex:(uint)subIndex {
    
    for (NSArray* array in self) {
        
        if ([array objectAtIndex:subIndex] == object) {
            
            return true;
        }
    }
    
    return false;
}


- (id) firstElement {
    
    return self.count > 0 ?  [self objectAtIndex:0] : nil;
}

// setzt voraus dass sich im eigenen array keine duplikate befinden
- (NSArray*) sortUsingOrderInArray:(NSArray *)array {

    NSMutableDictionary* orderDict = [NSMutableDictionary dictionary];
    
    int i = 0;
    for (id object in array) {
        [orderDict setObject:[NSNumber numberWithInt:i] forKey:object];
        ++i;
    }
    
    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    NSMutableArray* notFoundArray = [NSMutableArray array];
    
    for (id object in self) {
        if ([orderDict objectForKey:object]) {
            NSNumber* place = [orderDict objectForKey:object];
            [tempDict setObject:object forKey:place];
        }
        else {
            [notFoundArray addObject:object];
        }
    }
    
    NSMutableArray* returnArray = [NSMutableArray array];
    
    for (int j = 0; j < i; ++j) {
        id object = [tempDict objectForKey:[NSNumber numberWithInt:j]];
        if (object) {
            [returnArray addObject:object];
        }
    }
    
    return (NSArray*) returnArray;
}


- (NSArray*) sortUsingKeyInDictionary:(NSString *)key ascending:(BOOL)ascending {
    
    NSMutableArray* newArray = [self mutableCopy];

    // insertion sort
    
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSDictionary* temp = [newArray objectAtIndex:i];
        int i2 = i;
        
        while (i2 >= 1 && [[[newArray objectAtIndex:i2 - 1] objectForKey:key] intValue] > [[temp objectForKey:key] intValue]) {
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
    }
    
    if (ascending) return newArray;
    else return [newArray reversedArray];
}


/* supports types: NSArray, NSString, NSNumber and all Classes that perform to serializeToString */
- (NSString*) serializeToString {
    
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        
        if ([object respondsToSelector:@selector(serializeToString)]) {
            
            [resultArray addObject:[object serializeToString]];
        }
        else if ([object isKindOfClass:[NSString class]]) {
            
            [resultArray addObject:[NSString stringWithFormat:@"\"%@\"", (NSString*)object]];
        }
        else if ([object isKindOfClass:[NSNumber class]]) {
            
            [resultArray addObject:(NSNumber*)object];
        }
    }
    
    return [NSString stringWithFormat:@"[%@]", [resultArray componentsJoinedByString:@","]];
}


+ (NSArray*) arrayFromLettersInString:(NSString*) string {
    
    NSMutableArray* array = [NSMutableArray array];
    
    for (uint i = 0; i < string.length; ++i) {
        
        NSString* letter = [string substringWithRange:NSMakeRange(i, 1)];
        [array addObject:letter];
    }
    
    return array;
}


+ (NSArray*) arrayWithRangeOfIntegers:(NSRange) range {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:range.length];
    
    for (uint i = range.location; i < range.location + range.length; ++i) {
        
        [array addObject:@(i)];
    }
    
    return array;
}


- (NSArray*) arrayEliminatingEmptyStrings {
    
    NSMutableArray* newArray = [NSMutableArray array];
    
    for (id obj in self) {
        
        assert([obj isKindOfClass:[NSString class]]);
        
        if (((NSString*)obj).length > 0) {
            
            [newArray addObject:obj];
        }
    }
    
    return newArray;
}


- (NSArray*) sortAlphabetically {
    
    return [self sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


- (NSArray*) arrayWithObjectsInRange:(NSRange) range {
    
    NSMutableArray* newArray = [NSMutableArray array];
    
    for (uint i = range.location; i < range.location + range.length; ++i) {
        
        [newArray addObject:self[i]];
    }
    
    return newArray;
}


- (uint) deepCount {

    uint count = 0;
    
    for (id obj in self) {
        
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





@implementation NSMutableArray (Extensions)

- (void) removeFirstObjectMatchingString:(id)object {
    
//    NSMutableArray* newArray = [[NSMutableArray alloc] initWithArray:self copyItems:TRUE];
    
    NSLog(@"removeFirst");
    
    for (int i = 0; i < [self count]; ++i) {
        
        if ([[self objectAtIndex:i] isEqualToString:object]) {
            [self removeObjectAtIndex:i]; 
            NSLog(@"removing object: %@", object);
            break;
        }
    }
}

+ (id) createArrayWithWeakReferences {
    
    return [self createArrayWithWeakReferencesWithCapacity:0];
}





@end
