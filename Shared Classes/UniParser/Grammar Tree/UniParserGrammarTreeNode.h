//
//  UniParserGrammarTreeNode.h
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 22.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {

    UniParserGrammarTreeNodeTypeProduction,
    UniParserGrammarTreeNodeTypeExpressionList,
    UniParserGrammarTreeNodeTypeTerminal,
    UniParserGrammarTreeNodeTypeNonterminal,
    UniParserGrammarTreeNodeTypeGroup,
    UniParserGrammarTreeNodeTypeOptionOne,
    UniParserGrammarTreeNodeTypeOptionMany,
    UniParserGrammarTreeNodeTypeWildcard,
    UniParserGrammarTreeNodeTypeNothing,
    UniParserGrammarTreeNodeTypeConditional,
    UniParserGrammarTreeNodeTypeFalse
    
} UniParserGrammarTreeNodeType;


typedef enum {

    UniParserGrammarTreeNodeExpressionListTypeConcat,
    UniParserGrammarTreeNodeExpressionListTypeAlternatives
    
} UniParserGrammarTreeNodeExpressionListType;


typedef enum {

    UniParserGrammarTreeNodeCaptureTypeNone,
    UniParserGrammarTreeNodeCaptureTypeArray,
    UniParserGrammarTreeNodeCaptureTypeDictionary,
    UniParserGrammarTreeNodeCaptureTypeValue
    
} UniParserGrammarTreeNodeCaptureType;


#pragma mark - Forward declarations

@class UniParserGrammarTreeNode;
@class UniParserGrammarTreeNodeProduction;
@class UniParserGrammarTreeNodeExpressionList;
@class UniParserGrammarTreeNodeTerminal;
@class UniParserGrammarTreeNodeNonterminal;
@class UniParserGrammarTreeNodeGroup;
@class UniParserGrammarTreeNodeOptionOne;
@class UniParserGrammarTreeNodeOptionMany;
@class UniParserGrammarTreeNodeWildcard;
@class UniParserGrammarTreeNodeNothing;
@class UniParserGrammarTreeNodeConditional;



#pragma mark - Node (abstract)

@interface UniParserGrammarTreeNode : NSObject

@property (nonatomic, readonly) UniParserGrammarTreeNodeType type;
@property (nonatomic, assign) UniParserGrammarTreeNodeCaptureType captureType;
@property (nonatomic, copy) NSString* captureKey;
@property (nonatomic, strong) NSMutableArray* functions;
@property (nonatomic, assign) BOOL newErrorZone;

- (id) initWithType:(UniParserGrammarTreeNodeType) type;
- (NSString*) description2;

- (void) addFunction:(NSString*) functionString;

@end



#pragma mark - Production

@interface UniParserGrammarTreeNodeProduction : UniParserGrammarTreeNode

@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) UniParserGrammarTreeNode* expressionNode;

@end



#pragma mark - ExpressionList

@interface UniParserGrammarTreeNodeExpressionList : UniParserGrammarTreeNode

@property (nonatomic, assign) UniParserGrammarTreeNodeExpressionListType expressionListType;
@property (nonatomic, strong) UniParserGrammarTreeNode* node1;
@property (nonatomic, strong) UniParserGrammarTreeNode* node2;

@end



#pragma mark - Terminal

@interface UniParserGrammarTreeNodeTerminal : UniParserGrammarTreeNode

@property (nonatomic, copy) NSString* string;
@property (nonatomic, copy) NSCharacterSet* characterSet;
@property (nonatomic, copy) NSString* characterSetDescription;

@end



#pragma mark - Nonterminal

@interface UniParserGrammarTreeNodeNonterminal : UniParserGrammarTreeNode

@property (nonatomic, copy) NSString* nameRef;

@end



#pragma mark - Group

@interface UniParserGrammarTreeNodeGroup : UniParserGrammarTreeNode

@property (nonatomic, strong) UniParserGrammarTreeNode* expressionNode;

@end



#pragma mark - OptionOne

@interface UniParserGrammarTreeNodeOptionOne : UniParserGrammarTreeNode

@property (nonatomic, strong) UniParserGrammarTreeNode* expressionNode;

@end



#pragma mark - OptionMany

@interface UniParserGrammarTreeNodeOptionMany : UniParserGrammarTreeNode

@property (nonatomic, strong) UniParserGrammarTreeNode* expressionNode;
@property (nonatomic, assign) uint count;

@end



#pragma mark - Wildcard

@interface UniParserGrammarTreeNodeWildcard : UniParserGrammarTreeNode

@end



#pragma mark - Nothing

@interface UniParserGrammarTreeNodeNothing : UniParserGrammarTreeNode

@end



#pragma mark - Conditional

@interface UniParserGrammarTreeNodeConditional : UniParserGrammarTreeNode

@property (nonatomic, strong) UniParserGrammarTreeNode* nodeTrue;
@property (nonatomic, strong) UniParserGrammarTreeNode* nodeFalse;

@end



#pragma mark - Conditional

@interface UniParserGrammarTreeNodeFalse : UniParserGrammarTreeNode

@end