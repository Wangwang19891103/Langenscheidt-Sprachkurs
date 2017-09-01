//
//  ScrambledLettersInputViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 20.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ScrambledLettersInputViewController.h"
#import "NSArray+Extensions.h"

@implementation ScrambledLettersInputViewController

@synthesize strings;
@synthesize collectionView;
@synthesize collectionViewHeightConstraint;


//(
// "<NSLayoutConstraint:0x7fc622643580 V:|-(0)-[UIInputView:0x7fc6224dfe90]   (Names: '|':UIInputSetHostView:0x7fc622632810 )>",
// "<NSAutoresizingMaskLayoutConstraint:0x7fc62480b140 h=--& v=--& UIInputView:0x7fc6224dfe90.midY == + 30>",
// "<NSAutoresizingMaskLayoutConstraint:0x7fc62480bad0 h=--& v=--& V:[UIInputView:0x7fc6224dfe90(568)]>"
// )
//
//Will attempt to recover by breaking constraint
//<NSLayoutConstraint:0x7fc622643580 V:|-(0)-[UIInputView:0x7fc6224dfe90]   (Names: '|':UIInputSetHostView:0x7fc622632810 )>



- (id) initWithStrings:(NSArray*) p_strings {
    
//    self = [super initWithNibName:@"ScrambledLettersInputViewController" bundle:[NSBundle mainBundle]];
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]  instantiateViewControllerWithIdentifier:@"ScrambledLettersInputViewController"];
    
    strings = p_strings;
    
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self _populateCollectionView];
    
//    self.inputView.translatesAutoresizingMaskIntoConstraints = NO;
    
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

//    self.collectionViewHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    
//    [self.inputView setFrameHeight:self.collectionView.collectionViewLayout.collectionViewContentSize.height];
    
    self.inputView.frame = ({
    
        CGRect newRect = self.inputView.frame;
        newRect.size.height = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
        
        newRect;
    });
    
}


- (void) _populateCollectionView {
    
    NSString* solutionString = self.strings[0];
    NSMutableArray* items = [NSMutableArray array];

    NSArray* words = [solutionString componentsSeparatedByString:@" "];
    uint index = 0;
    
    for (NSString* word in words) {
        
        NSMutableArray* subItems = [NSMutableArray array];
        
        for (uint i = 0; i < word.length; ++i) {
            
            NSString* charString = [[word substringWithRange:NSMakeRange(i, 1)] lowercaseString];
            
            [subItems addObject:charString];
        }
        
        NSArray* subItems2 = [NSArray randomizedArrayFromArray:subItems];
        
        [items addObjectsFromArray:subItems2];
        
        
        if (index != words.count -1) {
            
            [items addObject:@" "];
        }
        
        
        ++index;
    }
    
    _items = items;
    
    NSLog(@"%@", _items);
}



#pragma mark - UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _items.count;
}


- (UICollectionViewCell*) collectionView:(UICollectionView *)p_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ScrambledLettersInputViewCell* cell = [p_collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell" forIndexPath:indexPath];
    
    [cell.button setTitle:_items[indexPath.row] forState:UIControlStateNormal];
    cell.button.tag = indexPath.row;
    
    return cell;
}


//- (BOOL) collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return YES;
//}


- (IBAction) actionType:(UIButton*)sender {
    
    NSInteger index = sender.tag;
    NSString* charString = _items[index];
    [self.textDocumentProxy insertText:charString];
}


- (IBAction) actionDelete {
    
    [self.textDocumentProxy deleteBackward];
}




@end



@implementation ScrambledLettersInputViewCell

@synthesize button;

@end