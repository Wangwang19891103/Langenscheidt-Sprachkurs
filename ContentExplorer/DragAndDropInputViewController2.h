//
//  DragAndDropInputViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "DragAndDropInputView.h"

IB_DESIGNABLE


@interface DragAndDropInputViewController : UIInputViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
    NSArray* _items;
}

@property (nonatomic, copy) NSArray* strings;

@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@property (nonatomic, strong) IBOutlet DragAndDropInputView* dragAndDropInputView;


- (id) initWithStrings:(NSArray*) p_strings;

- (IBAction) actionButtonTap:(UIButton*) sender;

@end








@interface DragAndDropInputViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton* button;

@end