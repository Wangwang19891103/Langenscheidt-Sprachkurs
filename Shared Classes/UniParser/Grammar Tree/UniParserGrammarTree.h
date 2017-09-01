//
//  UniParserGrammarTree.h
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 21.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniParserGrammarTreeNode.h"


@interface UniParserGrammarTree : NSObject {
    
    NSScanner* _scanner;
    NSCharacterSet* _whitespaceSet;
    NSCharacterSet* _alphanumericSet;
    NSCharacterSet* _newlineSet;
    NSCharacterSet* _identifierSet;
    NSString* _currentToken;
    NSMutableArray* _scanLocationStack;
    NSMutableDictionary* _productionDict;
    NSMutableArray* _referencedNonterminals;
}

@property (nonatomic, strong) NSMutableDictionary* settings;

- (id) initWithString:(NSString*) string;

- (UniParserGrammarTreeNodeProduction*) mainProduction;
- (UniParserGrammarTreeNodeProduction*) productionWithName:(NSString*) productionName;
- (BOOL) hasProductionNamed:(NSString*) productionName;

@end



