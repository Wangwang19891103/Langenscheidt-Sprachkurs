//
//  UniParserIter.h
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 27.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniParserGrammarTree.h"
#import "UniParserNode.h"
#import "UniParserDelegate.h"


typedef enum {
    
    UniParserModeValidateOnly,
    UniParserModeValidateAndCapture
    
} UniParserMode;


@interface UniParser : NSObject {
    
    UniParserGrammarTree* _grammarTree;
//    NSString* _contentString;
    NSScanner* _scanner;
    UniParserMode _mode;
    UniParserNode* _rootNode;
    UniParserNode* _currentNode;
    NSString* _currentToken;

    // capturing
    
    NSMutableArray* _capturedObjects;
    NSMutableArray* _capturedObjectStack;
    id _currentCaptureObject;
    NSMutableArray* _productionStack;
    NSMutableString* _totalString;
    BOOL _capturingValue;
    UniParserNode* _wildcardForCapturing;
    
    // error handling
    
    BOOL _isError;
    UniParserGrammarTreeNodeTerminal* _lastFailedTerminal;
    
    // debug
    
    uint _lastDirection;
    
    NSMutableArray* _errorZoneStack;
    
    UniParserNode* _errorZoneNode;
    uint _errorScanLocation;
}

@property (nonatomic, assign) id<UniParserDelegate> delegate;
@property (nonatomic, assign) BOOL loggingEnabled;
@property (nonatomic, readonly) BOOL hasError;


- (id) initWithGrammarString:(NSString*) grammarString;

- (BOOL) parseContentString:(NSString*) contentString withMode:(UniParserMode) mode;

- (BOOL) parseContentString:(NSString*) contentString withMode:(UniParserMode) mode production:(NSString*) productionName;

- (NSArray*) capturedObjects;

@end
