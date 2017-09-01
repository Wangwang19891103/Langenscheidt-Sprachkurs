//
//  PhotoCreditsViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "PhotoCreditsViewController.h"
#import "PhotoCreditsCell.h"
#import "ContentManager.h"
#import "Lesson.h"
#import "ContentDataManager.h"
#import "LTracker.h"


@implementation PhotoCreditsViewController



#pragma mark - init 

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.navigationItem.title = @"Bildnachweis";
    
    _items = [NSMutableArray array];
    
    [self _loadMainMenuImage];
    [self _loadCourseImages];
    [self _loadLessonImages];
    [self _loadVocabularies];
    [self _sortItemsAlphabetically];
    
    return self;
}



- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Einstellungen - Bildnachweise");
    GATrackingSetTrackScreenViews(YES);

}


#pragma mark - Load Vocabularies, menu images

#pragma mark Vocabularies

- (void) _loadVocabularies {
    
    NSArray* vocabularies = [[ContentDataManager instance] allVocabularies];
    
    for (Vocabulary* vocabulary in vocabularies) {
        
        [self _createItemFromVocabulary:vocabulary];
    }
}


- (void) _createItemFromVocabulary:(Vocabulary*) vocabulary {
    
    PhotoCreditsItem* item = [[PhotoCreditsItem alloc] init];
    
    item.title = vocabulary.textLang2;
    item.credits = vocabulary.photoCredits;
    item.imageFile = vocabulary.imageFile;
    item.id = _currentItemIndex;
    item.isVocabulary = YES;
    item.vocabularyID = vocabulary.id;
    
    [_items addObject:item];
    
    ++_currentItemIndex;
}



#pragma mark Courses

- (void) _loadCourseImages {
    
    NSArray* courses = [[ContentDataManager instance] courses];
    
    for (Course* course in courses) {
        
        [self _createItemFromCourse:course];
    }
}


- (void) _createItemFromCourse:(Course*) course {
    
    PhotoCreditsItem* item = [[PhotoCreditsItem alloc] init];
    
    item.title = course.photoCreditsTitle;
    item.credits = course.photoCredits;
    item.imageFile = course.imageFile;
    item.id = _currentItemIndex;
    
    [_items addObject:item];
    
    ++_currentItemIndex;
}


#pragma mark Lessons

- (void) _loadLessonImages {
    
    NSArray* lessons = [[ContentDataManager instance] allLessons];

    NSMutableDictionary* lessonDictByImageFile = [NSMutableDictionary dictionary];
    
    for (Lesson* lesson in lessons) {

        [lessonDictByImageFile setObject:lesson forKey:lesson.imageFile];
    }

    for (NSString* imageFile in lessonDictByImageFile.allKeys) {
        
        Lesson* lesson = lessonDictByImageFile[imageFile];

        [self _createItemFromLesson:lesson];
    }
}


- (void) _createItemFromLesson:(Lesson*) lesson {
    
    PhotoCreditsItem* item = [[PhotoCreditsItem alloc] init];
    
    item.title = lesson.photoCreditsTitle;
    item.credits = lesson.photoCredits;
    item.imageFile = lesson.imageFile;
    item.id = _currentItemIndex;
    
    [_items addObject:item];
    
    ++_currentItemIndex;
}


#pragma mark Main Menu

- (void) _loadMainMenuImage {
    
    NSString* fileName = @"PhotoCredits.plist";
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSArray* entries = [NSArray arrayWithContentsOfFile:filePath];
    
    NSDictionary* dict = entries[0];
    
    PhotoCreditsItem* item = [[PhotoCreditsItem alloc] init];
    
    item.title = dict[@"title"];
    item.credits = dict[@"credits"];
    item.imageFile = dict[@"imageFile"];
    item.id = _currentItemIndex;
    
    [_items addObject:item];
    
    ++_currentItemIndex;
    
}


#pragma mark Sort alphabetically

- (void) _sortItemsAlphabetically {
    
    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray* sortedItems = [_items sortedArrayUsingDescriptors:@[descriptor]];
    
    _items = [sortedItems mutableCopy];
}




#pragma mark - UIViewController



#pragma mark - UITableViewDelegate/datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1 + _items.count;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        return 210;
    }
    else {
        
        return 78;
    }
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        
        return cell;
    }
    else {
        
        PhotoCreditsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotoCreditsCell"];
        
        PhotoCreditsItem* item = _items[indexPath.row - 1];
        
        [cell setItem:item];

        [cell setVisible:YES];
        
        return cell;
    }
}


- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
    }
    else {
        
        PhotoCreditsCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [cell setVisible:NO];
    }
}





#pragma mark - Dealloc {

- (void) dealloc {
    
    [PhotoCreditsCell cleanImageCache];
}



@end







@implementation PhotoCreditsItem


                              
@end
