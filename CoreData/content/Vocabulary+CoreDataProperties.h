//
//  Vocabulary+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Vocabulary.h"

NS_ASSUME_NONNULL_BEGIN

@interface Vocabulary (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *audioFile;
@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *imageFile;
@property (nullable, nonatomic, retain) NSString *photoCredits;
@property (nullable, nonatomic, retain) NSString *popupFile;
@property (nullable, nonatomic, retain) NSString *prefixLang1;
@property (nullable, nonatomic, retain) NSString *prefixLang2;
@property (nullable, nonatomic, retain) NSString *textLang1;
@property (nullable, nonatomic, retain) NSString *textLang2;
@property (nullable, nonatomic, retain) Pearl *pearl;

@end

NS_ASSUME_NONNULL_END
