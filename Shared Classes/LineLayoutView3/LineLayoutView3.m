//
//  LineLayoutView3.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.03.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "LineLayoutView3.h"
#import "LineLayoutSpaceView.h"
#import "LineLayoutConnectionView.h"
#import "UIView+RemoveConstraints.h"



#define ANIMATION_DURATION          0.2

#define LINE_LAYOUT_VIEW_3_LOG_LEVEL_1      YES
#define LINE_LAYOUT_VIEW_3_LOG_LEVEL_2      YES


#define PREVIOUS_VIEW_IN_CURRENT_LINE       @"previousViewInCurrentLine"
#define HIGHEST_VIEW_IN_CURRENT_LINE        @"highestViewInCurrentLine"
#define HIGHEST_VIEW_IN_PREVIOUS_LINE       @"highestViewInPreviousLine"


/*
 * - non breaking space
 * - connection token
 * - non layouted subviews
 * - custom constraints
 * - fits in current line
 * - intersects with subviews
 *
 * ? constrain subview width (to self max width)
 * current line index
 * highestviewinpreviousline
 * after connection token loop back and putting a label now into the next line, there might be a spaceview before that label as a remainder at the end of that previous line -> remove possible spaceviews when placing subviews in new line
 *
 */


@implementation LineLayoutView3

@synthesize horizontalSpacing;
@synthesize verticalSpacing;
@synthesize verticalAlignment;



#pragma mark - Init


- (id) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.verticalAlignment = 0;
    self.horizontalSpacing = 0;
    self.verticalSpacing = 0;
//    [self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
//    [self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];

//    self.constrainSubviewWidth = YES;
    
    _waitingForLayout = YES;
}




#pragma mark - Control Token Views

- (void) addNonBreakingSpaceWithWidth:(CGFloat) width {
    
    LineLayoutSpaceView* spaceView = [[LineLayoutSpaceView alloc] init];
    spaceView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [spaceView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[spaceView(width)]" options:0 metrics:@{@"width" : @(width)} views:NSDictionaryOfVariableBindings(spaceView)]];
    
    [self addSubview:spaceView];
}


- (void) addConnectionToken {
    
    LineLayoutConnectionView* connectionView = [[LineLayoutConnectionView alloc] init];
    connectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [connectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[connectionView(0)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(connectionView)]];
    
    [self addSubview:connectionView];
}


- (BOOL) _viewIsNonBreakingSpace:(UIView*) view {
    
    return [view isKindOfClass:[LineLayoutSpaceView class]];
}


- (BOOL) _viewIsConnectionToken:(UIView*) view {
    
    BOOL is = [view isKindOfClass:[LineLayoutConnectionView class]];
    
    //    NSLog(@"isConnectionToken: %@ -- %@", is ? @"YES" : @"NO", view);
    
    return is;
}


- (BOOL) viewIsControlToken:(UIView*) view {
    
    return [self _viewIsNonBreakingSpace:view] || [self _viewIsConnectionToken:view];
}




#pragma mark - Intersecting Subviews

- (NSArray*) _subviewsIntersectingRect:(CGRect) rect regardingViews:(NSArray*) regardViews {
    
    NSMutableArray* subviewsIntersecting = [NSMutableArray array];
    
    for (UIView* subview in self.subviews) {
        
        
        if (![regardViews containsObject:subview]) continue;
        
        
        if ([self _subview:subview isIntersectingRect:rect]) {
            
            NSLog(@"intersect: %@, %@", NSStringFromCGRect(rect), subview);
            
            [subviewsIntersecting addObject:subview];
        }
    }
    
    return subviewsIntersecting;
}


- (BOOL) _subview:(UIView*) subview isIntersectingRect:(CGRect) rect {
    
    return CGRectIntersectsRect(subview.frame, rect);
}





#pragma mark - Special Layout constraints

- (BOOL) respectSubviewForLineLayout:(UIView*) subview {
    
    if ([self.delegate respondsToSelector:@selector(respectSubviewForLineLayout:)]) {
        
        return [self.delegate respectSubviewForLineLayout:subview];
    }
    else {
        
        return YES;
    }
}


- (NSArray*) customLayoutConstraintsForSubview:(UIView*) subview {
    
    if ([self.delegate respondsToSelector:@selector(lineLayoutView:customLayoutConstraintsForSubview:)]) {
        
        return [self.delegate lineLayoutView:self customLayoutConstraintsForSubview:subview];
    }
    else {
        
        return nil;
    }
}




#pragma mark - View, Layout, Constraints

+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (void) layoutSubviews {

    [super layoutSubviews];

    
    if (_finishedLayouting) return;

    
    _log(1, @"layoutSubviews (frame = %@)", NSStringFromCGRect(self.frame));
    
    
    
    if (_waitingForLayout) {
    
        _log(2, @"needs arrange subviews: yes");
        
        _waitingForLayout = NO;
        
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
    }
    else {
        
        _finishedLayouting = YES;
    }
    
    // what happens is: on first updateConstraints pass, no arrangeSubviews. when layout pass has arrive here for the first time (frame is calculated), a new updateConstraints pass including arrangeSubviews is initiated and a new layout pass (which doesnt arrive here?)
}


- (void) updateConstraints {

    if (_finishedLayouting) {
        
        [super updateConstraints];
        
        return;
    }
    
    
    
    _log(1, @"updateConstraints (frame = %@)", NSStringFromCGRect(self.frame));
    
//    [super layoutSubviews];

    if (!_waitingForLayout) {
    
        [self _arrangeSubviews];
    }
    
    [super updateConstraints];
}


- (BOOL) _needsArrangeSubviews {
    
    BOOL needsArrangeSubviews = _previousWidth != self.frame.size.width;
    
    _previousWidth = self.frame.size.width;
    
    return needsArrangeSubviews;
}



#pragma mark - Subview layour logic

- (void) _reset {
    
    _maxLineWidth = self.frame.size.width;
    
    _currentSubview = nil;
    _currentSubviewIndex = -1;  // starting index

    _subviewsToPlace = [NSMutableArray array];
    _placedLineLayoutedSubviewStack = [NSMutableArray array];
    _allPlacedSubviews = [NSMutableArray array];
    
    _previousViewInCurrentLine = nil;
    _highestViewInCurrentLine = nil;
    _highestViewInPreviousLine = nil;
}


- (void) _arrangeSubviews {

    _log(1, @"---------------------------- arrange subviews ---- (%@) ------(%@)-----------------", self.accessibilityIdentifier, NSStringFromCGRect(self.frame));

    
    [self _reset];
    
    
    
//    // self should have a non-zero frame size
//    
//    NSAssert(!CGSizeEqualToSize(self.frame.size, CGSizeZero), @"self has zero frame size");
    

    

    [self _beginNewLine];
    
    [self _increaseSubview];  // to index 0
    
    
    while (_currentSubviewIndex < self.subviews.count) {

        _log(2, @"main loop, subview: %@ (%d)", _currentSubview, _currentSubviewIndex);
        
        
        [self _resetSubviewsToPlace];

        
        // ------------------------- find subviews to place
        
        // case control token
        
        if ([self viewIsControlToken:_currentSubview]) {
        
            [self _handleControlToken];
        }

        
        // view should now be a non-control view. remove constraints and add to placed list
        
        NSAssert(![self viewIsControlToken:_currentSubview], @"subview after connection token loop back is still a control token");
        
        [self _removeConstraintsForCurrentSubview];
        
        [self _addSubviewToPlace];

        
        // remove connection token views
        
        [self _removeConnectionTokens];
        
        
        // placed list should now contain subviews
        
        NSAssert(_subviewsToPlace.count > 0, @"no subviews to be placed");
        
        _log(1, @"SUBVIEWS TO PLACE: %@", _subviewsToPlace);
        
        
        // ------------------------ checks for single played views

        // 1. respect for line layout
        
        if (![self respectSubviewForLineLayout:_currentSubview]) {
         
            [self _increaseSubview];

            continue;
        }

        
        // 2. custom constraints
        
        NSArray* customConstraints = [self customLayoutConstraintsForSubview:_currentSubview];
        
        if (customConstraints) {
            
            [self addConstraints:customConstraints];
            
            [self _addPlacedSubview:_currentSubview];
            
            [super layoutSubviews];  //? this is important?
            
            [self _increaseSubview];
            
            continue;
        }

        
        // 3. check if subviews to place fit in current line
        
        BOOL fitsInCurrentLine = [self _subviewsFitInCurrentLine];
        
        BOOL forceInCurrentLine = (_previousViewInCurrentLine == nil);
        
        if (fitsInCurrentLine) {
            
            _log(2, @"place subviews (%d) in current line", _subviewsToPlace.count);
            
            [self _placeSubviewsInCurrentLine];
        }
        else if (forceInCurrentLine) {
            
            _log(2, @"FORCE subviews (%d) in current line", _subviewsToPlace.count);
            
            [self _placeSubviewsInCurrentLine];
        }
        else {
            
            _log(2, @"place subviews (%d) in new line", _subviewsToPlace.count);
            
            [self _clearLeadingControlViews];
            
            [self _placeSubviewsInNewLine];
        }
        
        
        
        [super layoutSubviews];
        
        
        
        
        
        [self _increaseSubview];
    }
    
    
}


- (void) _placeSubviewsInCurrentLine {
    
    [self _placeSubviews];
}


- (void) _placeSubviewsInNewLine {
    
    [self _beginNewLine];

    [self _placeSubviews];
}


- (void) _beginNewLine {
    
    _highestViewInPreviousLine = _highestViewInCurrentLine;
    _highestViewInCurrentLine = nil;
    _previousViewInCurrentLine = nil;
//    ++_currentLineIndex;
}


- (void) _placeSubviews {
    
    _log(2, @"placing subviews.");
    _log(2, @"previous in line: %@", _previousViewInCurrentLine);
    _log(2, @"highest in current line: %@", _highestViewInCurrentLine);
    _log(2, @"highest in previous line: %@", _highestViewInPreviousLine);
    
    for (UIView* subview in _subviewsToPlace) {

        NSAssert(subview != _highestViewInPreviousLine, @"current subview is also highest subview in previous line");

        
        // constrain subview width to self width (max line width)
        
        if (self.constrainSubviewWidth) {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview(<=self)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview, self)]];
            
        }

        
        // horizontal constraints

        NSString* trailingConstraint = @"(>=right@1000,==right@800)";  // this order of priorities is important!
        NSString* formatString = nil;
        
        if (_previousViewInCurrentLine) {
            
            formatString = [NSString stringWithFormat:@"H:[_previousViewInCurrentLine]-(spacing@1000)-[subview]-%@-|", trailingConstraint];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:self.verticalAlignment metrics:@{@"spacing" : @(self.horizontalSpacing), @"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(_previousViewInCurrentLine, subview)]];
        }
        else {

            formatString = [NSString stringWithFormat:@"H:|-[subview]-%@-|", trailingConstraint];

            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:0 metrics:@{@"spacing" : @(self.horizontalSpacing), @"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(subview)]];
        }

        
        // vertical constraints
        
        if ([self _isFirstLine]) {  // first line
        
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[subview]-(>=bottom)-|" options:0 metrics:@{@"bottom" : @(self.layoutMargins.bottom)} views:NSDictionaryOfVariableBindings(subview)]];
        }
        else {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_highestViewInPreviousLine]-(spacing)-[subview]-(>=bottom)-|" options:0 metrics:@{@"bottom" : @(self.layoutMargins.bottom), @"spacing" : @(self.verticalSpacing)} views:NSDictionaryOfVariableBindings(_highestViewInPreviousLine, subview)]];
        }
        
        
        _previousViewInCurrentLine = subview;
        _highestViewInCurrentLine = (subview.frame.size.height > _highestViewInCurrentLine.frame.size.height) ? subview : _highestViewInCurrentLine;
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        
        dict[@"subview"] = subview;
        dict[PREVIOUS_VIEW_IN_CURRENT_LINE] = _previousViewInCurrentLine;
        dict[HIGHEST_VIEW_IN_CURRENT_LINE] = _highestViewInCurrentLine;
        dict[HIGHEST_VIEW_IN_PREVIOUS_LINE] = _highestViewInPreviousLine;
        
        [self _addPlacedLineLayoutedSubviewDictionaty:dict];

    }
}


- (void) _clearLeadingControlViews {
    
    uint i = 0;
    UIView* subview = _subviewsToPlace[i];
    NSMutableArray* newSubviewsToPlace = [NSMutableArray array];
    
    while (i < _subviewsToPlace.count && [self viewIsControlToken:subview]) {

        ++i;

        subview = _subviewsToPlace[i];
    }
    
    while (i < _subviewsToPlace.count) {
    
        subview = _subviewsToPlace[i];
        
        [newSubviewsToPlace addObject:subview];
        
        ++i;
    }
    
    _subviewsToPlace = newSubviewsToPlace;
}




#pragma mark - Handle Tokens


- (void) _handleControlToken {
    
    
    // case non breaking space
    
    if ([self _viewIsNonBreakingSpace:_currentSubview]) {
        
        _log(2, @"non breaking space (%d)", _currentSubviewIndex);
        
        
        // find next non-control view. add subviews along the way
        
        while (_currentSubviewIndex < self.subviews.count && [self viewIsControlToken:_currentSubview]) {

            
            // case connection token
            
            if ([self _viewIsConnectionToken:_currentSubview]) {
                
                // break and let next condition take care of connection token
                
                break;
            }
            
            
            [self _addSubviewToPlace];

            [self _increaseSubview];
        }
        
        
        // view should now be a non-control view. let arrangeSubviews main loop handle it.
    }
    
    
    // case connection token
    
    if ([self _viewIsConnectionToken:_currentSubview]) {
     
        _log(2, @"connection token (%d)", _currentSubviewIndex);
        
        
        [self _resetSubviewsToPlace];
        
        
        // 1. loop backwards and find next non-control view
        
        while (_currentSubviewIndex >= 0 && [self viewIsControlToken:_currentSubview]) {
            
            [self _removeConstraintsForCurrentSubview];
            
            [self _popPlacedLineLayoutedSubviewIfLast:_currentSubview];
            
            [self _decreaseSubview];
        }
        
        
        // 2. view should now be a non-control view. remove constraints and add to placed array
        
        _log(2, @"subview after loop back: %@", _currentSubview);
        
        NSAssert(![self viewIsControlToken:_currentSubview], @"subview after connection token loop back is still a control token");
        
        [self _removeConstraintsForCurrentSubview];
        
        [self _addSubviewToPlace];
        
        [self _popPlacedLineLayoutedSubviewIfLast:_currentSubview];
        
//        _previousViewInLine = _placedLineLayoutedSubviewStack.lastObject;
        
        _log(2, @"previousViewInLine: %@", _previousViewInCurrentLine);
        
        
        // 3. loop forwards and find next non-control view. add subviews along the way
        
        [self _increaseSubview];
        
        while (_currentSubviewIndex < self.subviews.count && [self viewIsControlToken:_currentSubview]) {
            
            [self _removeConstraintsForCurrentSubview];
            
            [self _addSubviewToPlace];
            
            [self _increaseSubview];
        }
        
        
        // 4. view should now be a non-control view. let arrange subviews main loop handle it
        
    }
}


- (void) _increaseSubview {
    
    ++_currentSubviewIndex;
    
    if (_currentSubviewIndex < self.subviews.count) {

        _currentSubview = self.subviews[_currentSubviewIndex];
    }
    else {
        
        _currentSubview = nil;
    }
    
//    [self _checkCurrentSubviewValid];
}


- (void) _decreaseSubview {
    
    --_currentSubviewIndex;
    _currentSubview = self.subviews[_currentSubviewIndex];

    [self _checkCurrentSubviewValid];
}


- (void) _addSubviewToPlace {
    
    [_subviewsToPlace addObject:_currentSubview];
}


- (void) _resetSubviewsToPlace {
    
    _subviewsToPlace = [NSMutableArray array];
}


- (void) _addPlacedLineLayoutedSubviewDictionaty:(NSDictionary*) dict {
    
    [_placedLineLayoutedSubviewStack addObject:dict];
    
    [self _addPlacedSubview:dict[@"subview"]];
}


- (void) _popPlacedLineLayoutedSubviewIfLast:(UIView*) subview {  //? does this work reliably? (found crash in course4, am telefon1, dialog)
    
    NSAssert(_placedLineLayoutedSubviewStack.count > 0, @"popping placed layouted subviews, out of bounds");

    NSDictionary* dict = nil;
    
    if ([(dict = _placedLineLayoutedSubviewStack.lastObject) objectForKey:@"subview"] == subview) {
    
        [_placedLineLayoutedSubviewStack removeObject:_placedLineLayoutedSubviewStack.lastObject];
        
        dict = _placedLineLayoutedSubviewStack.lastObject;
        
        _previousViewInCurrentLine = dict[PREVIOUS_VIEW_IN_CURRENT_LINE];
        _highestViewInCurrentLine = dict[HIGHEST_VIEW_IN_CURRENT_LINE];
        _highestViewInPreviousLine = dict[HIGHEST_VIEW_IN_PREVIOUS_LINE];
    }
    
    [self _removePlacedSubview:subview]; //? here or in the if statement
}


//- (UIView*) _highestViewInCurrentLine {
//    
//    NSDictionary* dict = _placedLineLayoutedSubviewStack.lastObject;
//    
//    return dict[@"highestView"];
//}
//
//
//- (UIView*) _previousViewInCurrentLine {
// 
//    NSDictionary* dict = _placedLineLayoutedSubviewStack.lastObject;
//    
//    return dict[@"previousView"];
//}


- (void) _addPlacedSubview:(UIView*) subview {
    
    [_allPlacedSubviews addObject:subview];
}


- (void) _removePlacedSubview:(UIView*) subview {

    [_allPlacedSubviews removeObject:subview];
}


- (void) _removeConnectionTokens {
    
    NSMutableArray* newSubviewsToPlace = [NSMutableArray array];
    
    for (UIView* subview in _subviewsToPlace) {
        
        if (![self _viewIsConnectionToken:subview]) {
            
            [newSubviewsToPlace addObject:subview];
        }
    }
    
    _subviewsToPlace = newSubviewsToPlace;
}


- (void) _removeConstraintsForCurrentSubview {
    
    [self removeConstraintsAffectingSubview:_currentSubview];
}


- (void) _checkCurrentSubviewValid {
    
    NSAssert(_currentSubviewIndex >= 0 && _currentSubviewIndex < self.subviews.count, @"currentSubviewIndex out of bounds");
    NSAssert(_currentSubview != nil, @"currentSubview is nil");
}


- (BOOL) _subviewsFitInCurrentLine {
    
    CGFloat posX, posY;
    
    if (_previousViewInCurrentLine) {
        
        CGRect previousViewFrameInSelfCoordinates = [self convertRect:_previousViewInCurrentLine.frame fromView:self];

        posX = (previousViewFrameInSelfCoordinates.origin.x + previousViewFrameInSelfCoordinates.size.width);
        posY = (previousViewFrameInSelfCoordinates.origin.y + previousViewFrameInSelfCoordinates.size.height);
    }
    else {
        
        posX = self.layoutMargins.left;
        posY = self.layoutMargins.top;
    }
    
    
    CGFloat widthOfSubviewsToPlace = [self _widthOfSubviewsToPlace];
    CGFloat heightOfSubviewsToPlace = [self _heightOfSubviewsToPlace];
    
    _log(2, @"width: %f, height: %f", widthOfSubviewsToPlace, heightOfSubviewsToPlace);
    
    
    // check if subviews to place intersect with any subviews if they would be placed together in the current line
    
    CGRect necessaryRect =
    ({
        CGFloat top = [self _isFirstLine] ? self.layoutMargins.top : self.verticalSpacing;
        CGFloat bottom = self.verticalSpacing;
        CGFloat right = self.horizontalSpacing;
        
        CGRectMake(posX, posY - top, widthOfSubviewsToPlace + right, heightOfSubviewsToPlace + top + bottom);
    });
    
    
    // check if there is a subview intersecting with necessaryRect

    BOOL intersecting = [[self _subviewsIntersectingRect:necessaryRect regardingViews:_allPlacedSubviews] count] != 0;
    
    _log(2, @"intersecting: %@", intersecting ? @"YES" : @"NO");
  
    
    CGFloat newLineWidth = posX + widthOfSubviewsToPlace + ((_previousViewInCurrentLine != nil) ? self.horizontalSpacing : 0) + self.layoutMargins.right;
    BOOL fitsInCurrentLine = newLineWidth <= _maxLineWidth;
    
    _log(2, @"fitsInCurrentLine width: %@ (%f / %f)", fitsInCurrentLine ? @"YES" : @"NO", newLineWidth, _maxLineWidth);

    
    return !intersecting && fitsInCurrentLine;
}


- (CGFloat) _widthOfSubviewsToPlace {
    
    CGFloat width = 0;
    
    for (UIView* subview in _subviewsToPlace) {
        
        width += subview.frame.size.width;
    }
    
    return width;
}


- (CGFloat) _heightOfSubviewsToPlace {

    // returns height of last subview in list
    
    return [_subviewsToPlace.lastObject frame].size.height;
}


- (BOOL) _isFirstLine {
    
    return (_highestViewInPreviousLine == nil);
}



#pragma mark - Logging

void _log(int level, NSString* format, ...) {
    
    va_list arguments;
    va_start(arguments, format);
    NSString* string = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    
    BOOL shouldLog = ({
 
        BOOL log;
        
        switch (level) {
            case 1:
                log = LINE_LAYOUT_VIEW_3_LOG_LEVEL_1;
                break;
                
            case 2:
                log = LINE_LAYOUT_VIEW_3_LOG_LEVEL_2;
                break;
                
            default:
                log = NO;
                break;
        }
        
        log;
    });
    
    if (shouldLog) {
        
        NSLog(@"[LineLayoutView3]: %@", string);
    }
}



@end































































