//
//  UniParserNode.m
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 27.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import "UniParserNode.h"

@implementation UniParserNode

@synthesize parentNode;
@synthesize childNodes;
@synthesize currentChildIndex;
@synthesize grammarNode;
@synthesize scanLocation;
@synthesize ambiguityLevel;
@synthesize capturedString;
@synthesize returnState;
@synthesize depth;
@synthesize finished;
@synthesize visited;
@synthesize wildcardActive;
@synthesize setVars;
@synthesize captureVars;

//static uint __count = 0;


- (id) init {
    
    
//    ++__count;
    
    self = [super init];
    
    childNodes = [NSMutableArray array];
    capturedString = nil;
    currentChildIndex = 0;
    returnState = UniParserNodeReturnStateUndefined;
    depth = 0;
    finished = NO;
    visited = NO;
    wildcardActive = NO;
    setVars = [NSMutableDictionary dictionary];
    captureVars = [NSMutableDictionary dictionary];
    
    return self;
}


- (NSString*) description {

    return [NSString stringWithFormat:@"%@ (%@)", [UniParserNode stringForNodeType:self], self.grammarNode];
}


+ (NSString*) stringForNodeType:(UniParserNode*) node {
    
    switch (node.grammarNode.type) {
            
        case UniParserGrammarTreeNodeTypeProduction:
            return @"Production";
            break;

        case UniParserGrammarTreeNodeTypeExpressionList:
            return @"ExpressionList";
            break;
            
        case UniParserGrammarTreeNodeTypeTerminal:
            return @"Terminal";
            break;
            
        case UniParserGrammarTreeNodeTypeNonterminal:
            return @"NonTerminal";
            break;
            
        case UniParserGrammarTreeNodeTypeGroup:
            return @"Group";
            break;
            
        case UniParserGrammarTreeNodeTypeOptionOne:
            return @"OptionOne";
            break;
            
        case UniParserGrammarTreeNodeTypeOptionMany:
            return @"OptionMany";
            break;

        case UniParserGrammarTreeNodeTypeWildcard:
            return @"Wildcard";
            break;
            
        case UniParserGrammarTreeNodeTypeNothing:
            return @"Nothing";
            break;

        case UniParserGrammarTreeNodeTypeConditional:
            return @"Conditional";
            break;

        case UniParserGrammarTreeNodeTypeFalse:
            return @"False";
            break;

        default:
            return @"<UNKNOWN>";
            break;
    }
}


- (void) dealloc {
    
//    --__count;
    
//    NSLog(@"UniParserNode -dealloc (%d instances)", __count);
}

@end
