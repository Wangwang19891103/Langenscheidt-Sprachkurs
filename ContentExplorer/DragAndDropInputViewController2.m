//
//  DragAndDropInputViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "DragAndDropInputViewController.h"
#import "UIView+Extensions.h"
#import "NSArray+Extensions.h"


@implementation DragAndDropInputViewController

@synthesize strings;
@synthesize collectionView;
@synthesize dragAndDropInputView;


- (id) initWithStrings:(NSArray*) p_strings {
    
    //    self = [super initWithNibName:@"ScrambledLettersInputViewController" bundle:[NSBundle mainBundle]];
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]  instantiateViewControllerWithIdentifier:@"DragAndDropInputViewController"];
    
    strings = p_strings;
    
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self _populateCollectionView];
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self.inputView setFrameHeight:self.collectionView.collectionViewLayout.collectionViewContentSize.height];
    
}


- (void) _populateCollectionView {
    
    NSMutableArray* items = [NSMutableArray array];
    
    for (NSString* string in self.strings) {
        
        [items addObject:[string lowercaseString]];
    }
    
    _items = [NSArray randomizedArrayFromArray:items];
    
    NSLog(@"%@", _items);
}


- (DragAndDropInputViewCell*) _createCellForString:(NSString*) string {
    
    DragAndDropInputViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell2" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [cell.button setTitle:string forState:UIControlStateNormal];
    
    return cell;
}


- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _items.count;
}


- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    UICollectionViewCell* cell = _items[indexPath.row];

//     DragAndDropInputViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell2" forIndexPath:indexPath];
//    [cell.button setTitle:_items[indexPath.row] forState:UIControlStateNormal];
//
//    assert(!CGSizeEqualToSize(cell.bounds.size, CGSizeZero));
//    
//    return cell.bounds.size;
    
    return [self sizeForButtonWithString:_items[indexPath.row]];
}


//- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    
//    return UIEdgeInsetsZero;
//}
//
//
//- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return 10;
//}
//
//
//- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return 10;
//}
//
//
//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    
//    return CGSizeZero;
//}
//
//
//- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    
//    return CGSizeZero;
//}


- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    return _items[indexPath.row];
    
     DragAndDropInputViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ButtonCell2" forIndexPath:indexPath];
    [cell.button setTitle:_items[indexPath.row] forState:UIControlStateNormal];
    cell.button.titleLabel.font = [self buttonFont];
    cell.button.tag = indexPath.row;
    
    return cell;
}


- (UIFont*) buttonFont {
    
    UIFont* font = nil;
    
    if ([self.dragAndDropInputView.buttonFontName isEqualToString:@"System"]) {
        
        font = [UIFont systemFontOfSize:self.dragAndDropInputView.buttonFontSize];
    }
    else {
        
        font = [UIFont fontWithName:self.dragAndDropInputView.buttonFontName size:self.dragAndDropInputView.buttonFontSize];
    }

    return font;
}


- (CGSize) sizeForButtonWithString:(NSString*) string {

    UIFont* buttonFont = [self buttonFont];
    
    NSDictionary* attributes = @{NSFontAttributeName : buttonFont};
    CGRect textRect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    textRect.size.width += self.dragAndDropInputView.buttonSideInsets * 2;
    textRect.size.height = self.dragAndDropInputView.buttonHeight;
    
    return textRect.size;
}


- (IBAction) actionButtonTap:(UIButton *)sender {
    
    NSString* string = _items[sender.tag];
    
    NSString* currentString = self.textDocumentProxy.documentContextBeforeInput;
    
    for (uint i = 0; i < currentString.length; ++i) {
        
        [self.textDocumentProxy deleteBackward];
    }
    
    [self.textDocumentProxy insertText:string];
}


@end





@implementation DragAndDropInputViewCell

@synthesize button;



@end