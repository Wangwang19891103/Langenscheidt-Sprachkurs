//
//  ScrambledLettersInputViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 20.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ScrambledLettersInputViewController : UIInputViewController <UICollectionViewDataSource> {
    
    NSArray* _items;
}

@property (nonatomic, copy) NSArray* strings;

@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;


- (id) initWithStrings:(NSArray*) p_strings;

- (IBAction) actionDelete;
- (IBAction) actionType:(UIButton*) sender;

@end




@interface ScrambledLettersInputViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton* button;

@end
