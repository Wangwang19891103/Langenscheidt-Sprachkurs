//
//  DataManager2.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DataManager2.h"
#import "ObjectOrNull.h"


@implementation DataManager2


static NSMutableDictionary* __instances = nil;



#pragma mark - Init / Create Instance

- (instancetype) initWithModelName:(NSString*) modelName {
    
    self = [super init];
    
    
    // ManagedObjectModel
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];

    if (!modelURL) {
        
        modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"mom"];
    }
    
    if (!modelURL) {
        
        @throw  [NSException exceptionWithName:@"DataManagerModelNotFoundException"
                                        reason:@"Model URL not found."
                                      userInfo:@{
                                                 @"modelName" : ObjectOrNull(modelName),
                                                 @"URL" : ObjectOrNull(modelURL)
                                                 }];
    }
    
    NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    
    // PersistentStoreCoordinator
    
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    
   // ManagedObjectContext
        
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    
    
    // stores array
    
    _stores = [NSMutableDictionary dictionary];
    
    
    
    return self;
}


+ (instancetype) createInstanceWithName:(NSString*) instanceName modelName:(NSString*) modelName {

    if ([[DataManager2 _instances] objectForKey:instanceName]) {
        
        @throw [NSException exceptionWithName:@"DataManagerInstanceCannotBeCreatedException"
                                       reason:@"Instance already exists."
                                     userInfo:@{
                                                @"instanceName" : ObjectOrNull(instanceName)
                                                }];
    }
    
    DataManager2* instance = [[DataManager2 alloc] initWithModelName:modelName];
    
    [[DataManager2 _instances] setObject:instance forKey:instanceName];
    
    
    return instance;
}


+ (instancetype) instanceNamed:(NSString*) instanceName {
    
    DataManager2* instance = [[DataManager2 _instances] objectForKey:instanceName];
    
    if (!instance) {
        
        @throw [NSException exceptionWithName:@"DataManagerInstanceNotFoundException"
                                       reason:@"Instance not found."
                                     userInfo:@{
                                                @"instanceName" : ObjectOrNull(instanceName)
                                                }];
    }
    
    return instance;
}


+ (NSMutableDictionary*) _instances {
    
    @synchronized (self) {

        if (!__instances) {
            
            __instances = [NSMutableDictionary dictionary];
        }

        return __instances;
    }
}




#pragma mark - Adding Stores with Configurations

- (void) addStoreWithName:(NSString*) storeName configuration:(NSString*) configuration location:(DataManagerStoreLocation) location {
    
    NSURL *storeURL;
    NSMutableDictionary *options = [NSMutableDictionary dictionary];

    [options setObject:@{@"journal_mode" : @"DELETE"} forKey:NSSQLitePragmasOption];  // WAL off  (does it work?)
    
    
    switch (location) {
            
        case DataManagerStoreLocationDocuments:
        {
            NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSString* fullStoreName = [NSString stringWithFormat:@"%@.sqlite", storeName];
            storeURL = [documentsDirectory URLByAppendingPathComponent:fullStoreName];
            
            [options setObject:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:@YES forKey:NSInferMappingModelAutomaticallyOption];
            
            break;
        }
            
        case DataManagerStoreLocationBundle:
        {
            NSString* fullPath = [NSString stringWithFormat:@"%@", storeName];
            storeURL = [[NSBundle mainBundle] URLForResource:fullPath withExtension:@"sqlite"];
            
            [options setObject:@(true) forKey:NSReadOnlyPersistentStoreOption];
            
            break;
        }
            
        default:
            break;
    }
    
    NSError* error;
    
    NSPersistentStore* store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:options error:&error];

    if (error) {
        
        @throw [NSException exceptionWithName:@"DataManagerCannotAddStoreException"
                                       reason:@"Cannot add persistant store."
                                     userInfo:@{
                                                @"storeName" : ObjectOrNull(storeName),
                                                @"configuration" : ObjectOrNull(configuration),
                                                @"location" : @(location),
                                                @"error" : error
                                                }];
    }
    else {
        
        [_stores setObject:store forKey:storeName];
        NSLog(@"Please find me %@",storeURL);
    }
}


- (void) addStoreAtPath:(NSString*) storePath withConfiguration:(NSString*) configuration {
    
    NSString* storeName = [self _randomStoreName];
    
    [self addStoreAtPath:storePath withName:storeName configuration:configuration];
}


- (void) addStoreAtPath:(NSString*) storePath withName:(NSString*) storeName configuration:(NSString*) configuration {

    NSURL* storeURL = [NSURL fileURLWithPath:storePath];
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    [options setObject:@{@"journal_mode" : @"DELETE"} forKey:NSSQLitePragmasOption];  // WAL off  (does it work?)
    [options setObject:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:@YES forKey:NSInferMappingModelAutomaticallyOption];
    
    NSError* error;
    
    NSPersistentStore* store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:options error:&error];
    
    if (error) {
        
        @throw [NSException exceptionWithName:@"DataManagerCannotAddStoreException"
                                       reason:@"Cannot add persistant store."
                                     userInfo:@{
                                                @"storePath" : ObjectOrNull(storePath),
                                                @"configuration" : ObjectOrNull(configuration),
                                                @"error" : error
                                                }];
    }
    else {
        
        [_stores setObject:store forKey:storeName];
    }
}


- (NSPersistentStore*) storeNamed:(NSString *)storeName {
    
    NSPersistentStore* store = _stores[storeName];
    
    if (!store) {
        
        @throw [NSException exceptionWithName:@"DataManagerStoreNotFound"
                                       reason:@"Store not found."
                                     userInfo:@{
                                                @"storeName" : ObjectOrNull(storeName),
                                                }];
    }
    
    return store;
}


- (void) removeStoreWithName:(NSString*) storeName {
    
    NSPersistentStore* store = _stores[storeName];
    NSError* error = nil;
    
    if (store) {
        
        [_coordinator removePersistentStore:store error:&error];
        
        if (error) {
            
            NSLog(@"Error: %@", error);
        }
        
        [_stores removeObjectForKey:storeName];
    }
}


//- (void) removeAllStores {
//    
//    NSError* error;
//    
//    for (NSPersistentStore* store in _coordinator.persistentStores) {
//        
//        [_coordinator removePersistentStore:store error:&error];
//        
//        if (error) {
//            
//            NSLog(@"error: %@", error);
//        }
//    }
//    
//    [_stores removeAllObjects];
//}



#pragma mark - Insert Managed Objects

- (id) insertObjectWithEntityName:(NSString*) entityName intoStoreNamed:(NSString*) storeName {
    
    NSManagedObject* object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                            inManagedObjectContext:_context];
    
    NSPersistentStore* store = [self storeNamed:storeName];
    
    [_context assignObject:object toPersistentStore:store];
    
    return object;
}




#pragma mark - Fetching Managed Objects

- (NSArray*) fetchDataForEntityName:(NSString*) name withPredicate: (NSPredicate*) predicate sortedBy: (NSString*) firstSorter, ... {
    
    // SortDescriptors erstellen
    
    NSMutableArray* sortDescriptors = [NSMutableArray array];
    va_list arguments;
    
    if (firstSorter) {
        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:firstSorter ascending:YES]];
        va_start(arguments, firstSorter);
        NSString* anotherString;
        while ((anotherString = va_arg(arguments, NSString*))) {
            [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:anotherString ascending:YES]];
        }
        va_end(arguments);
    }
    
    // Request
    NSArray* results;
    NSError* error;
    
    @synchronized(self) {
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:_context]];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        results = [_context executeFetchRequest:request error:&error];
    }
    
    if (error) {
        
        @throw [NSException exceptionWithName:@"DataManagerFailedFetchRequestException"
                                       reason:@"Failed fetch request."
                                     userInfo:@{
                                                @"error" : error
                                                }];
    }
    
    return results;
}




#pragma mark - Save

- (void) save {
    
    NSError* error;
    
    BOOL hasChanges = [_context hasChanges];
    
    if (hasChanges) {
    
        BOOL success = [_context save:&error];
        
        if (!success) {
            
            @throw [NSException exceptionWithName:@"DataManagerFailedToSaveContextException"
                                           reason:@"Failed to save context."
                                         userInfo:@{
                                                    @"error" : error
                                                    }];
        }
    }
}




#pragma mark - Clear store

- (void) clearAllStores {

    for (NSString* storeName in _stores.allKeys) {
        
        [self clearStoreNamed:storeName];
    }
}


- (void) clearStoreNamed:(NSString*) storeName {
    
    NSPersistentStore* store = [self storeNamed:storeName];
    NSURL* storeURL = [_coordinator URLForPersistentStore:store];
    NSError* error;
    
    
    // delete store file
    
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];

    if (error) {
        
        @throw [NSException exceptionWithName:@"DataManagerFailedToClearStoreException"
                                       reason:@"Failed to clear store."
                                     userInfo:@{
                                                @"storeName" : ObjectOrNull(storeName),
                                                @"error" : error
                                                }];
    }
    
    
    // remove persistant store from coordinator
    
    [_coordinator removePersistentStore:store error:&error];
    
    
    // recreate store
    
    [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:store.configurationName URL:store.URL options:store.options error:&error];
    
    if (error) {
        
        @throw [NSException exceptionWithName:@"DataManagerFailedToClearStoreException"
                                       reason:@"Failed to clear store."
                                     userInfo:@{
                                                @"storeName" : ObjectOrNull(storeName),
                                                @"error" : error
                                                }];
    }
}





#pragma mark - Utility

- (NSString*) _randomStoreName {
    
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    NSString* storeName = [NSString stringWithFormat:@"%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);

    return storeName;
}




#pragma mark - Test

- (void) test {
    
    NSArray* o = [_context insertedObjects];
    
    
}












@end
