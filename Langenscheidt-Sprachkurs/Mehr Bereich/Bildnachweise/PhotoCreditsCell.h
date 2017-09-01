//
//  PhotoCreditsCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Vocabulary.h"



@class PhotoCreditsItem;


@interface PhotoCreditsCell : UITableViewCell {
    
    BOOL _visible;
    
    void(^_getResizedImageBlock)(UIImage* resizedImage);
}

@property (nonatomic, strong) PhotoCreditsItem* item;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;

@property (nonatomic, readonly) BOOL visible;


- (void) setVisible:(BOOL) visible;



+ (void) cleanImageCache;

@end
