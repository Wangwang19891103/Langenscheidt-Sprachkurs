//
//  DataManager.m
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 24.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "DataManager.h"
//#import "DeepDirectoryPrinter.h"
#import "SystemVersion.h"


@implementation DataManager

//@synthesize context = _context;


#pragma mark Initializer

- (id) initWithModelName:(NSString *)modelName storeName:(NSString *)storeName location:(DataManagerStoreLocation)location {
    
    if ((self = [super init])) {

        // ManagedObjectModel
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
        assert(modelURL);
        NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // PersistentStoreCoordinator

        NSURL *storeURL;
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        
            options = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                      NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"}
                                                                      }];  // turn off Write ahead logging (new in iOS7)
        }
        
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
                
            case DataManagerStoreLocationUbiquityContainer:
            {
                NSURL* ubiquityContainerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                NSURL* documentsURL = [ubiquityContainerURL URLByAppendingPathComponent:@"Documents"];
//                NSURL* coreDataURL = [ubiquityContainerURL URLByAppendingPathComponent:@"CoreData"];
//                NSURL* coreDataSupportURL = [documentsURL URLByAppendingPathComponent:@"CoreDataUbiquitySupport"];
//                
//                // print contents
//                NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:ubiquityContainerURL includingPropertiesForKeys:nil options:0 error:nil];
//                NSArray* documentsContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsURL includingPropertiesForKeys:nil options:0 error:nil];
//                NSArray* coreDataContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:coreDataURL includingPropertiesForKeys:nil options:0 error:nil];
//                NSArray* coreDataSupportContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:coreDataSupportURL includingPropertiesForKeys:nil options:0 error:nil];
//
//                NSLog(@"Ubiquity Container contents: %@", contents);
//                NSLog(@"Ubiquity Container \"Documents\" contents: %@", documentsContents);
//                NSLog(@"Ubiquity Container \"CoreData\" contents: %@", coreDataContents);
//                NSLog(@"Ubiquity Container \"Documents/CoreDataUbiquitySupport\" contents: %@", coreDataSupportContents);

//                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//                NSString* printFilePath = [documentsPath stringByAppendingPathComponent:@"ubiquityContainer.txt"];
//                NSURL* printFileURL = [NSURL fileURLWithPath:printFilePath];
//                [[DeepDirectoryPrinter instance] printDirectoryAtURL:ubiquityContainerURL toFileAtURL:printFileURL];
                
                //---------
                
                storeURL = [documentsURL URLByAppendingPathComponent:@"Data"];
                
                [options setObject:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
                [options setObject:@YES forKey:NSInferMappingModelAutomaticallyOption];
                [options setObject:storeName forKey:NSPersistentStoreUbiquitousContentNameKey];
                
//                _managedDocument = [[UIManagedDocument alloc] initWithFileURL:storeURL];
                NSError* error;
//                [_managedDocument configurePersistentStoreCoordinatorForURL:storeURL ofType:nil modelConfiguration:nil storeOptions:options error:&error];

                assert(!error);
                
                break;
            }
                
            default:
                break;
        }
        
        if (location == DataManagerStoreLocationUbiquityContainer) {

//            _context = _managedDocument.managedObjectContext;
        }
        else {
            NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
            NSError* error;
            
            if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
                [self handleError:error];
            
            // ManagedObjectContext
            
            _context = [[NSManagedObjectContext alloc] init];
            [_context setPersistentStoreCoordinator:coordinator];
        }
    }
    
    return self;
}


- (id) initWithModelName:(NSString*) modelName path:(NSString *)path {
    
    if (self = [super init]) {
        
        // ManagedObjectModel
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
        NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // PersistentStoreCoordinator
        
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        NSError* error;
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            [self handleError:error];
        
        // ManagedObjectContext
        
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
        //        [coordinator release];
        //        [managedObjectModel release];
    }
    
    return self;
}


- (void) addStoreInDocumentsWithPath:(NSString *)path {
    
    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString* fullStoreName = [NSString stringWithFormat:@"%@.sqlite", path];
    NSURL* storeURL = [documentsDirectory URLByAppendingPathComponent:fullStoreName];
    [_context.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
}

//
//- (id) init {
//    
//    if ((self = [super init])) {
//        
//        // Copy sqlite file (once)
//        
//        [self copyDatabase];
//        
//        // ManagedObjectModel
//        
//        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:model_name withExtension:@"momd"];
//        NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//        
//        // PersistentStoreCoordinator
//        
//        // mainbundle pathforresource
//        
//        NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//        NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:db_name];
////        NSURL* storeURL = [[NSBundle mainBundle] URLForResource:@"Sprachenraetsel" withExtension:@"sqlite"];
//        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
//        NSError* error;
//        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
//            [self handleError:error];
//        
//        // ManagedObjectContext
//        
//        _context = [[NSManagedObjectContext alloc] init];
//        [_context setPersistentStoreCoordinator:coordinator];
//        [coordinator release];
//        [managedObjectModel release];
//    }
//    
//    return self;
//}

#pragma mark Shared Instance Method

//+ (DataManager*) sharedInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] init];
//        }
//    }
//    
//    return _instance;
//}

//+ (DataManager*) contentInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] initWithModelName:@"content" storeName:@"content" location:DataManagerStoreLocationBundle];
//        }
//    }
//    
//    return _instance;
//}
//
//+ (DataManager*) importedContentInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] initWithModelName:@"content" storeName:@"content" location:DataManagerStoreLocationDocuments];
//        }
//    }
//    
//    return _instance;
//}
//
//+ (DataManager*) playerInstance {
//    
//    static DataManager* _instance;
//    
//    @synchronized(self) {
//        
//        if (!_instance) {
//            _instance = [[DataManager alloc] initWithModelName:@"player" storeName:@"player" location:DataManagerStoreLocationDocuments];
//        }
//    }
//    
//    return _instance;
//}


+ (DataManager*) instanceNamed:(NSString *)name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
        
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
        
        if ([_instances objectForKey:name]) {
            
            return [_instances objectForKey:name];
        }
        else {
                
            DataManager* newManager = [[DataManager alloc] initWithModelName:name storeName:name location:DataManagerStoreLocationDocuments];
            [_instances setObject:newManager forKey:name];
            return newManager;
        }
    }
}

+ (DataManager*) instanceInBundleNamed:(NSString *)name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
        
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
        
        if ([_instances objectForKey:name]) {
            
            return [_instances objectForKey:name];
        }
        else {
            
            DataManager* newManager = [[DataManager alloc] initWithModelName:name storeName:name location:DataManagerStoreLocationBundle];
            [_instances setObject:newManager forKey:name];
            return newManager;
        }
    }
}

+ (DataManager*) instanceInUbiquityContainerNamed:(NSString*) name {
    
    static NSMutableDictionary* _instances;
    
    @synchronized(self) {
        
        if (!_instances) {
            
            _instances = [[NSMutableDictionary alloc] init];
        }
        
        if ([_instances objectForKey:name]) {
            
            return [_instances objectForKey:name];
        }
        else {
            
            DataManager* newManager = [[DataManager alloc] initWithModelName:name storeName:name location:DataManagerStoreLocationUbiquityContainer];
            [_instances setObject:newManager forKey:name];
            return newManager;
        }
    }
}



#pragma mark Methods

- (id) insertNewObjectForEntityName:(NSString *)name {
    
    return [NSEntityDescription insertNewObjectForEntityForName:name
                                  inManagedObjectContext:_context];
}


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
    
    if (!results) [self handleError:error];
    
    return results;
}


- (NSArray*) executeFetchRequest:(NSFetchRequest*) request error:(NSError**) error {
    
    return [_context executeFetchRequest:request error:error];
}


// WARNING: predicate might find more than 1 hit
- (id) fetchOrCreateObjectForEntityName:(NSString *)name withPredcate:(NSPredicate *)predicate {
    
    NSArray* results = [self fetchDataForEntityName:name withPredicate:predicate sortedBy:nil];
    
    if (results.count == 0) {
        
        return [self insertNewObjectForEntityName:name];
    }
    else {
        
        return [results objectAtIndex:0];
    }
}


- (NSManagedObject*) createUnmanagedObjectForEntityName:(NSString*) entityName {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_context];
    return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
}


- (int) countForEntity:(NSString *)entityName {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:_context]];
    NSError* error;
    
    int count = [_context countForFetchRequest:request error:&error];
    
//    [request release];
    
    return count;
}

- (void) deleteObject:(id)object {
    
    [_context deleteObject:object];
}

- (void) handleError:(NSError *)error {
    
    if (error) {
        NSLog(@"DataManager: Unresolved error: %@", [error userInfo]);
        abort();
    }
}

- (void) save {

    NSError *error = nil;
    
    if (_context && [_context hasChanges]) {
        [_context save:&error];
        [self handleError:error];
    }
}

- (void) clearStore {
    
//    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* storeURL = [[_context persistentStoreCoordinator] URLForPersistentStore:[[[_context persistentStoreCoordinator]persistentStores] lastObject] ];
//    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:db_name];
    NSError* error;
    
    // delete store file
    
    if (![[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error])
        [self handleError:error];
    
    NSPersistentStoreCoordinator* coordinator = [_context persistentStoreCoordinator];
    
    [coordinator removePersistentStore:[[coordinator persistentStores] lastObject] error:&error];
    
    // recreate store file
    
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        [self handleError:error];
}


//- (void) copyDatabase {
//    
//    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
//    
//    NSString* originalDatabasePath = [resourcePath stringByAppendingPathComponent:db_name];
//    
//    // Create the path to the database in the Documents directory.
//    
//    NSArray* documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString* documentsDirectory = [documentsPaths objectAtIndex:0];
//    
//    NSString* newDatabasePath = [documentsDirectory stringByAppendingPathComponent:db_name];
//    
//    if (![[NSFileManager defaultManager] isReadableFileAtPath:newDatabasePath]) {
//        
//        if ([[NSFileManager defaultManager] copyItemAtPath:originalDatabasePath toPath:newDatabasePath error:NULL] != YES)
//            
//            NSAssert2(0, @"Fail to copy database from %@ to %@", originalDatabasePath, newDatabasePath);
//    }
//}


- (float) calculateSumForEntityName:(NSString*) entityName withPredicate:(NSPredicate*) predicate attribute:(NSString*) attribute {
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_context];
    request.predicate = predicate;
    request.resultType = NSDictionaryResultType;
    request.includesPendingChanges = YES;
    
    NSExpressionDescription* sumExpressionDescription = [[NSExpressionDescription alloc] init];
    sumExpressionDescription.name = @"sum";
    
    NSExpression* sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForKeyPath:attribute]]];
    sumExpressionDescription.expression = sumExpression;
    
    sumExpressionDescription.expressionResultType = NSFloatAttributeType;
    
    request.propertiesToFetch = @[sumExpressionDescription];
    
    NSArray* results = [self executeFetchRequest:request error:nil];
    
    float sum = [results[0][@"sum"] floatValue];

    return sum;
}


@end
