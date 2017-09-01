//
//  PhotoCreditsViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Vocabulary.h"


@interface PhotoCreditsViewController : UITableViewController {

    NSMutableArray* _items;

    NSInteger _currentItemIndex;
}

@end



@interface PhotoCreditsItem : NSObject

@property (nonatomic, copy) NSString* title;

@property (nonatomic, copy) NSString* credits;

@property (nonatomic, copy) NSString* imageFile;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) BOOL isVocabulary;

@property (nonatomic, assign) int32_t vocabularyID;

@end