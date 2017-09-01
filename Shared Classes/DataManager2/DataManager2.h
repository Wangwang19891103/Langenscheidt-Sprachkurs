//
//  DataManager2.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;



#import "DataManager.h" // retrieve enum


//typedef NS_ENUM(NSInteger, DataManagerStoreLocation) {
//    
//    DataManagerStoreLocationBundle,
//    DataManagerStoreLocationDocuments
//    
//};





@interface DataManager2 : NSObject {
    
    NSPersistentStoreCoordinator* _coordinator;
    
    NSManagedObjectContext* _context;
    

}


@property (nonatomic, strong) NSMutableDictionary* stores;


#pragma mark - Init / Instances

+ (instancetype) createInstanceWithName:(NSString*) instanceName modelName:(NSString*) modelName;

+ (instancetype) instanceNamed:(NSString*) instanceName;

- (void) addStoreWithName:(NSString*) storeName configuration:(NSString*) configuration location:(DataManagerStoreLocation) location;

- (void) addStoreAtPath:(NSString*) storePath withConfiguration:(NSString*) configuration;

- (void) addStoreAtPath:(NSString*) storePath withName:(NSString*) storeName configuration:(NSString*) configuration;

- (NSPersistentStore*) storeNamed:(NSString*) storeName;

- (void) removeStoreWithName:(NSString*) storeName;

//- (void) removeAllStores;



#pragma mark - Insert Managed Objects

- (id) insertObjectWithEntityName:(NSString*) entityName intoStoreNamed:(NSString*) storeName;



#pragma mark - Fetching Managed Objects

- (NSArray*) fetchDataForEntityName:(NSString*) name withPredicate: (NSPredicate*) predicate sortedBy: (NSString*) firstSorter, ...;



#pragma mark - Save

- (void) save;



#pragma mark - Clear store

- (void) clearAllStores;

- (void) clearStoreNamed:(NSString*) storeName;



#pragma mark - Test

- (void) test;


    
@end
