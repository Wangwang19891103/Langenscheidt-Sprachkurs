//
//  PhotoCreditsCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "PhotoCreditsCell.h"
#import "ContentManager.h"
#import "PhotoCreditsViewController.h"



static NSMutableDictionary* __resizedImageCache = nil;
static dispatch_once_t __onceToken;




@implementation PhotoCreditsCell


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}




#pragma mark - Reset

- (void) _reset {
    
    _titleLabel.text = nil;
    _creditsLabel.text = nil;
    _visible = NO;
    _getResizedImageBlock = nil;
    _photoImageView.image = nil;
}





#pragma mark - UITableViewCell

- (void) prepareForReuse {
    
    [super prepareForReuse];

    [self _reset];
}



#pragma mark - Set Visible

- (void) setVisible:(BOOL)visible {

    _visible = visible;
    
    if (_visible) {
    
        [self _loadDataAsync];
    }
    else {
        
        [self _reset];
    }
}



#pragma mark - Load Data

- (void) _loadDataAsync {
    
    __weak PhotoCreditsCell* weakself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{  // dispatch request to fill data for cell to background queue
        
        if (_visible) {  // if cell is still visible dispatch fill data to main queue
        
//            sleep(1);

            
            // setting labels text
            
            [weakself _setLabels];
            
            
            // setting resized image
            
            _getResizedImageBlock = ^(UIImage* resizedImage) {
                
                [weakself _setImage:resizedImage];
            };
            
            [PhotoCreditsCell _getResizedImageForCell:weakself withCompletionBlock:_getResizedImageBlock];
        }
    });
}


- (void) _setLabels {

    dispatch_async(dispatch_get_main_queue(), ^{

//        NSLog(@"setting labels for vocabulary: %@", self.vocabulary.textLang2);
        
        
        _titleLabel.text = _item.title;
        _creditsLabel.text = _item.credits;
    });
}


- (void) _setImage:(UIImage*) image {

    if (_visible) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            NSLog(@"setting resized image for vocabulary: %@", self.vocabulary.textLang2);
            
//            _photoImageView.backgroundColor = [UIColor lightGrayColor];
            _photoImageView.image = image;
        });
    }
    else {
        
        NSLog(@"wanted to set image, but cell no longer visible");
    }
}




#pragma mark - Resized Image Cache

+ (void) _initializeResizedImageCacheIfNeeded {
    
    dispatch_once(&__onceToken, ^{
        
        NSLog(@"creating resized image cache");
        
        __resizedImageCache = [NSMutableDictionary dictionary];
    });
}


+ (UIImage*) _getResizedImageFromCacheForCell:(PhotoCreditsCell*) cell {

    [PhotoCreditsCell _initializeResizedImageCacheIfNeeded];

    UIImage* resizedImage = __resizedImageCache[@(cell.item.id)];

    return resizedImage;
}


+ (void) _setResizedImageForCache:(UIImage*) image cell:(PhotoCreditsCell*) cell {
    
    [PhotoCreditsCell _initializeResizedImageCacheIfNeeded];

    [__resizedImageCache setObject:image forKey:@(cell.item.id)];
}





#pragma mark - Get Resized Image

+ (void) _getResizedImageForCell:(PhotoCreditsCell*) cell withCompletionBlock:(void(^)()) completionBlock {
    
    // this method gets called delayed from a dispatch block on background queue
    
    if (!cell.visible || !completionBlock) return;  // if cell turned invisible in the meantime do nothing
    
    // --------------
    
    UIImage* resizedImage = [PhotoCreditsCell _getResizedImageFromCacheForCell:cell];
    
    if (resizedImage) {

//        NSLog(@"FOUND - %@", vocabulary.textLang2);
        
        completionBlock(resizedImage);
    }
    else {
        
        [PhotoCreditsCell _createResizedImageForCell:cell withCompletionBlock:^(UIImage *resizedImage) {
            
            completionBlock(resizedImage);
        }];
    }
}


+ (void) _createResizedImageForCell:(PhotoCreditsCell*) cell withCompletionBlock:(void(^)(UIImage* resizedImage)) completionBlock {

    NSLog(@"creating resized image for vocabulary: %@", cell.item.title);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImage* image = [PhotoCreditsCell _getImageForItem:cell.item];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            if (!cell.visible) return;
            
            // -----------------
            
            CGSize sourceImageSize = image.size;
            CGSize imageViewSize = cell.photoImageView.frame.size;
            CGRect drawingRect = [PhotoCreditsCell _centerSize:sourceImageSize inSizeUsingAspectFit:imageViewSize];
            
            UIGraphicsBeginImageContextWithOptions(imageViewSize, FALSE, 0.0f);
            
            [image drawInRect:drawingRect];
            
            UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [PhotoCreditsCell _setResizedImageForCache:resizedImage cell:cell];
            
            completionBlock(resizedImage);
            
        });
    });
    
    
}


+ (UIImage*) _getImageForItem:(PhotoCreditsItem*) item {
    
    UIImage* image = nil;
    
    if (item.isVocabulary) {
        
        Lesson* lesson = [[ContentDataManager instance] lessonForVocabularyWithID:item.vocabularyID];
        image = [[ContentManager instance] smallVocabularyImageNamed:item.imageFile forLesson:lesson];
    }
    else {
        
        NSString* filePath = [[[NSBundle mainBundle] pathForResource:@"Menu Photos" ofType:nil] stringByAppendingPathComponent:item.imageFile];
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    
    return image;
}


+ (CGRect) _centerSize:(CGSize) size inSizeUsingAspectFit:(CGSize) size2 {
    
    CGFloat ratioW = size2.width / size.width;
    CGFloat ratioH = size2.height / size.height;
    float ratioToUse = MIN(ratioW, ratioH);
    
    CGRect centerRect;
    
    centerRect.size.width = size.width * ratioToUse;
    centerRect.size.height = size.height * ratioToUse;
    
    centerRect.origin.x = (size2.width - centerRect.size.width) * 0.5;
    centerRect.origin.y = (size2.height - centerRect.size.height) * 0.5;
    
    return centerRect;
}



+ (void) cleanImageCache {
    
    NSLog(@"PhotoCreditsCell - cleaning image cache");
    
    __resizedImageCache = nil;
}


@end
