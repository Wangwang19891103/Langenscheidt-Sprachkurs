//
//  UniParserNode.h
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 27.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniParserGrammarTree.h"



typedef enum {

    UniParserNodeReturnStateUndefined,
    UniParserNodeReturnStateSuccess,
    UniParserNodeReturnStateNotFound,
    UniParserNodeReturnStateIncomplete,
    UniParserNodeReturnStateWildcard

} UniParserNodeReturnState;


@interface UniParserNode : NSObject

@property (nonatomic, assign) UniParserNode* parentNode;
@property (nonatomic, strong) NSMutableArray* childNodes;
@property (nonatomic, assign) int currentChildIndex;
@property (nonatomic, weak) UniParserGrammarTreeNode* grammarNode;
@property (nonatomic, assign) uint scanLocation;
@property (nonatomic, assign) uint ambiguityLevel;
@property (nonatomic, copy) NSString* capturedString;
@property (nonatomic, assign) UniParserNodeReturnState returnState;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL wildcardActive;

// debug
@property (nonatomic, assign) uint depth;

// set vars
@property (nonatomic, strong) NSMutableDictionary* setVars;

// capture vars
@property (nonatomic, strong) NSMutableDictionary* captureVars;

+ (NSString*) stringForNodeType:(UniParserNode*) node;

@end
