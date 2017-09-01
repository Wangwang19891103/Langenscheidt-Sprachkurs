//
//  VocabularyViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Pearl.h"


@interface VocabularyViewController : UIPageViewController <UIPageViewControllerDataSource> {
    
    NSArray* _vocabularies;
    NSMutableDictionary* _pages;
}

@property (nonatomic, assign) Pearl* pearl;

@end
