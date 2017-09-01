//
//  UniParserGrammarTree.m
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 21.12.14.
//  Copyright (c) 2014 Stefan Ueter. All rights reserved.
//

#import "UniParserGrammarTree.h"
@import UIKit;


#define PRODUCTION_ASSIGNMENT           @"="
#define PRODUCTION_SEPARATOR            @";"
#define EXPRESSION_LIST_SEPARATOR       @","
#define QUOTATION_MARKS                 @"\""
#define GROUP_OPEN                      @"("
#define GROUP_CLOSE                     @")"
#define OPTION_ONE_OPEN                 @"["
#define OPTION_ONE_CLOSE                @"]"
#define OPTION_MANY_OPEN                @"{"
#define OPTION_MANY_CLOSE               @"}"
#define ALTERNATIVE_SEPARATOR           @"|"
#define SPECIAL_SET_OPEN                @"?"
#define SPECIAL_SET_CLOSE               @"?"
#define WILDCARD                        @"*"

#define CAPTURE_KEY_NAME_OPEN           @"("
#define CAPTURE_KEY_NAME_CLOSE          @")"

#define ARGUMENTS_OPEN                  @"("
#define ARGUMENTS_CLOSE                 @")"

#define FUNCTION_ARGUMENTS_OPEN         @"("
#define FUNCTION_ARGUMENTS_CLOSE        @")"

#define CHARACTERSET_ALL                        @"all"
#define CHARACTERSET_ALPHABETIC_LOWERCASE       @"alphabetic_lowercase"
#define CHARACTERSET_ALPHABETIC_UPPERCASE       @"alphabetic_uppercase"
#define CHARACTERSET_ALPHABETIC                 @"alphabetic"
#define CHARACTERSET_DECIMAL                    @"decimal"
#define CHARACTERSET_PUNCTUATION                @"punctuation"
#define CHARACTERSET_WHITESPACE                 @"whitespace"
#define CHARACTERSET_WHITESPACEANDNEWLINE       @"whitespace_and_newline"
#define CHARACTERSET_NEWLINE                    @"newline"

#define CAPTURE_SYMBOL_ARRAY            @"#"
#define CAPTURE_SYMBOL_DICTIONARY       @"@"
#define CAPTURE_SYMBOL_VALUE            @"$"

#define IDENTIFIER_ALLOWED_CHARS        @"_!"

#define ERROR_REPORT_STRING_RADIUS      40

#define SETTINGS_PREFIX                 @";;"
#define COMMENTS_PREFIX                 @"//"

#define FUNCTION_PREFIX                 @"&"

#define FUNCTION_ARGUMENTS_SEPARATOR    @","

#define PRODUCTION_NEW_ERROR_ZONE_MARKER    @"!"

#define FUNCTION_NAME_JOIN_CONCAT       @"join_concat"
#define FUNCTION_NAME_JOIN_ALTERNATIVES @"join_alternatives"
#define FUNCTION_NAME_SET_IF            @"set_if"
#define FUNCTION_NAME_IF_SET            @"if_set"
#define FUNCTION_NAME_NOT_FOUND         @"not_found"
#define FUNCTION_NAME_SET_IF2           @"set_if2"          // sets a captured variable to a specific value


#define LOG_LEVEL_UNIPARSERGRAMMARTREE_1        NO


/* Stuff to test
 *
 * empty strings in quotes
 * groups (logical processing)
 *
 */



@implementation UniParserGrammarTree

@synthesize settings;


#pragma mark - Public

- (id) initWithString:(NSString *)string {

    self = [super init];

    _scanner = [[NSScanner alloc] initWithString:string];
    _scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    _whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
    _newlineSet = [NSCharacterSet newlineCharacterSet];
    _alphanumericSet = [NSCharacterSet alphanumericCharacterSet];

    NSMutableCharacterSet* identifierSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [identifierSet addCharactersInString:IDENTIFIER_ALLOWED_CHARS];
    _identifierSet = identifierSet;
    _productionDict = [NSMutableDictionary dictionary];
    _referencedNonterminals = [NSMutableArray array];
    settings = [self _loadDefaultSettings];
    
    _scanLocationStack = [NSMutableArray array];
    
    [self _scanEBNF];
    
    [self _testNonterminals];
    
//    [self _printProductions];
    
    return self;
}


- (NSMutableDictionary*) _loadDefaultSettings {
    
    NSDictionary* defaultDict = @{
             @"ignore_newline" : @(YES),
             @"case_sensitive" : @(NO)
             };
    
    return [NSMutableDictionary dictionaryWithDictionary:defaultDict];
}


- (UniParserGrammarTreeNodeProduction*) mainProduction {
    
    UniParserGrammarTreeNodeProduction* mainProduction = _productionDict[@"main"];
    
    if (!mainProduction) {
        
        [self _error:@"Main production not found."];

        return nil;
    }
    else {
        
        return mainProduction;
    }
}


- (UniParserGrammarTreeNodeProduction*) productionWithName:(NSString *)productionName {
    
    UniParserGrammarTreeNodeProduction* production = _productionDict[productionName];
    
    if (!production) {
        
        [self _error:[NSString stringWithFormat:@"Production named \"%@\" not found.", productionName]];
        
        return nil;
    }
    else {
        
        return production;
    }
}


- (BOOL) hasProductionNamed:(NSString *)productionName {
    
    return (_productionDict[productionName] != nil);
}




#pragma mark - Parsing / Importing the grammar file

- (void) _scanEBNF {

    while (![_scanner isAtEnd]) {
        
        if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
            [self logSeparator];
        
        
        if ([_scanner scanString:SETTINGS_PREFIX intoString:nil]) {
            
            NSDictionary* settingsDict = [self _scanSetting];
            
            [self _processSetting:settingsDict];
        }
        else if ([_scanner scanString:COMMENTS_PREFIX intoString:nil]) {
            
            [self _scanComments];
        }
        else {
        
            UniParserGrammarTreeNodeProduction* production = [self _scanProduction];
        
            [_productionDict setObject:production forKey:production.name];
        }
    }
}


- (BOOL) _matchString:(NSString*) string {  // checks if string can be scanned. if not, moves scanLocation back
    
    [self _pushScanLocation];
    
    BOOL success = [_scanner scanString:string intoString:nil];
    
    if (!success) {
        
        [self _restoreScanLocation];
    }
    else {
        
        [self _popScanLocation];
    }
    
    return success;
}


- (BOOL) _testString:(NSString*) string {  // checks if string can be scanned and moves scanLocation back always
    
    [self _pushScanLocation];
    
    BOOL success = [_scanner scanString:string intoString:nil];
    
    [self _restoreScanLocation];
    
    return success;
}


- (void) _consumeString:(NSString*) string {
    
    BOOL success = [self _matchString:string];

    if (!success) {
        
        [self _error:@"Expected \"%@\".", string];
    }
}


- (void) _consumeNewline {
    
    if ([_scanner.charactersToBeSkipped isSupersetOfSet:[NSCharacterSet newlineCharacterSet]]) return;
    
    BOOL success = [_scanner scanCharactersFromSet:_newlineSet intoString:nil];
    
    if (!success) {
        
        [self _error:@"Expected newline."];
    }
}


- (NSString*) _scanIdentifier {
    
    NSString* string = nil;

    [_scanner scanCharactersFromSet:_identifierSet intoString:&string];
    
    return string;
}


- (NSString*) _testString:(NSString*) string forCapture:(UniParserGrammarTreeNodeCaptureType*) captureType {
    
    NSString* returnString = string;
    
    if ([[string substringToIndex:1] isEqualToString:CAPTURE_SYMBOL_ARRAY]) {
        
        *captureType = UniParserGrammarTreeNodeCaptureTypeArray;
        returnString = [string substringFromIndex:1];
    }
    else if ([[string substringToIndex:1] isEqualToString:CAPTURE_SYMBOL_ARRAY]) {
        
        *captureType = UniParserGrammarTreeNodeCaptureTypeDictionary;
        returnString = [string substringFromIndex:1];
    }

    return returnString;
}


- (BOOL) _scanStringInQuotes:(NSString**) returnString {

    // 1. test for quotation marks begin
    
    BOOL success = [self _matchString:QUOTATION_MARKS];
    
    if (!success) return NO;
    
    
    // 2. scan string in quotes
    
//    NSString* string = nil;
    NSMutableString* string = [NSMutableString string];
    BOOL endQuoteFound = NO;
    
    while (!endQuoteFound) {
        
        NSString* s = nil;

        [_scanner scanUpToString:QUOTATION_MARKS intoString:&s];

        [string appendString:s];
        
        char previousChar = [_scanner.string characterAtIndex:_scanner.scanLocation - 1];
        
        if (previousChar != '\\') {
            
            endQuoteFound = YES;
        }
        else {

            [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
        }
        
        if ([_scanner isAtEnd]) {
            
            [self _error:@"Expected \"%@\".", QUOTATION_MARKS];
            return NO;
        }
        
        if (!endQuoteFound) {

            [_scanner scanString:QUOTATION_MARKS intoString:&s];
        
            [string appendString:s];
        }
    }


    // 3. test for quotation marks end
    
    [self _consumeString:QUOTATION_MARKS];
    

    
    // 4. return true and  the string
    
    *returnString = [string copy];
    
    return YES;
}


- (void) _scanWhitespaces {
    
    uint locationBefore = _scanner.scanLocation;
    
    [_scanner scanCharactersFromSet:_whitespaceSet intoString:nil];
    
    uint locationAfter = _scanner.scanLocation;
    
    if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
        [self logString:[NSString stringWithFormat:@"(skipped %d whitespaces)", (locationAfter - locationBefore)] withColor:nil];
}


- (BOOL) _stringEmpty:(NSString*) string {
    
    return !(string && string.length > 0);
}


- (void) _processSetting:(NSDictionary*) dictionary {

    NSString* key = dictionary.allKeys[0];
    NSString* value = dictionary[key];
    BOOL boolValue = NO;
    
    if ([[value lowercaseString] isEqualToString:@"yes"] || [[value lowercaseString] isEqualToString:@"true"]) {
        
        boolValue = YES;
    }
    else if ([[value lowercaseString] isEqualToString:@"no"] || [[value lowercaseString] isEqualToString:@"false"]) {
     
        boolValue = NO;
    }
    else {
        
        [self _error:@"Unknown value for setting \"%@\"", value];
    }
    
    [settings setObject:@(boolValue) forKey:key];
    
//    [self logSeparator];
    
//    [self logString:[NSString stringWithFormat:@"setting \"%@\" = \"%@\"", key, boolValue ? @"YES" : @"NO"] withColor:nil];
}


- (NSCharacterSet*) _characterSetForString:(NSString*) string {

    NSString* cleanedString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSMutableCharacterSet* combinedSet = [[NSMutableCharacterSet alloc] init];
    
    NSScanner* scanner = [[NSScanner alloc] initWithString:cleanedString];
    NSString* token = nil;
    NSCharacterSet* dividerSet = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    NSString* lastDivider = nil;
    
    while (![scanner isAtEnd]) {
        
        if ([scanner scanString:@"'" intoString:nil]) {
            
            [scanner scanUpToString:@"'" intoString:&token];
            
            [scanner scanString:@"'" intoString:nil];
            
            token = [NSString stringWithFormat:@"'%@'", token];
        }
        else {

            [scanner scanUpToCharactersFromSet:dividerSet intoString:&token];
        }
        
        NSString* charSetName = [token copy];
        NSCharacterSet* charSet = nil;
        
        if ([[charSetName substringToIndex:1] isEqualToString:@"'"]) {

            NSString* characterString = [charSetName stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            charSet = [NSCharacterSet characterSetWithCharactersInString:characterString];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_ALL]) {
            
            charSet = [[[NSCharacterSet alloc] init] invertedSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_ALPHABETIC]) {
            
            charSet =[NSCharacterSet letterCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_ALPHABETIC_LOWERCASE]) {
            
            charSet = [NSCharacterSet lowercaseLetterCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_ALPHABETIC_UPPERCASE]) {
            
            charSet = [NSCharacterSet uppercaseLetterCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_DECIMAL]) {
            
            charSet = [NSCharacterSet decimalDigitCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_PUNCTUATION]) {
            
            charSet = [NSCharacterSet punctuationCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_WHITESPACE]) {
            
            charSet = [NSCharacterSet whitespaceCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_WHITESPACEANDNEWLINE]) {
            
            charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        }
        else if ([charSetName isEqualToString:CHARACTERSET_NEWLINE]) {
            
            charSet = [NSCharacterSet newlineCharacterSet];
        }
        else {
            
            [self _error:@"Unknown character set \"%@\"", charSetName];
        }

        
        if (lastDivider) {

            if ([lastDivider isEqualToString:@"+"]) {
                
                [combinedSet formUnionWithCharacterSet:charSet];
            }
            else {
                
                [combinedSet formIntersectionWithCharacterSet:[charSet invertedSet]];
            }
        }
        else {
            
            [combinedSet formUnionWithCharacterSet:charSet];
        }
        
        BOOL success = [scanner scanCharactersFromSet:dividerSet intoString:&token];
    
        if (success) {
            
            lastDivider = [token copy];
        }

    }
    
    return combinedSet;
}

//- (NSCharacterSet*) _characterSetForString:(NSString*) string {
//
//    NSMutableCharacterSet* characterSet = [[NSMutableCharacterSet alloc] init];
//
//    NSString* cleanedString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSArray* minusDividedStrings = [cleanedString componentsSeparatedByString:@"-"];
//
//    for (NSString* minusDividedString in minusDividedStrings) {
//        
//        NSMutableCharacterSet* subCharacterSet = [[NSMutableCharacterSet alloc] init];
//
//        NSArray* plusDividedStrings = [minusDividedString componentsSeparatedByString:@"+"];
//        
//        
//        for (NSString* plusDividedString in plusDividedStrings) {
//            
//            if ([plusDividedString isEqualToString:CHARACTERSET_ALPHABETIC]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_ALPHABETIC_LOWERCASE]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_ALPHABETIC_UPPERCASE]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_DECIMAL]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_PUNCTUATION]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_WHITESPACE]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_WHITESPACEANDNEWLINE]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//            }
//            else if ([plusDividedString isEqualToString:CHARACTERSET_NEWLINE]) {
//                
//                [subCharacterSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
//            }
//            
//            else {
//                
//                [self _error:@"Unknown character set \"%@\"", plusDividedString];
//            }
//        }
//        
//    }
//    
//    
//
//    return characterSet;
//}


- (void) _scanCaptureTypeForNode:(UniParserGrammarTreeNode*) node {
    
    UniParserGrammarTreeNodeCaptureType captureType = UniParserGrammarTreeNodeCaptureTypeNone;
    
    if ([_scanner scanString:CAPTURE_SYMBOL_ARRAY intoString:nil]) {
        
        captureType = UniParserGrammarTreeNodeCaptureTypeArray;
    }
    else if ([_scanner scanString:CAPTURE_SYMBOL_DICTIONARY intoString:nil]) {
        
        captureType = UniParserGrammarTreeNodeCaptureTypeDictionary;
    }
    else if ([_scanner scanString:CAPTURE_SYMBOL_VALUE intoString:nil]) {
        
        captureType = UniParserGrammarTreeNodeCaptureTypeValue;
    }

    node.captureType = captureType;

    if (captureType != UniParserGrammarTreeNodeCaptureTypeNone) {
    
        if ([self _matchString:CAPTURE_KEY_NAME_OPEN]) {
            
            NSString* keyName = [self _scanIdentifier];
            node.captureKey = keyName;
            
            if (keyName.length == 0) {
                
                [self _error:@"Capture key empty."];
            }
            
            [self _consumeString:CAPTURE_KEY_NAME_CLOSE];
        }
    }

}


- (UniParserGrammarTreeNodeProduction*) _scanProduction {
    
//  production                  =   whitespaces , identifier , whitespaces , "=" , whitespaces , expression_list , whitespaces , ";" ;

    
    UniParserGrammarTreeNodeProduction* production = [[UniParserGrammarTreeNodeProduction alloc] init];
    
    
    // 0. whitespaces
    
    [self _scanWhitespaces];

    
    // 1. identifier  (with prefix)

    [self _scanCaptureTypeForNode:production];

    
    NSString* identifier = [self _scanIdentifier];
    
    BOOL success = ![self _stringEmpty:identifier];
    
    if (!success) {
        
        [self _error:@"Expected identifier."];
    }
    
    if ([[identifier substringFromIndex:identifier.length - 1] isEqualToString:PRODUCTION_NEW_ERROR_ZONE_MARKER]) {
        
        identifier = [identifier substringToIndex:identifier.length - 1];
        production.newErrorZone = YES;
    }

    production.name = identifier;
    
    if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
        [self logString:[NSString stringWithFormat:@"production identifier \"%@\"", identifier] withColor:nil];
    
    [self _scanWhitespaces];

    
    // 2. assignment operator
    
    [self _consumeString:PRODUCTION_ASSIGNMENT];
    
    if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
        [self logString:PRODUCTION_ASSIGNMENT withColor:nil];
    
    [self _scanWhitespaces];
    
    
    // 3. expression_list
    
    UniParserGrammarTreeNode* expressionNode = [self _scanExpressionList];
    production.expressionNode = expressionNode;
    
    // 4. production separator
    
    
    [self _consumeString:PRODUCTION_SEPARATOR];
    
    [self _consumeNewline];
    
    return production;
}



- (UniParserGrammarTreeNode*) _scanExpressionList {

//expression_list             =   expression , ((whitespaces , "," , whitespaces , expression_list) | (whitespaces , "|" , whitespaces , expression_list)) ;
    
    
    UniParserGrammarTreeNode* node = nil;
    
    
    [self _pushScanLocation];

    UniParserGrammarTreeNode* expression = [self _scanExpression];

    
    BOOL success = (expression != nil);
    
    if (success) {
    
        [self _scanWhitespaces];
        
        if ([self _matchString:EXPRESSION_LIST_SEPARATOR]) {
            
            UniParserGrammarTreeNodeExpressionList* theNode = [[UniParserGrammarTreeNodeExpressionList alloc] init];
            theNode.node1 = expression;
            UniParserGrammarTreeNode* node2 = [self _scanExpressionList];
            
            success = (node2 != nil);
            
            [self _scanWhitespaces];
            
            if (success) {
                
                theNode.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
                theNode.node2 = node2;

                node = theNode;
                
                if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
                    [self logString:@"expression list (more than 1)" withColor:nil];
                
                [self _popScanLocation];
            }
        }
        else if ([self _matchString:ALTERNATIVE_SEPARATOR]) {

            UniParserGrammarTreeNodeExpressionList* theNode = [[UniParserGrammarTreeNodeExpressionList alloc] init];
            theNode.node1 = expression;
            UniParserGrammarTreeNode* node2 = [self _scanExpressionList];
            
            success = (node2 != nil);
            
            [self _scanWhitespaces];
            
            if (success) {

                theNode.expressionListType = UniParserGrammarTreeNodeExpressionListTypeAlternatives;
                theNode.node2 = node2;
                
                node = theNode;

                if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
                    [self logString:@"expression alternatives" withColor:nil];

                [self _popScanLocation];
            }
        }
        else {
            
            node = expression;
        }
    }
    
    if (!success) {
        
        [self _restoreScanLocation];

        return nil;
    }
    else {
        
        return node;
    }
}


- (UniParserGrammarTreeNode*) _scanExpression {
    
//    expression                  =   whitespaces , (group | terminal | nonterminal | option_one | option_many | special_set | alternative) , whitespaces ;
    
    [self _pushScanLocation];
    
    BOOL success;
    
    UniParserGrammarTreeNode* node = [self _scanNonterminal];
    success = (node != nil);
    
    if (!success) {  // begins with "
        
        node = [self _scanTerminal];
        success = (node != nil);
    }

    if (!success) {  // begins with (
        
        node = [self _scanGroup];
        success = (node != nil);
    }

    if (!success) {  // begins with [
        
        node = [self _scanOptionOne];
        success = (node != nil);
    }

    if (!success) {  // begins with {
        
        node = [self _scanOptionMany];
        success = (node != nil);
    }

    if (!success) {  // begins with ?
        
        node = [self _scanSpecialSet];
        success = (node != nil);
    }

    if (!success) {  // begins with *
        
        node = [self _scanWildcard];
        success = (node != nil);
    }
    
    if (!success) {  // begins with _
        
        node = [self _scanFunction];
        success = (node != nil);
    }

    if (!success) {  // ... is nothing

        node = [self _scanNothing];
        success = (node != nil);
    }

    [self _popScanLocation];
        
    return node;
}


- (UniParserGrammarTreeNodeNonterminal*) _scanNonterminal {

    UniParserGrammarTreeNodeNonterminal* node = [[UniParserGrammarTreeNodeNonterminal alloc] init];

    [self _pushScanLocation];

    
    [self _scanCaptureTypeForNode:node];

    

    NSString* identifier = [self _scanIdentifier];
    
    BOOL success = ![self _stringEmpty:identifier];
    
    if (success) {
    
        node.nameRef = identifier;
        
        [_referencedNonterminals addObject:identifier];
        
        [self _popScanLocation];
        
        if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
            [self logString:[NSString stringWithFormat:@"nonterminal \"%@\"", identifier] withColor:nil];
        
        return node;
    }
    else {
        
        [self _restoreScanLocation];
        
        return nil;
    }
}


- (UniParserGrammarTreeNodeTerminal*) _scanTerminal {

    UniParserGrammarTreeNodeTerminal* node = [[UniParserGrammarTreeNodeTerminal alloc] init];

    [self _pushScanLocation];

    
    [self _scanCaptureTypeForNode:node];

    
    
    NSString* terminalString;
    
    BOOL success = [self _scanStringInQuotes:&terminalString];

    if (success && [self _stringEmpty:terminalString]) {
        
        [self _error:@"Found empty string."];
    }
    
    if (success) {
        
        node.string = terminalString;
        
        [self _popScanLocation];
        
        if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
            [self logString:[NSString stringWithFormat:@"terminal \"%@\"", terminalString] withColor:nil];
        
        return node;
    }
    else {
        
        [self _restoreScanLocation];
        
        return nil;
    }
}


- (UniParserGrammarTreeNodeGroup*) _scanGroup {
    
//  group                       =   "(" , expression_list , ")" ;

    UniParserGrammarTreeNodeGroup* node = [[UniParserGrammarTreeNodeGroup alloc] init];
    
    
    [self _pushScanLocation];
    
    
    [self _scanCaptureTypeForNode:node];



    BOOL success = [self _matchString:GROUP_OPEN];
    
    if (success) {

        UniParserGrammarTreeNode* expressionNode = [self _scanExpressionList];
        success = (expressionNode != nil);

        if (success) {
        
            [self _consumeString:GROUP_CLOSE];
        
            node.expressionNode = expressionNode;
            
            if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
                [self logString:@"group" withColor:nil];
            
            [self _popScanLocation];
            
            return node;
        }
    }
    
    if (!success) {
        
        [self _restoreScanLocation];
        
        return nil;
    }
    else return nil;
}


- (UniParserGrammarTreeNodeOptionOne*) _scanOptionOne {
    
//  option_one                  =   "[" , expression_list" , "]" ;

    UniParserGrammarTreeNodeOptionOne* node = [[UniParserGrammarTreeNodeOptionOne alloc] init];
    
    
    [self _pushScanLocation];
    
    BOOL success = [self _matchString:OPTION_ONE_OPEN];
    
    if (success) {
        
        UniParserGrammarTreeNode* expressionNode = [self _scanExpressionList];
        success = (expressionNode != nil);
        
        if (success) {
            
            [self _consumeString:OPTION_ONE_CLOSE];
            
            node.expressionNode = expressionNode;
            
            if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
                [self logString:@"option_one" withColor:nil];
            
            [self _popScanLocation];
            
            return node;
        }
    }
    
    if (!success) {
        
        [self _restoreScanLocation];
        
        return nil;
    }
    else return nil;
}


- (UniParserGrammarTreeNodeOptionMany*) _scanOptionMany {
    
//  option_many                 =   "{" , expression_list" , "}" ;

    UniParserGrammarTreeNodeOptionMany* node = [[UniParserGrammarTreeNodeOptionMany alloc] init];
    
    
    [self _pushScanLocation];
    
    
    [self _scanCaptureTypeForNode:node];



    BOOL success = [self _matchString:OPTION_MANY_OPEN];
    
    if (success) {
        
        UniParserGrammarTreeNode* expressionNode = [self _scanExpressionList];
        success = (expressionNode != nil);
        
        if (success) {
            
            [self _consumeString:OPTION_MANY_CLOSE];
            
            node.expressionNode = expressionNode;
            
            if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
                [self logString:@"option_many" withColor:nil];
            
            // count argument
            
            success = [self _matchString:ARGUMENTS_OPEN];
            
            if (success) {
                
                NSString* countString = nil;
                success = [_scanner scanUpToString:ARGUMENTS_CLOSE intoString:&countString];
                
                if (success) {
                    
                    uint count = [countString integerValue];
                    node.count = count;
                    
                    [self _consumeString:ARGUMENTS_CLOSE];
                }
                else {
                    
                    [self _error:@"OptionMany arguments syntax error."];
                }
            }
            
            
            [self _popScanLocation];
            
            return node;
        }
    }
    
    if (!success) {
        
        [self _restoreScanLocation];
        
        return nil;
    }
    else return nil;
}


- (UniParserGrammarTreeNodeTerminal*) _scanSpecialSet {
    
//  special_set                 =   "?" , identifier , "?" ;
  
    UniParserGrammarTreeNodeTerminal* node = [[UniParserGrammarTreeNodeTerminal alloc] init];
    
    
    [self _pushScanLocation];
    
    
    [self _scanCaptureTypeForNode:node];
    
    
    BOOL success = [self _matchString:SPECIAL_SET_OPEN];
    
    if (success) {
        
        NSString* string = nil;
        
        [_scanner scanUpToString:SPECIAL_SET_CLOSE intoString:&string];
        
        BOOL success = ![self _stringEmpty:string];
        
        if (success) {
            
            [self _consumeString:SPECIAL_SET_CLOSE];
            
            NSCharacterSet* characterSet = [self _characterSetForString:string];

            node.characterSetDescription = string;

            if (!characterSet) {
                
                [self _error:@"Character set not found \"%@\".", string];
            }
            
            node.characterSet = characterSet;
            
            if (LOG_LEVEL_UNIPARSERGRAMMARTREE_1)
                [self logString:[NSString stringWithFormat:@"special set \"%@\"", string] withColor:nil];
            
            [self _popScanLocation];
            
            return node;
        }
    }
    
    if (!success) {
        
        [self _restoreScanLocation];
        
        return nil;
    }
    else return nil;
}


- (UniParserGrammarTreeNode*) _scanWildcard {
    
    UniParserGrammarTreeNodeWildcard* node = [[UniParserGrammarTreeNodeWildcard alloc] init];
    
    [self _pushScanLocation];

    
    [self _scanCaptureTypeForNode:node];

    
    BOOL success = [self _matchString:WILDCARD];
    
    if (success) {
        
        [self _popScanLocation];
        
        return node;
    }
    else {
        
        [self _restoreScanLocation];
        
        return nil;
    }

    
    return node;
}


- (UniParserGrammarTreeNode*) _scanFunction {  // creates a sub-tree and returns it
    
    BOOL success = [self _matchString:FUNCTION_PREFIX];
    
    if (success) {

        NSString* functionName = nil;
        success = [_scanner scanUpToString:FUNCTION_ARGUMENTS_OPEN intoString:&functionName];
        
        if (success) {
            
            [self _consumeString:FUNCTION_ARGUMENTS_OPEN];

            UniParserGrammarTreeNode* node = [self _handleFunctionName:functionName];

            return node;
        }
        else {
            
            [self _error:@"Function syntax error."];

            return nil;
        }
    }
    else {
        
        return nil;
    }
}


- (UniParserGrammarTreeNode*) _scanNothing {
    
    UniParserGrammarTreeNodeNothing* node = [[UniParserGrammarTreeNodeNothing alloc] init];
    
    return node;
}


- (NSDictionary*) _scanSetting {
    
    NSString* identifier = [self _scanIdentifier];
    
    BOOL success = ![self _stringEmpty:identifier];
    
    if (!success) {
        
        [self _error:@"Expected identifier."];
    }
    
    // 2. assignment operator
    
    [self _consumeString:PRODUCTION_ASSIGNMENT];

    // 3. terminal
    
    NSString* value = nil;
    
    [_scanner scanCharactersFromSet:_alphanumericSet intoString:&value];
    
    [self _consumeString:PRODUCTION_SEPARATOR];
    
    [self _consumeNewline];
    
    return @{
             identifier : value
             };
}


- (void) _scanComments {

//    NSMutableCharacterSet* charSet = [[NSMutableCharacterSet alloc] init];
//    [charSet formUnionWithCharacterSet:_alphanumericSet];
//    [charSet formUnionWithCharacterSet:_whitespaceSet];
//    [charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];

    
    
    [_scanner scanUpToCharactersFromSet:_newlineSet intoString:nil];
    
    [self _consumeNewline];
}





#pragma mark - Function handlers

- (UniParserGrammarTreeNode*) _handleFunctionName:(NSString*) functionName {
    
    if ([functionName isEqualToString:FUNCTION_NAME_JOIN_CONCAT]) {
        
        return [self _handleFunctionJoinConcat];
    }
    else if ([functionName isEqualToString:FUNCTION_NAME_SET_IF]) {
        
        return [self _handleFunctionSetIf];
    }
    else if ([functionName isEqualToString:FUNCTION_NAME_IF_SET]) {
        
        return [self _handleFunctionIfSet];
    }
    else if ([functionName isEqualToString:FUNCTION_NAME_NOT_FOUND]) {
        
        return [self _handleFunctionNotFound];
    }
    else if ([functionName isEqualToString:FUNCTION_NAME_SET_IF2]) {
        
        return [self _handleFunctionSetIf2];
    }
    else {
        
        [self _error:@"Function not found \"%@\"", functionName];
        
        return nil;
    }
}


- (UniParserGrammarTreeNode*) _handleFunctionJoinConcat {

    
    
    
    // !!!!!!!!!!!!!!!!!!!!!!!! PROBLEM !!!!!!!!!!!!!!!!!!!!!!!!!
    //
    // Type 1 needs special case for OPTIONS. if FIRST node is optional, the following separator is too
    
    
    
    
    
    // sub-tree creator blocks
    

    // type 1 (SINGLE node -> no separator needed
    
    UniParserGrammarTreeNode* (^createType1Tree)(UniParserGrammarTreeNode*, UniParserGrammarTreeNode*) = ^UniParserGrammarTreeNode* (UniParserGrammarTreeNode* node, UniParserGrammarTreeNode* separator) {

        return node;
    };

    
    // type 2 (FIRST node in list with at least 2 nodes)
    
    UniParserGrammarTreeNodeExpressionList* (^createType2Tree)(UniParserGrammarTreeNode*, UniParserGrammarTreeNode*) = ^UniParserGrammarTreeNodeExpressionList* (UniParserGrammarTreeNode* node, UniParserGrammarTreeNode* separator) {

        UniParserGrammarTreeNodeExpressionList* list = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
        list.node1 = node;
        
        return list;
    };

    
    // type 3 (node in the MIDDLE of a list with at least 3 nodes (not first node, not last node)
    
    UniParserGrammarTreeNodeExpressionList* (^createType3Tree)(UniParserGrammarTreeNode*, UniParserGrammarTreeNode*, UniParserGrammarTreeNodeExpressionList**) = ^UniParserGrammarTreeNodeExpressionList* (UniParserGrammarTreeNode* node, UniParserGrammarTreeNode* separator, UniParserGrammarTreeNodeExpressionList** frontList) {

        UniParserGrammarTreeNodeExpressionList* list1 = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list1.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
        list1.node1 = separator;
        
        UniParserGrammarTreeNodeExpressionList* list2 = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list2.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
        list2.node1 = node;
        
        list1.node2 = list2;
        
        *frontList = list1;
        
        return list2;
    };
    
    
    // type 3 with OPTION
    
    UniParserGrammarTreeNodeExpressionList* (^createType3TreeWithOption)(UniParserGrammarTreeNode*, UniParserGrammarTreeNode*, UniParserGrammarTreeNodeExpressionList**) = ^UniParserGrammarTreeNodeExpressionList* (UniParserGrammarTreeNode* node, UniParserGrammarTreeNode* separator, UniParserGrammarTreeNodeExpressionList** frontList) {
        
        UniParserGrammarTreeNodeExpressionList* list1 = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list1.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;

        UniParserGrammarTreeNodeOptionOne* option = [[UniParserGrammarTreeNodeOptionOne alloc] init];
        
        list1.node1 = option;
        
        UniParserGrammarTreeNodeExpressionList* list2 = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list2.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
        
        option.expressionNode = list2;
        
        list2.node1 = separator;
        
        UniParserGrammarTreeNodeOptionOne* option2 = (UniParserGrammarTreeNodeOptionOne*)node;
        
        list2.node2 = option2.expressionNode;
        
        [option2.expressionNode.functions addObjectsFromArray:option2.functions];
        
        *frontList = list1;
        
        return list1;
    };
    
    
    // type 4 (LAST node in a list of at least 2 nodes)
    
    UniParserGrammarTreeNode* (^createType4Tree)(UniParserGrammarTreeNode*, UniParserGrammarTreeNode*) = ^UniParserGrammarTreeNode* (UniParserGrammarTreeNode* node, UniParserGrammarTreeNode* separator) {

        UniParserGrammarTreeNodeExpressionList* list = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
        list.node1 = separator;
        list.node2 = node;
        
        return list;
    };
    
    
    // type 4 with OPTION
    
    UniParserGrammarTreeNode* (^createType4TreeWithOption)(UniParserGrammarTreeNode*, UniParserGrammarTreeNode*) = ^UniParserGrammarTreeNode* (UniParserGrammarTreeNode* node, UniParserGrammarTreeNode* separator) {
        
        UniParserGrammarTreeNodeExpressionList* list = [[UniParserGrammarTreeNodeExpressionList alloc] init];
        list.expressionListType = UniParserGrammarTreeNodeExpressionListTypeConcat;
        list.node1 = separator;

        UniParserGrammarTreeNodeOptionOne* option2 = (UniParserGrammarTreeNodeOptionOne*)node;
        
        list.node2 = option2.expressionNode;
        
        option2.expressionNode.functions = [NSMutableArray arrayWithArray:option2.functions];
        
        UniParserGrammarTreeNodeOptionOne* option = [[UniParserGrammarTreeNodeOptionOne alloc] init];
        option.expressionNode = list;
        
        return option;
    };
    
    
    
    
    
    
    NSMutableArray* argumentNodes = [NSMutableArray array];
    UniParserGrammarTreeNode* node = nil;
    
    while (![self _matchString:FUNCTION_ARGUMENTS_CLOSE]) {
        
        node = [self _scanExpression];
        
        if (!node) {
            
            [self _error:@"Function syntax error."];
        }
        
        [argumentNodes addObject:node];
        
        [self _matchString:FUNCTION_ARGUMENTS_SEPARATOR];
    }
    
    if (argumentNodes.count < 3) {
        
        [self _error:@"Insufficient arguments for function \"%@\" (%d, must be >= 3)", @"join_concat", argumentNodes.count];
    }
    
    // build sub-tree

    UniParserGrammarTreeNode* separatorNode = [argumentNodes lastObject];
    UniParserGrammarTreeNode* rootNode = nil;
    
    
    // case Type 1 (SINGLE node)
    
    if (argumentNodes.count < 3) {
        
        rootNode = argumentNodes[1];
    }

    else {
    
        UniParserGrammarTreeNodeExpressionList* rootList = nil;
        UniParserGrammarTreeNodeExpressionList* currentList = nil;
        
//        __weak UniParserGrammarTreeNode* weakNode = node;
//        __weak UniParserGrammarTreeNode* weakSeparator = separatorNode;
        
        for (uint i = 0; i < argumentNodes.count - 1; ++i) {
            
            UniParserGrammarTreeNode* node = argumentNodes[i];
            
            // case Type 2 (FIRST node of many)
            
            if (i == 0) {
                
                currentList = createType2Tree(node, separatorNode);
                rootList = currentList;
            }

            // case Type 3 (MIDDLE node)
            
            else if (i < argumentNodes.count - 2) {  // not last argument node

                if ([node isKindOfClass:[UniParserGrammarTreeNodeOptionOne class]]) {
                    
                    UniParserGrammarTreeNodeExpressionList* frontList = nil;
                    UniParserGrammarTreeNodeExpressionList* backlist = createType3TreeWithOption(node, separatorNode, &frontList);
                    currentList.node2 = frontList;
                    currentList = backlist;
                }
                else {
                    
                    UniParserGrammarTreeNodeExpressionList* frontList = nil;
                    UniParserGrammarTreeNodeExpressionList* backlist = createType3Tree(node, separatorNode, &frontList);
                    currentList.node2 = frontList;
                    currentList = backlist;
                }
            }
            
            // case Type 4 (LAST node)
            
            else {

                if ([node isKindOfClass:[UniParserGrammarTreeNodeOptionOne class]]) {

                    UniParserGrammarTreeNode* endNode = createType4TreeWithOption(node, separatorNode);
                    currentList.node2 = endNode;
                }
                else {
                    
                    UniParserGrammarTreeNode* endNode = createType4Tree(node, separatorNode);
                    currentList.node2 = endNode;
                }
            }
        }
        
        rootNode = rootList;
    }

    return rootNode;
}


- (UniParserGrammarTreeNode*) _handleFunctionSetIf {
    
    NSString* varName = [self _scanIdentifier];

    [self _consumeString:FUNCTION_ARGUMENTS_SEPARATOR];
    
    UniParserGrammarTreeNode* node = [self _scanExpression];

    [node addFunction:[NSString stringWithFormat:@"set_if %@", varName]];
    
    [self _consumeString:FUNCTION_ARGUMENTS_CLOSE];
    
    return node;
}


- (UniParserGrammarTreeNode*) _handleFunctionSetIf2 {

    // format: &set_if2(varname, "value", expression)
    
    NSString* varName = [self _scanIdentifier];
    
    [self _consumeString:FUNCTION_ARGUMENTS_SEPARATOR];
    
    NSString* value;
    BOOL success = [self _scanStringInQuotes:&value];

    [self _consumeString:FUNCTION_ARGUMENTS_SEPARATOR];

    UniParserGrammarTreeNode* node = [self _scanExpression];
    
    [node addFunction:[NSString stringWithFormat:@"set_if2 %@ %@", varName, value]];
    
    [self _consumeString:FUNCTION_ARGUMENTS_CLOSE];
    
    return node;
}


- (UniParserGrammarTreeNode*) _handleFunctionIfSet {
    
    NSString* varName = [self _scanIdentifier];
    
    [self _consumeString:FUNCTION_ARGUMENTS_SEPARATOR];
    
    UniParserGrammarTreeNode* nodeTrue = [self _scanExpression];

    BOOL success = [self _matchString:FUNCTION_ARGUMENTS_SEPARATOR];

    UniParserGrammarTreeNode* nodeFalse = nil;
    
    if (success) {
    
        nodeFalse = [self _scanExpression];
    }
    
    [self _consumeString:FUNCTION_ARGUMENTS_CLOSE];
    
    UniParserGrammarTreeNodeConditional* conditional = [[UniParserGrammarTreeNodeConditional alloc] init];
    conditional.nodeTrue = nodeTrue;
    conditional.nodeFalse = nodeFalse;
    [conditional addFunction:[NSString stringWithFormat:@"var_is_set %@", varName]];
    
    return conditional;
}


- (UniParserGrammarTreeNode*) _handleFunctionNotFound {
    
    UniParserGrammarTreeNodeFalse* node = [[UniParserGrammarTreeNodeFalse alloc] init];

    [self _consumeString:FUNCTION_ARGUMENTS_CLOSE];

    return node;
}







#pragma mark - Save/restore scan location

- (void) _pushScanLocation {
    
    [_scanLocationStack addObject:@(_scanner.scanLocation)];
}


- (void) _restoreScanLocation {

    if (_scanLocationStack.count > 0) {
        
        _scanner.scanLocation = [self _popScanLocation];
    }
    else {
        
        [self _error:@"Tried to over-pop scan location stack"];
    }
}


- (uint) _popScanLocation {
    
    uint location = [[_scanLocationStack lastObject] intValue];
    [_scanLocationStack removeLastObject];
    
    return location;
}





#pragma mark - Tests

- (void) _testNonterminals {
    
    for (NSString* nonterminal in _referencedNonterminals) {
        
        BOOL success = [self hasProductionNamed:nonterminal];
        
        if (!success) {
            
            [self _error:[NSString stringWithFormat:@"No production rule found for referenced nonterminal \"%@\"", nonterminal]];
        }
    }
}




#pragma mark - Printing

- (void) _printProductions {

//    [self logSeparator];
    
    for (NSString* productionName in _productionDict.allKeys) {
        
        UniParserGrammarTreeNodeProduction* production = _productionDict[productionName];
        
        [self logString:[NSString stringWithFormat:@"%@", production] withColor:nil];
    }
}




#pragma mark - Error reporting

- (void) _error:(NSString*) string, ... {
    
    va_list args;
    va_start(args, string);
    
    NSString* message = [[NSString alloc] initWithFormat:string arguments:args];
    
    NSRange range = NSMakeRange(_scanner.scanLocation - _currentToken.length, _currentToken.length);
    
    if ([_scanner isAtEnd]) {
     
        NSLog(@"UniParserGrammarTree error: %@ (location=%d (end-of-file))", message, range.location);
    }
    else {

        NSLog(@"UniParserGrammarTree error: %@ (location=%d, string=\"%@\")", message, range.location, [self _parserStringForRange:range radius:ERROR_REPORT_STRING_RADIUS]);
    }
    
    va_end(args);
    
    exit(0);
}


- (NSString*) _parserStringForRange:(NSRange) range radius:(int) radius {
    
    NSString* string = _scanner.string;
    uint beginIndex = ((int)range.location - radius >= 0) ? range.location - radius : 0;
    uint endIndex = (range.location + range.length + radius < string.length) ? range.location + range.length + radius : string.length - 1;
    
    NSString* substring = [string substringWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)];
    
    NSRange modifiedRange = NSMakeRange(range.location - beginIndex, range.length);
    
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



#pragma mark - Temp

- (void) logString:(NSString*) string withColor:(UIColor*) color {
    
    NSLog(@"%@", string);
    
//    [[UIApplication sharedApplication].delegate performSelector:@selector(logString:withColor:) withObject:string withObject:color];
}


- (void) logSeparator {
    
//    [[UIApplication sharedApplication].delegate performSelector:@selector(logSeparator) withObject:nil];
}


@end





