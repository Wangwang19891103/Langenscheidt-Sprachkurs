//
//  DialogLine+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DialogLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialogLine (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *audioFile;
@property (nullable, nonatomic, retain) NSString *audioRange;
@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *popupFile;
@property (nullable, nonatomic, retain) NSString *speaker;
@property (nullable, nonatomic, retain) NSString *textLang1;
@property (nullable, nonatomic, retain) NSString *textLang2;
@property (nullable, nonatomic, retain) NSString *vocabularyIDs;
@property (nullable, nonatomic, retain) Exercise *exercise;

@end

NS_ASSUME_NONNULL_END
