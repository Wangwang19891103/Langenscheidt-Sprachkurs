//
//  UniParserIter.m
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 27.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import "UniParser.h"
#import <UIKit/UIKit.h>


#define ERROR_REPORT_STRING_RADIUS              50

#define COLOR_ERROR                             [UIColor redColor]
#define COLOR_WARNING                           [UIColor orangeColor]


@implementation UniParser

@synthesize delegate;
@synthesize loggingEnabled;
@synthesize hasError;


- (id) initWithGrammarString:(NSString *)grammarString {
    
    self = [super init];
    
    if (!grammarString) {
        
        NSLog(@"UniParser: GrammarString must not be nil.");
        return nil;
    }
    
    _grammarTree = [[UniParserGrammarTree alloc] initWithString:grammarString];
//    _contentString = [contentString copy];
    
    return self;
}


- (BOOL) parseContentString:(NSString *)contentString withMode:(UniParserMode)mode {
    
    return [self parseContentString:contentString withMode:mode production:nil];
}


- (BOOL) parseContentString:(NSString*) contentString withMode:(UniParserMode) mode production:(NSString*) productionName {

    _mode = mode;
    _scanner = [[NSScanner alloc] initWithString:contentString];
    _currentNode = nil;
    
    [self _configureScanner];
    
    
    BOOL success = [self _parseBeginWithProduction:productionName scanLocation:0];
    
    if (!success && _errorZoneNode) {

        NSLog(@"Tracking error around scan location %d --> %@", _errorScanLocation, [self _parserStringForRange:NSMakeRange(_errorScanLocation - 2, 1) radius:200]);
        
        self.loggingEnabled = YES;
        UniParserGrammarTreeNodeProduction* productionNode = (UniParserGrammarTreeNodeProduction*)_errorZoneNode.grammarNode;
        [self _parseBeginWithProduction:productionNode.name scanLocation:_errorScanLocation];
    }
    
    else if (_mode == UniParserModeValidateAndCapture) {
        
        [self _capture];
    }
    
    return success;
}


- (void) _configureScanner {
    
    if ([_grammarTree.settings[@"ignore_newline"]boolValue]) {
        
        _scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    }
    else {
        
        _scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
    }
    
    if ([_grammarTree.settings[@"case_sensitive"]boolValue]) {
        
        _scanner.caseSensitive = YES;
    }
    else {
        
        _scanner.caseSensitive = NO;
    }
    
}




#pragma mark - Parsing

- (BOOL) _parseBeginWithProduction:(NSString*) productionName scanLocation:(uint) scanLocation {
    
    UniParserGrammarTreeNodeProduction* production = nil;
    
    if (!productionName) {

        production = [_grammarTree mainProduction];
    }
    else {
        
        production = [_grammarTree productionWithName:productionName];
    }
    
    _rootNode = [[UniParserNode alloc] init];
    _rootNode.grammarNode = production;
    _rootNode.scanLocation = scanLocation;
    _rootNode.ambiguityLevel = 0;
    _isError = NO;
    
    _currentNode = _rootNode;
    
    _errorZoneStack = [NSMutableArray array];
    
    [self _addErrorZone:_currentNode];
    
    // main loop
    
    do {
        
        [self _parseCurrentNode];
        
        NSMutableArray* a1 = [NSMutableArray array];
        for (uint i = 0; i < _currentNode.depth; ++i) {
            [a1 addObject:@"|"];
        }
        NSString* s1 = [a1 componentsJoinedByString:@""];
        
        [self _log:@"%0.2d %@ %@ - %@ (sl:%d, al:%d, ret:%@)%@",
                         _currentNode.depth,
                         s1,
                         (_lastDirection == 1) ? @"DOWN" : (_lastDirection == -1) ? @"UP  " : @"xxx",
                         _currentNode,
                         _currentNode.scanLocation,
                         _currentNode.ambiguityLevel,
                         ((_currentNode.returnState == UniParserNodeReturnStateUndefined) ? @"undefined" :
                          (_currentNode.returnState == UniParserNodeReturnStateSuccess) ? @"success" :
                          (_currentNode.returnState == UniParserNodeReturnStateNotFound) ? @"not found" : @"incomplete"),
              (_currentNode.capturedString.length != 0) ? [NSString stringWithFormat:@"    \"%@\"", _currentNode.capturedString] : @""];
        
        [self _nextNode];
        
    } while (!_isError && _currentNode);
    
    
    
    BOOL success = (_rootNode.returnState == UniParserNodeReturnStateSuccess);
    
    if (![_scanner isAtEnd]) {
        
        [self _errorAsWarning:NO message:@"Parse error. End of main production without end of string."];
        
        success = NO;
    }
    
//    NSLog(@"captured string: %@", [self _capturedString]);
    
//    NSLog(@"set vars: %@", _rootNode.setVars);
    
    return success;
}


- (void) _nextNode {
    
    // 1. next child node
    
    if (!_currentNode.finished
        && _currentNode.currentChildIndex < _currentNode.childNodes.count) {
        
        _currentNode = _currentNode.childNodes[_currentNode.currentChildIndex++];
        
        _lastDirection = 1;
    }
    
    // 2. parent node
    
    else {
        
        _currentNode = _currentNode.parentNode;
        
        _lastDirection = -1;
    }
}


//- (void) _nextNode {
//    
//    // 1. next child node
//    
//    if (_currentNode.returnState == UniParserNodeReturnStateUndefined
//        && _currentNode.currentChildIndex < _currentNode.childNodes.count) {
//        
//        _currentNode = _currentNode.childNodes[_currentNode.currentChildIndex++];
//        
//        _lastDirection = 1;
//    }
//    
//    // 2. parent node
//    
//    else {
//        
//        _currentNode = _currentNode.parentNode;
//        
//        _lastDirection = -1;
//    }
//}


- (void) _parseCurrentNode {
    
    if (!_currentNode.visited) {  // way down
        
        [self _createChildnodesForNode:_currentNode];
    }
    else {  // after visiting (way up)
        
    }
    
    [self _parseNode:_currentNode];
}


//- (void) _parseCurrentNode {
//
//    if (_currentNode.currentChildIndex == 0) {
//        
//        [self _createChildnodesForNode:_currentNode];
//    }
//    
//    [self _parseNode:_currentNode];
//}


- (void) _createChildNodeWithGrammarNode:(UniParserGrammarTreeNode*) grammarNode forParentNode:(UniParserNode*) parentNode {
    
    UniParserNode* childNode = [[UniParserNode alloc] init];
    childNode.grammarNode = grammarNode;
    childNode.parentNode = parentNode;
    [parentNode.childNodes addObject:childNode];
    childNode.ambiguityLevel = parentNode.ambiguityLevel;
    childNode.scanLocation = parentNode.scanLocation;
    childNode.depth = parentNode.depth + 1;
    childNode.wildcardActive = parentNode.wildcardActive;
    childNode.setVars = [NSMutableDictionary dictionaryWithDictionary:parentNode.setVars];

}


- (void) _createChildnodesForNode:(UniParserNode*) node {
    
    switch (node.grammarNode.type) {
            
        case UniParserGrammarTreeNodeTypeProduction: {
            
            UniParserGrammarTreeNodeProduction* production = (UniParserGrammarTreeNodeProduction*)node.grammarNode;
            
            [self _createChildNodeWithGrammarNode:production.expressionNode forParentNode:node];
        }
            break;
            
        case UniParserGrammarTreeNodeTypeExpressionList: {
            
            UniParserGrammarTreeNodeExpressionList* expressionList = (UniParserGrammarTreeNodeExpressionList*)node.grammarNode;

            [self _createChildNodeWithGrammarNode:expressionList.node1 forParentNode:node];
            [self _createChildNodeWithGrammarNode:expressionList.node2 forParentNode:node];
        }
            break;
            
        case UniParserGrammarTreeNodeTypeNonterminal: {
            
            UniParserGrammarTreeNodeNonterminal* nonterminal = (UniParserGrammarTreeNodeNonterminal*)node.grammarNode;
            UniParserGrammarTreeNodeProduction* production = [_grammarTree productionWithName:nonterminal.nameRef];
            
            [self _createChildNodeWithGrammarNode:production forParentNode:node];
        }
            break;
            
        case UniParserGrammarTreeNodeTypeGroup: {
            
            UniParserGrammarTreeNodeGroup* group = (UniParserGrammarTreeNodeGroup*)node.grammarNode;
            
            [self _createChildNodeWithGrammarNode:group.expressionNode forParentNode:node];
        }
            break;
            
        case UniParserGrammarTreeNodeTypeOptionOne: {
            
            UniParserGrammarTreeNodeOptionOne* option = (UniParserGrammarTreeNodeOptionOne*)node.grammarNode;
            
            [self _createChildNodeWithGrammarNode:option.expressionNode forParentNode:node];
        }
            break;
            
        case UniParserGrammarTreeNodeTypeOptionMany: {
            
            UniParserGrammarTreeNodeOptionMany* option = (UniParserGrammarTreeNodeOptionMany*)node.grammarNode;
            
            [self _createChildNodeWithGrammarNode:option.expressionNode forParentNode:node];
        }
            break;
            
        case UniParserGrammarTreeNodeTypeConditional: {
            
            BOOL isTrue = NO;
            
            for (NSString* functionString in node.grammarNode.functions) {
                
                NSArray* arguments = [functionString componentsSeparatedByString:@" "];
                NSString* functionName = arguments[0];
                
                if ([functionName isEqualToString:@"var_is_set"]) {
                    
                    assert(arguments.count == 2);
                    
                    NSString* varName = arguments[1];
                    
                    isTrue = [node.setVars[varName] boolValue];
                }
            }
            
            UniParserGrammarTreeNodeConditional* grammarNode = (UniParserGrammarTreeNodeConditional*)node.grammarNode;
            UniParserGrammarTreeNode* childNode = (isTrue) ? grammarNode.nodeTrue : grammarNode.nodeFalse;
            
            if (childNode) {

                [self _createChildNodeWithGrammarNode:childNode forParentNode:node];
            }
        }
            break;
            
        default:
            break;
    }
}


- (void) _passDataFromChild:(UniParserNode*) child toParent:(UniParserNode*) parent {
    
    // pass on setVars
        
    [self _mergeDictionary:child.setVars intoDictionary:parent.setVars];
}


- (void) _passDataFromParent:(UniParserNode*) parent toChild:(UniParserNode*) child {
    
    // pass on setVars
    
    [self _mergeDictionary:parent.setVars intoDictionary:child.setVars];
}





#pragma mark - Parse Grammar Nodes

- (void) _parseNode:(UniParserNode*) node {

    enum {UP, DOWN} direction = (!node.visited) ? DOWN : UP;
    
    node.visited = YES;

    
    if (node.grammarNode.newErrorZone) {
        
        if (direction == DOWN) {
            
            [self _addErrorZone:node];
        }
    }
    
    
    switch (node.grammarNode.type) {
            
        case UniParserGrammarTreeNodeTypeProduction:
            
            [self _parseProduction:node];
            break;
            
        case UniParserGrammarTreeNodeTypeExpressionList:
            
            [self _parseExpressionList:node];
            break;
            
        case UniParserGrammarTreeNodeTypeNonterminal:
            
            [self _parseNonterminal:node];
            break;
            
        case UniParserGrammarTreeNodeTypeTerminal:
            
            [self _parseTerminal:node];
            break;
            
        case UniParserGrammarTreeNodeTypeGroup:
            
            [self _parseGroup:node];
            break;
            
        case UniParserGrammarTreeNodeTypeOptionOne:
            
            [self _parseOptionOne:node];
            break;
            
        case UniParserGrammarTreeNodeTypeOptionMany:
            
            [self _parseOptionMany:node];
            break;

        case UniParserGrammarTreeNodeTypeWildcard:
            
            [self _parseWildcard:node];
            break;

        case UniParserGrammarTreeNodeTypeNothing:

            [self _parseNothing:node];
            break;
            
        case UniParserGrammarTreeNodeTypeConditional:
            
            [self _parseConditional:node];
            break;

        case UniParserGrammarTreeNodeTypeFalse:
            
            [self _parseFalse:node];
            break;

        default:

            // ???
            break;
    }
    
    
    if (node.grammarNode.newErrorZone) {
        
        if (direction == UP) {
            
            if (node.returnState == UniParserNodeReturnStateIncomplete  || node.returnState == UniParserNodeReturnStateNotFound) {  // might be incomplete or incorrect state to check for
                
                if (!_errorZoneNode) {
                    
                    // only first error is being saved in form of a error zone node
                    
//                    unichar c = [self _scanCurrentCharacter];
//                    
//                    NSString* messageString = [NSString stringWithFormat:@"Production incomplete \"%@\"\n", node];
//                    messageString = [messageString stringByAppendingFormat:@"Expected \"%@\" - found \"%C\" (%d).", _lastFailedTerminal , c, c];
//                    
//                    [self _errorAsWarning:NO message:messageString];

                    
                    _errorZoneNode = node;
                    _errorScanLocation = node.scanLocation;
                }
            }
            
            [self _popErrorZone:node];
        }
    }
}


- (void) _parseProduction:(UniParserNode*) node {

    // returns: anything
    
    UniParserNode* expressionNode = node.childNodes[0];
    
    
    if ([self _returnStateDecidedForNode:expressionNode]) {

        if (expressionNode.returnState == UniParserNodeReturnStateIncomplete && expressionNode.ambiguityLevel == 0) {
            
            unichar c = [self _scanCurrentCharacter];
            
            NSString* messageString = [NSString stringWithFormat:@"Production incomplete \"%@\"\n", node];
            messageString = [messageString stringByAppendingFormat:@"Expected \"%@\" - found \"%C\" (%d).", _lastFailedTerminal , c, c];
            
            [self _errorAsWarning:NO message:messageString];
        }

        node.returnState = expressionNode.returnState;
        node.scanLocation = expressionNode.scanLocation;
        node.finished = YES;

        [self _evaluateFunctionsForNode:node];
        
        if (node.returnState == UniParserNodeReturnStateSuccess) {

            [self _passDataFromChild:expressionNode toParent:node];
        }
    }
}


- (void) _parseExpressionList:(UniParserNode*) node {

    UniParserNode* node1 = node.childNodes[0];
    UniParserNode* node2 = node.childNodes[1];
    UniParserGrammarTreeNodeExpressionList* expressionList = (UniParserGrammarTreeNodeExpressionList*)node.grammarNode;
    
    
    // !!! probably handling scan location is much easier. just set the scan location to (node2 if concat once node2 is decided) (node1 or node2 if alternatives once one is decided)
    
    // !!! or maybe not because scanLocation of scanner might have progressed (success) eventho the subtree turns out to be failure. in this case scanlocation needs to be reverted (or kept at the original parent state before the descent into children)
    
    
    // concat (&) - returns: success, not found, incomplete
    
    if (expressionList.expressionListType == UniParserGrammarTreeNodeExpressionListTypeConcat) {

        if ([self _returnStateDecidedForNode:node1]) {
            
            if (![self _returnStateDecidedForNode:node2]) {
                
                if (node1.returnState == UniParserNodeReturnStateSuccess) {
                    
//                    node.scanLocation = node1.scanLocation;
                    node2.scanLocation = node1.scanLocation;
                    
                    [self _passDataFromChild:node1 toParent:node];
                    [self _passDataFromParent:node toChild:node2];
                }
                else if (node1.returnState == UniParserNodeReturnStateWildcard) {
                    
//                    node.scanLocation = node1.scanLocation;
                    node2.scanLocation = node1.scanLocation;
                    node.wildcardActive = YES;
                    node2.wildcardActive = YES;

                    [self _passDataFromChild:node1 toParent:node];
                }
                else {
                    
                    node.returnState = UniParserNodeReturnStateNotFound;  // if first node doesnt return success, this node returns not found
                    node.finished = YES;
                    node.currentChildIndex = node.childNodes.count - 1;
                    
                    [self _evaluateFunctionsForNode:node];
                }
            }
            else {
                
//                node.returnState = node2.returnState;
                node.finished = YES;
                
                [self _evaluateFunctionsForNode:node];
                
                if (node2.returnState == UniParserNodeReturnStateSuccess) {
                    
                    node.returnState = UniParserNodeReturnStateSuccess;
                    node.scanLocation = node2.scanLocation;
                    
                    [self _passDataFromChild:node2 toParent:node];
                }
                else if (node2.returnState == UniParserNodeReturnStateWildcard) {
                    
                    node.scanLocation = node2.scanLocation;
                    node.returnState = UniParserNodeReturnStateWildcard;
                    
                    [self _passDataFromChild:node2 toParent:node];
                }
                else {
                    
                    node.returnState = UniParserNodeReturnStateIncomplete;
                }
            }
        }
    }
    
    // alternatives (|) - returns: success, not found
    
    else {
        
        if ([self _returnStateDecidedForNode:node1]) {
            
            // WENN node1 decided
            
            if (node1.returnState == UniParserNodeReturnStateSuccess) {
                
                // WENN node1.return == success
                // DANN node.return = success && node2 skippen
                
                node.returnState = UniParserNodeReturnStateSuccess;
                node.finished = YES;
                node.currentChildIndex = node.childNodes.count - 1;
                node.scanLocation = node1.scanLocation;

                [self _evaluateFunctionsForNode:node];
                [self _passDataFromChild:node1 toParent:node];
            }
            else if (node1.returnState == UniParserNodeReturnStateWildcard) {
                
                // WENN node1.return == wildcard
                // DANN node.return = wildcard && node2 skippen
                
                node.returnState = UniParserNodeReturnStateWildcard;
                node.finished = YES;
                node.currentChildIndex = node.childNodes.count - 1;
                node.scanLocation = node1.scanLocation;

                [self _evaluateFunctionsForNode:node];
                [self _passDataFromChild:node1 toParent:node];
            }
            else if ([self _returnStateDecidedForNode:node2]) {

                // WENN node1.return nicht (success || wildcard)
                // UND WENN node2 decided
                // DANN ...
                
                node.finished = YES;
            
                [self _evaluateFunctionsForNode:node];

                if (node2.returnState == UniParserNodeReturnStateSuccess) {
                
                    // WENN node2.return == success
                    // DANN node.return = success
                    
                    node.returnState = UniParserNodeReturnStateSuccess;
                    node.scanLocation = node2.scanLocation;

                    [self _passDataFromChild:node2 toParent:node];
                }
                else if (node2.returnState == UniParserNodeReturnStateWildcard) {
                    
                    // WENN node2.return == wildcard
                    // DANN node.return = wildcard
                    
                    node.returnState = UniParserNodeReturnStateWildcard;
                    node.scanLocation = node2.scanLocation;

                    [self _passDataFromChild:node2 toParent:node];
                }
                else {
                    
                    // SONST node.return = not found
                    
                    node.returnState = UniParserNodeReturnStateNotFound;
                    
                }
            }

        }
        else {  // descent
            
            // WENN node1 nicht decided
            // DANN erhöhe ambi level
            
            node1.ambiguityLevel++;
        }
    }
}


- (void) _parseNonterminal:(UniParserNode*) node {
    
    // can return: anything

    UniParserNode* production = node.childNodes[0];

    
    if ([self _returnStateDecidedForNode:production]) {
        
        node.returnState = production.returnState;
        node.scanLocation = production.scanLocation;
        node.finished = YES;

        [self _evaluateFunctionsForNode:node];

        if (node.returnState == UniParserNodeReturnStateSuccess) {
            
            [self _passDataFromChild:production toParent:node];
        }
    }
}


- (void) _parseTerminal:(UniParserNode*) node {

    // can return: success or not found

    UniParserGrammarTreeNodeTerminal* terminal = (UniParserGrammarTreeNodeTerminal*)node.grammarNode;
    BOOL success;
    
    _currentToken = @"";
    
    _scanner.scanLocation = node.scanLocation;  // setting scan location is important because it might have to be set back
    
    if (terminal.string) {
    
        if (node.wildcardActive) {

//            if (_wildcardForCapturing && _wildcardForCapturing.grammarNode.captureType == UniParserGrammarTreeNodeCaptureTypeValue) {

            if (_wildcardForCapturing) {
            
                NSString* string = nil;
                [_scanner scanUpToString:terminal.string intoString:&string];
                _wildcardForCapturing.capturedString = string;
                _wildcardForCapturing = nil;
            }
//            else {
            
//                [_scanner scanUpToString:terminal.string intoString:nil];
//            }
        }
        
        success = [self _matchString:terminal.string];
    }
    else if (terminal.characterSet) {
        
        if (node.wildcardActive) {
            
            [_scanner scanUpToCharactersFromSet:terminal.characterSet intoString:nil];
        }
        
        success = [self _matchCharactersInSet:terminal.characterSet];
    }
    else {
        
        success = YES;
    }
    
    if (!success) {
        
        _lastFailedTerminal = (UniParserGrammarTreeNodeTerminal*)node.grammarNode;
    }
    
    node.capturedString = _currentToken;
    node.scanLocation = _scanner.scanLocation;
    
    node.returnState = (success) ? UniParserNodeReturnStateSuccess : UniParserNodeReturnStateNotFound;
    node.finished = YES;
    
    if (node.returnState == UniParserNodeReturnStateSuccess) {
        
        [self _evaluateFunctionsForNode:node];
    }
}


- (void) _parseGroup:(UniParserNode*) node {
    
    // can return: anything
    
    UniParserNode* expressionNode = node.childNodes[0];

    
    if ([self _returnStateDecidedForNode:expressionNode]) {
        
        node.returnState = expressionNode.returnState;
        node.scanLocation = expressionNode.scanLocation;
        node.finished = YES;

        [self _evaluateFunctionsForNode:node];

        if (node.returnState == UniParserNodeReturnStateSuccess) {

            [self _passDataFromChild:expressionNode toParent:node];
        }
    }
}


- (void) _parseOptionOne:(UniParserNode*) node {
    
    // can return: success or wildcard
    
    UniParserNode* expressionNode = node.childNodes[0];
    
    
    if ([self _returnStateDecidedForNode:expressionNode]) {

        if (expressionNode.returnState == UniParserNodeReturnStateWildcard) {
            
            node.returnState = UniParserNodeReturnStateWildcard;
            
            [self _passDataFromChild:expressionNode toParent:node];
        }
        else {
            
            node.returnState = UniParserNodeReturnStateSuccess;

            [self _passDataFromChild:expressionNode toParent:node];
        }
        
        node.finished = YES;
        node.scanLocation = expressionNode.scanLocation;

        if (expressionNode.returnState == UniParserNodeReturnStateSuccess ||
            expressionNode.returnState == UniParserNodeReturnStateWildcard) {
            
            [self _evaluateFunctionsForNode:node];
        }
    }
    else {
        
        expressionNode.ambiguityLevel++;
    }
}


- (void) _parseOptionMany:(UniParserNode*) node {
    
    // can return: success or wildcard

    UniParserNode* expressionNode = [node.childNodes lastObject];
    UniParserGrammarTreeNodeOptionMany* grammarNode = (UniParserGrammarTreeNodeOptionMany*)node.grammarNode;
    
    if ([self _returnStateDecidedForNode:expressionNode]) {

        if (expressionNode.returnState == UniParserNodeReturnStateSuccess) {

            // this makes the logic parse this node again (as long as success)

            expressionNode.returnState = UniParserNodeReturnStateUndefined;
            node.scanLocation = expressionNode.scanLocation;
            node.wildcardActive = NO;  // assuming a child tree always ends with a terminal (or a wildcard which returns wildcard)
        
            // count
        
            if (grammarNode.count == 0 || node.childNodes.count < grammarNode.count) {
            
                [self _createChildnodesForNode:node];
            }
            else {
                
                node.finished = YES;
                node.returnState = UniParserNodeReturnStateSuccess;
                
                [self _evaluateFunctionsForNode:node];
                [self _passDataFromChild:expressionNode toParent:node];
            }
        }
        else if (expressionNode.returnState == UniParserNodeReturnStateWildcard) {
            
            node.returnState = UniParserNodeReturnStateWildcard;
            node.finished = YES;

            [self _evaluateFunctionsForNode:node];
            [self _passDataFromChild:expressionNode toParent:node];
        }
        else {

            node.finished = YES;

            if (grammarNode.count > 0 && node.childNodes.count < grammarNode.count) {
                
                node.returnState = UniParserNodeReturnStateNotFound;
                
                [self _evaluateFunctionsForNode:node];
            }
            else {
            
                node.returnState = UniParserNodeReturnStateSuccess;

                [self _evaluateFunctionsForNode:node];
                [self _passDataFromChild:expressionNode toParent:node];
            }
        }
    }
    else {
        
        expressionNode.ambiguityLevel++;
    }
}


- (void) _parseWildcard:(UniParserNode*) node {

    node.returnState = UniParserNodeReturnStateWildcard;
    
//    if (node.grammarNode.captureType == UniParserGrammarTreeNodeCaptureTypeValue) {
    
        _wildcardForCapturing = node;
//    }
}


- (void) _parseNothing:(UniParserNode*) node {
    
    node.returnState = UniParserNodeReturnStateSuccess;
}


- (void) _parseConditional:(UniParserNode*) node {
    
    if (node.childNodes.count == 0) {
        
        node.finished = YES;
//        node.returnState = UniParserNodeReturnStateNotFound;
        node.returnState = UniParserNodeReturnStateSuccess;
        
        [self _evaluateFunctionsForNode:node];
        
        return; 
    }
    
    UniParserNode* expressionNode = node.childNodes[0];
    
    
    if ([self _returnStateDecidedForNode:expressionNode]) {
        
        node.returnState = expressionNode.returnState;
        node.scanLocation = expressionNode.scanLocation;
        node.finished = YES;
        
        [self _evaluateFunctionsForNode:node];
        
        if (node.returnState == UniParserNodeReturnStateSuccess) {
            
            [self _passDataFromChild:expressionNode toParent:node];
        }
    }
}


- (void) _parseFalse:(UniParserNode*) node {
    
    node.finished = YES;
    node.returnState = UniParserNodeReturnStateNotFound;
}





#pragma mark - Capturing

- (void) _capture {
    
    _capturedObjects = [NSMutableArray array];
    _capturedObjectStack = [NSMutableArray array];
    _currentNode = _rootNode;
    _rootNode.visited = NO;
    _productionStack = [NSMutableArray array];
    _totalString = [NSMutableString string];
    
    
//    [self logSeparator];
    
    // main loop
    
    do {
    
        if (_currentNode.finished) {  // fresh node
            
            _currentNode.finished = NO;
            _currentNode.currentChildIndex = 0;
            
            // unlock child nodes
            
            for (UniParserNode* childNode in _currentNode.childNodes) {
                
                childNode.visited = NO;
            }
        }
        
        [self _captureCurrentNode];
        
        [self _nextCaptureNode];
        
    } while (_currentNode);
}


- (void) _nextCaptureNode {
    
    UniParserGrammarTreeNodeType grammarNodeType = _currentNode.grammarNode.type;
    
    if (grammarNodeType == UniParserGrammarTreeNodeTypeExpressionList) {
        
        UniParserGrammarTreeNodeExpressionList* expressionList = (UniParserGrammarTreeNodeExpressionList*) _currentNode.grammarNode;
        
        UniParserNode* node1 = _currentNode.childNodes[0];
        UniParserNode* node2 = _currentNode.childNodes[1];
        
        if (expressionList.expressionListType == UniParserGrammarTreeNodeExpressionListTypeConcat) {
            
            // to look in concat expression sub-tree for captures, BOTH sub nodes must be success/wildcard
            
            if ((node1.returnState == UniParserNodeReturnStateSuccess || node1.returnState == UniParserNodeReturnStateWildcard) &&
                (node2.returnState == UniParserNodeReturnStateSuccess || node2.returnState == UniParserNodeReturnStateWildcard)) {
            
                if (!node1.visited) {
                    
                    _currentNode = node1;
                }
                else if (!node2.visited) {
                    
                    _currentNode = node2;
                }
                else {
                    
                    _currentNode = _currentNode.parentNode;
                }
            }
            else {
                
                _currentNode = _currentNode.parentNode;
            }
        }
        else {
            
            if (!node1.visited) {

                _currentNode = node1;
            }
            else if (!node2.visited) {
                
                if (node1.returnState == UniParserNodeReturnStateSuccess) {
                    
                    _currentNode = _currentNode.parentNode;
                }
                else {
                    
                    _currentNode = node2;
                }
            }
            else {
                
                _currentNode = _currentNode.parentNode;
            }
        }
    }
    else {
        
        if (_currentNode.childNodes.count > 1) {

            if (_currentNode.currentChildIndex < _currentNode.childNodes.count) {
                
                _currentNode = _currentNode.childNodes[_currentNode.currentChildIndex++];
            }
            else {
                
                _currentNode = _currentNode.parentNode;
            }
        }
        else if (_currentNode.childNodes.count == 1) {

            UniParserNode* childNode = _currentNode.childNodes[0];
            
            if (!childNode.visited && childNode.returnState == UniParserNodeReturnStateSuccess) {
                
                _currentNode = childNode;
            }
            else {
                
                _currentNode = _currentNode.parentNode;
            }
        }
        else {
            
            _currentNode = _currentNode.parentNode;
        }
    }
}


- (void) _captureCurrentNode {
    
//    NSLog(@"capturing: %d %@", _currentNode.depth, _currentNode);
    
    if (_currentNode.grammarNode.type == UniParserGrammarTreeNodeTypeTerminal) {
        
        ;;
    }
    
    
    if (_currentNode.grammarNode.type == UniParserGrammarTreeNodeTypeProduction && !_currentNode.visited) {
            
            [_productionStack addObject:_currentNode];
    }

    
    if (!_currentNode.visited && _currentNode.capturedString) {
        
        [_totalString appendString:_currentNode.capturedString];
    }
    
    
    if (_currentNode.grammarNode.captureType == UniParserGrammarTreeNodeCaptureTypeArray) {
        
        if (!_currentNode.visited) {

            [self _openCaptureArray];
        }
        else {
            
            [self _closeCaptureArray];
        }
    }
    else if (_currentNode.grammarNode.captureType == UniParserGrammarTreeNodeCaptureTypeDictionary) {
        
        if (!_currentNode.visited) {
            
            [self _openCaptureDictionary];
        }
        else {
            
            [self _closeCaptureDictionary];
        }
    }
    else if (_currentNode.grammarNode.captureType == UniParserGrammarTreeNodeCaptureTypeValue) {
        
        if (!_currentNode.visited) {

            if (_capturingValue) {
                
                [self _errorAsWarning:NO message:@"Capture error. Value inside value."];
            }

            [self _openCaptureValue];

            
            // special cast for Terminal: push and close right after (because terminals arent "captured" twice so they need to be manually closed)
            
            if (_currentNode.grammarNode.type == UniParserGrammarTreeNodeTypeTerminal
                || _currentNode.grammarNode.type == UniParserGrammarTreeNodeTypeWildcard) {
                
                [self _pushValue:_currentNode.capturedString];
                
                [self _closeCaptureValue];
            }
        }
        else {
            
            [self _closeCaptureValue];
        }
    }

    
    if (_capturingValue && _currentNode.capturedString) {
        
        [self _pushValue:_currentNode.capturedString];
        
//        NSLog(@"string: %@", _currentNode.capturedString);
    }
    

    if (_currentNode.grammarNode.type == UniParserGrammarTreeNodeTypeProduction && _currentNode.visited) {
        
        [_productionStack removeLastObject];
    }

    
    if (_currentNode.captureVars.allKeys.count != 0) {
        
        id topCaptureObject = [_capturedObjectStack lastObject];
        
        if ([topCaptureObject isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary* dict = (NSMutableDictionary*)topCaptureObject;

            for (NSString* key in _currentNode.captureVars.allKeys) {
                
                [dict setObject:_currentNode.captureVars[key] forKey:key];
            }
        }
        else {
            
            [self _errorAsWarning:NO message:@"Capturing var (set_if2) not inside a dictionary."];
        }
    }
    
    
    _currentNode.visited = YES;
}


- (void) _openCaptureArray {
    
//    NSLog(@"capture array");
    
    _currentCaptureObject = [NSMutableArray array];
    
    [_capturedObjectStack addObject:_currentCaptureObject];
}


- (void) _closeCaptureArray {
    
    assert([[_capturedObjectStack lastObject] isKindOfClass:[NSMutableArray class]]);
    
    [self _closeCaptureObject];
}


- (void) _openCaptureDictionary {
    
//    NSLog(@"capture dictionary");
    
    _currentCaptureObject = [NSMutableDictionary dictionary];
    
    [_capturedObjectStack addObject:_currentCaptureObject];
}


- (void) _closeCaptureDictionary {
    
    assert([[_capturedObjectStack lastObject] isKindOfClass:[NSMutableDictionary class]]);
    
    [self _closeCaptureObject];
}


- (void) _openCaptureValue {
    
//    NSLog(@"capture value");

    _capturingValue = YES;
    
    _currentCaptureObject = [NSMutableArray array];
    
    [_capturedObjectStack addObject:_currentCaptureObject];
}


- (void) _pushValue:(NSString*) string {
    
    assert([[_capturedObjectStack lastObject] isKindOfClass:[NSMutableArray class]]);

    NSMutableArray* captureValueArray = (NSMutableArray*)[_capturedObjectStack lastObject];
    
    [captureValueArray addObject:string];
}


- (void) _closeCaptureValue {
    
    assert([[_capturedObjectStack lastObject] isKindOfClass:[NSMutableArray class]]);
    
    [self _closeCaptureObject];
    
    _capturingValue = NO;
}


- (void) _closeCaptureObject {
    
    id lastCaptureObject = [_capturedObjectStack lastObject];
    [_capturedObjectStack removeLastObject];

    if (_capturingValue) {
        
        NSString* string = [self _arrayToString:lastCaptureObject];
        
        lastCaptureObject = string;
    }

    if (_capturedObjectStack.count == 0) {
        
        [_capturedObjects addObject:lastCaptureObject];
        
        [self _reportCaptureObject:lastCaptureObject];
    }
    else {
        
        id parentCaptureObject = [_capturedObjectStack lastObject];

        
        // array
        
        if ([parentCaptureObject isKindOfClass:[NSMutableArray class]]) {
            

            NSMutableArray* parentCaptureArray = (NSMutableArray*)parentCaptureObject;

            [parentCaptureArray addObject:lastCaptureObject];
        }
        
        
         // dictionary
        
        else {
            
            NSMutableDictionary* parentCaptureDictionary = (NSMutableDictionary*)parentCaptureObject;
            
//            UniParserNode* productionNode = [_productionStack lastObject];
//            UniParserGrammarTreeNodeProduction* production = (UniParserGrammarTreeNodeProduction*) productionNode.grammarNode;
//            NSString* productionName = production.name;

            NSString* captureKey = [self _captureKeyForNode:_currentNode];
            
            [parentCaptureDictionary setObject:lastCaptureObject forKey:captureKey];
        }
    }
}


- (NSArray*) capturedObjects {
    
    return _capturedObjects;
}


- (void) _reportCaptureObject:(id) captureObject {
    
    NSString* captureKey = [self _captureKeyForNode:_currentNode];
    
//    [self logString:[NSString stringWithFormat:@"Captured object: %@ = %@", captureKey, captureObject] withColor:nil];
}


- (NSString*) _captureKeyForNode:(UniParserNode*) node {
    
    if (node.grammarNode.captureKey) {
        
        return _currentNode.grammarNode.captureKey;
    }
    else if (node.grammarNode.type == UniParserGrammarTreeNodeTypeNonterminal) {
        
        UniParserGrammarTreeNodeNonterminal* nonterminal = (UniParserGrammarTreeNodeNonterminal*)node.grammarNode;
       return nonterminal.nameRef;
    }
    else {
        
        UniParserNode* topProduction = [_productionStack lastObject];
        UniParserGrammarTreeNodeProduction* production = (UniParserGrammarTreeNodeProduction*)topProduction.grammarNode;
        return production.name;
    }
}



#pragma mark - Error Zones

- (void) _addErrorZone:(UniParserNode*) node {
    
    if (node == [self _currentErrorZone]) return;
    
    [_errorZoneStack addObject:node];
}


- (void) _popErrorZone:(UniParserNode*) node {

    BOOL consistent = node == [self _currentErrorZone];
    
    if (!consistent) {
        
        [self _errorAsWarning:NO message:@"Inconsistency error popping error zone. Found %@, should be %@", node, [self _currentErrorZone]];
    }
    
    [_errorZoneStack removeLastObject];
}


- (UniParserNode*) _currentErrorZone {
    
    return [_errorZoneStack lastObject];
}




#pragma mark - Functions

- (void) _evaluateFunctionsForNode:(UniParserNode*) node {
    
    for (NSString* functionString in node.grammarNode.functions) {
        
        NSArray* arguments = [functionString componentsSeparatedByString:@" "];
        NSString* functionName = arguments[0];
        
        if ([functionName isEqualToString:@"set_if"]) {
            
            assert(arguments.count == 2);
            
            NSString* varName = arguments[1];
            
            [node.setVars setObject:@(YES) forKey:varName];
        }
        else if ([functionName isEqualToString:@"set_if2"]) {
            
            assert(arguments.count == 3);
            
            NSString* varName = arguments[1];
            NSString* value = arguments[2];

            [node.captureVars setObject:value forKey:varName];
        }

    }
}




#pragma mark - Utility

- (BOOL) _returnStateDecidedForNode:(UniParserNode*) node {
    
    return node.returnState != UniParserNodeReturnStateUndefined;
}


- (BOOL) _matchString:(NSString*) string {  // checks if string can be scanned. if not, moves scanLocation back
    
//    [self _pushScanLocation];
    
    NSString* token = nil;
    
    BOOL success = [_scanner scanString:string intoString:&token];
    
    if (!success) {
        
//        [self _restoreScanLocation];
    }
    else {
        
        _currentToken = [token copy];
        
//        [self _pushString:token];
    }
    
    return success;
}


- (BOOL) _matchCharactersInSet:(NSCharacterSet*) characterSet {
    
//    [self _pushScanLocation];
    
    NSString* token = nil;
    BOOL success = [_scanner scanCharactersFromSet:characterSet intoString:&token];
    
    if (!success) {
        
//        [self _restoreScanLocation];
    }
    else {
        
        _currentToken = [token copy];
        
//        [self _pushString:token];
        
    }
    
    return success;
}


- (NSString*) _arrayToString:(NSArray*) array {
    
    return [array componentsJoinedByString:@""];
}


- (void) _mergeDictionary:(NSDictionary*) dict1 intoDictionary:(NSMutableDictionary*) dict2 {
    
    for (NSString* key1 in dict1.allKeys) {
        
        [dict2 setObject:dict1[key1] forKey:key1];
    }
}










#pragma mark - Temp

- (void) logString:(NSString*) string withColor:(UIColor*) color {
    
    NSLog(@"%@", string);
    
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(logString:withColor:)]) {
    
        [[UIApplication sharedApplication].delegate performSelector:@selector(logString:withColor:) withObject:string withObject:color];
    }
}


- (void) logSeparator {
    
    NSLog(@"-------------------------------------------");
    
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(logSeparator)]) {

        [[UIApplication sharedApplication].delegate performSelector:@selector(logSeparator) withObject:nil];
    }
}





#pragma mark - Logging

- (void) _log:(NSString*) message, ... {
    
    if (!self.loggingEnabled) return;
    
    
    va_list args;
    va_start(args, message);
    
    NSString* fullMessage = [[NSString alloc] initWithFormat:message arguments:args];

    NSLog(@"%@", fullMessage);
}



#pragma mark - Error reporting

//- (void) _error:(NSString*) string, ... {
//    
//    [self _errorAsWarning:NO message:string];
//}
//
//
//- (void) _warning:(NSString*) string, ... {
//
//    [self _errorAsWarning:YES message:string];
//}


- (void) _errorAsWarning:(BOOL) asWarning message:(NSString*) string, ... {

    if (_isError) return;
    
    
    va_list args;
    va_start(args, string);
    
    NSString* message = [[NSString alloc] initWithFormat:string arguments:args];
    
    uint gapLength = MAX(1, _currentToken.length);
    
    NSRange range = NSMakeRange(_scanner.scanLocation - gapLength, gapLength);
    
    NSString* errorOrWarning = (asWarning) ? @"warning" : @"error";
    
    if ([_scanner isAtEnd]) {
        
        [self logString:[NSString stringWithFormat:@"UniParser %@", errorOrWarning] withColor:COLOR_ERROR];
        [self logString:message withColor:COLOR_ERROR];
        [self logString:[NSString stringWithFormat:@"Location=%d (end-of-file)", range.location] withColor:COLOR_ERROR];
    }
    else {

        [self logString:[NSString stringWithFormat:@"UniParser %@", errorOrWarning] withColor:COLOR_ERROR];
        [self logString:message withColor:COLOR_ERROR];
        [self logString:[NSString stringWithFormat:@"Location=%d, string=\"%@\"", range.location, [self _parserStringForRange:range radius:ERROR_REPORT_STRING_RADIUS]] withColor:COLOR_ERROR];
    }
    
//    NSLog(@"Production: %@", [_productionStack lastObject]);
    
    va_end(args);

    
    if (!asWarning) {
    
//        exit(0);
        _isError = YES;
    }
}


- (BOOL) hasError {
    
    return _isError;
}



- (NSString*) _parserStringForRange:(NSRange) range radius:(int) radius {
    
    NSString* string = _scanner.string;
    uint beginIndex = ((int)range.location - radius >= 0) ? range.location - radius : 0;
    uint endIndex = (range.location + range.length + radius < string.length) ? range.location + range.length + radius : string.length;
    
    NSString* substring = [string substringWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)];
    
    NSRange modifiedRange = NSMakeRange(range.location - beginIndex + 1, range.length);
    
    NSString* stringAtLocation = [substring substringWithRange:modifiedRange];
    NSString* replacementString = [NSString stringWithFormat:@"__%@__", stringAtLocation];
    substring = [substring stringByReplacingCharactersInRange:modifiedRange withString:replacementString];
    
    substring = [self _stringByEscapingControlChars:substring];
    
    return substring;
}


- (NSString*) _stringByEscapingControlChars:(NSString*) string {
    
    NSString* newString = [string copy];
    
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    newString = [newString stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    
    return newString;
}


- (unichar) _scanCurrentCharacter {
    
    NSString* token = [_scanner.string substringWithRange:NSMakeRange(_scanner.scanLocation, 1)];
    unichar c = [token characterAtIndex:0];
    
    return c;
}


- (void) dealloc {
    
    NSLog(@"UniParser -dealloc");
}

@end
