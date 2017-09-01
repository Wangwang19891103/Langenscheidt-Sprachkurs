//
//  UniParserGrammarTreeNode.m
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 22.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import "UniParserGrammarTreeNode.h"


#define TRUNCATE_MAX_LENGTH                 40


@implementation UniParserGrammarTreeNode

@synthesize type;
@synthesize captureType;
@synthesize functions;
@synthesize newErrorZone;

- (id) initWithType:(UniParserGrammarTreeNodeType)p_type {
    
    self = [super init];

    type = p_type;
    captureType = UniParserGrammarTreeNodeCaptureTypeNone;
    functions = [NSMutableArray array];
    
    return self;
}

- (void) addFunction:(NSString*) functionString {
    
    [self.functions addObject:functionString];
}

- (NSString*) description {
    
    NSString* superString = [self _truncateIfNeeded:[self description2]];
    
    return [NSString stringWithFormat:@"%@%@", [self stringForCaptureType:self.captureType], superString];
}

- (NSString*) stringForCaptureType:(UniParserGrammarTreeNodeCaptureType) le_captureType {
    
    switch (le_captureType) {
        case UniParserGrammarTreeNodeCaptureTypeNone:
            return @"";
            break;
            
        case UniParserGrammarTreeNodeCaptureTypeArray:
            return @"#";
            break;
            
        case UniParserGrammarTreeNodeCaptureTypeDictionary:
            return @"@";
            break;

        case UniParserGrammarTreeNodeCaptureTypeValue:
            return @"$";
            break;

        default:
            break;
    }
}


- (NSString*) _truncateIfNeeded:(NSString*) string {

    if (string.length > 40) {
    
        return [NSString stringWithFormat:@"%@ ...", [string substringWithRange:NSMakeRange(0, TRUNCATE_MAX_LENGTH)]];
    }
    else {
    
        return string;
    }
}

@end




@implementation UniParserGrammarTreeNodeProduction

@synthesize name;
@synthesize expressionNode;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeProduction];
    
    return self;
}

- (NSString*) description2 {
    
    return [NSString stringWithFormat:@"%@ = %@ ;", name, expressionNode];
}



@end




@implementation UniParserGrammarTreeNodeExpressionList

@synthesize expressionListType;
@synthesize node1;
@synthesize node2;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeExpressionList];
    
    return self;
}

- (NSString*) description2 {
    
    if (expressionListType == UniParserGrammarTreeNodeExpressionListTypeConcat) {
        
        return [NSString stringWithFormat:@"%@ , %@", node1, node2];
    }
    else {
        
        return [NSString stringWithFormat:@"%@ | %@", node1, node2];
    }
}

@end




@implementation UniParserGrammarTreeNodeTerminal

@synthesize string;
@synthesize characterSet;
@synthesize characterSetDescription;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeTerminal];
    
    return self;
}

- (NSString*) description2 {

    if (string) {
        
        return [NSString stringWithFormat:@"\"%@\"", string];
    }
    else if (characterSet) {
        
        return [NSString stringWithFormat:@"<character set:%@>", characterSetDescription];
    }
    else {
        
        return @"<EMPTY>";
    }
}

@end




@implementation UniParserGrammarTreeNodeNonterminal

@synthesize nameRef;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeNonterminal];

    return self;
}

- (NSString*) description2 {

    return nameRef;
}

@end




@implementation UniParserGrammarTreeNodeGroup

@synthesize expressionNode;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeGroup];
    
    return self;
}

- (NSString*) description2 {
    
    return [NSString stringWithFormat:@"( %@ )", expressionNode];
}

@end




@implementation UniParserGrammarTreeNodeOptionOne

@synthesize expressionNode;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeOptionOne];
    
    return self;
}

- (NSString*) description2 {
    
    return [NSString stringWithFormat:@"[ %@ ]", expressionNode];
}

@end




@implementation UniParserGrammarTreeNodeOptionMany

@synthesize expressionNode;
@synthesize count;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeOptionMany];
    
    count = 0;
    
    return self;
}

- (NSString*) description2 {
    
    if (count > 0) {
        
        return [NSString stringWithFormat:@"{ %@ }(%d)", expressionNode, count];
    }
    else {
    
        return [NSString stringWithFormat:@"{ %@ }", expressionNode];
    }
}

@end




@implementation UniParserGrammarTreeNodeWildcard

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeWildcard];
    
    return self;
}

- (NSString*) description2 {
    
    return @"*";
}

@end




@implementation UniParserGrammarTreeNodeNothing

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeNothing];
    
    return self;
}

- (NSString*) description2 {
    
    return @"<nothing>";
}

@end



@implementation UniParserGrammarTreeNodeConditional

@synthesize nodeTrue;
@synthesize nodeFalse;

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeConditional];
    
    return self;
}

- (NSString*) description2 {
    
    return [NSString stringWithFormat:@"%@ -OR- %@", nodeTrue, nodeFalse];
}

@end



@implementation UniParserGrammarTreeNodeFalse

- (id) init {
    
    self = [super initWithType:UniParserGrammarTreeNodeTypeFalse];
    
    return self;
}

- (NSString*) description2 {
    
    return @"<false>";
}

@end
