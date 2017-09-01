//
//  DataManager.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef enum {
    DataManagerStoreLocationBundle,
    DataManagerStoreLocationDocuments,
    DataManagerStoreLocationUbiquityContainer
    
} DataManagerStoreLocation;

@interface DataManager : NSObject {
    
    NSManagedObjectContext* _context;
    
//    UIManagedDocument* _managedDocument;
}

//- (id) initWithModelName:(NSString*) modelName storeName:(NSString*) storeName location:(DataManagerStoreLocation) location;

//- (id) initWithModelName:(NSString*) modelName path:(NSString *)path;

//+ (DataManager*) sharedInstance;

//+ (DataManager*) contentInstance;
//+ (DataManager*) importedContentInstance;
//+ (DataManager*) playerInstance;

+ (DataManager*) instanceNamed:(NSString*) name;

+ (DataManager*) instanceInBundleNamed:(NSString *)name;


//+ (DataManager*) instanceInUbiquityContainerNamed:(NSString*) name;

- (void) addStoreInDocumentsWithPath:(NSString*) path;

- (id) insertNewObjectForEntityName:(NSString*) name;

- (NSArray*) fetchDataForEntityName:(NSString*) name withPredicate: (NSPredicate*) predicate sortedBy: (NSString*) firstSorter, ...;

- (id) fetchOrCreateObjectForEntityName:(NSString*) name withPredcate:(NSPredicate*) predicate;

- (NSArray*) executeFetchRequest:(NSFetchRequest*) request error:(NSError**) error;

- (NSManagedObject*) createUnmanagedObjectForEntityName:(NSString*) entityName;

- (int) countForEntity:(NSString*) entityName;

- (void) deleteObject:(id) object;

- (void) save;
- (void) clearStore;
- (void) handleError:(NSError*) error;

//- (void) copyDatabase;


- (float) calculateSumForEntityName:(NSString*) entityName withPredicate:(NSPredicate*) predicate attribute:(NSString*) attribute;

@end

