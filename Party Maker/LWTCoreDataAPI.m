//
//  LWTCoreDataAPI.m
//  Party Maker
//
//  Created by 2 on 2/22/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTCoreDataAPI.h"
@interface LWTCoreDataAPI()
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readwrite, strong, nonatomic) NSManagedObjectContext *mainThreadContext;

@property (nonatomic) NSMutableArray *internetBase;
@property (nonatomic) NSMutableArray *tempInternetBase;
@end
@implementation LWTCoreDataAPI

+ (instancetype) coreData {
    static dispatch_once_t pred;
    static id storage = nil;
    dispatch_once(&pred, ^{
        storage = [[super alloc] init];
    });
    
    return storage;
}

-(void)loadPartiesFromDatabase{
    [LWTPartyStorage partiesStorage].parties = [[NSMutableArray alloc] init];
    
    NSArray *fetchedParties = [Party fetchPartiesWithContext:self.mainThreadContext];
    for(Party *party in fetchedParties){
        LWTParty *myParty = [LWTParty getMyPartyWithParty:party];
        [[LWTPartyStorage partiesStorage].parties addObject:myParty];
    }
    NSLog(@"Parties from database loaded");
    
}

-(void)mergeDatabaseWithContext:(NSManagedObjectContext *)context{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyyHH:mm";
    NSString *beginDate;
    NSString *endDate;
    
    for(LWTParty *party in [LWTPartyStorage partiesStorage].tempInternetBase){
        Party *myParty = [Party fetchPartiesWithIDInContext:party.partyID context:context];
        if(myParty){
            myParty.name = party.partyName;
            myParty.desc = party.partyDescription;
            myParty.iconNumber = [party.partyImageNumber intValue];
            beginDate = [party.partyDate stringByAppendingString:[NSNumber timeFromFloat:party.partyStartTime]];
            endDate =[party.partyDate stringByAppendingString:[NSNumber timeFromFloat:party.partyEndTime]];
            myParty.beginDate = [[formatter dateFromString:beginDate] timeIntervalSince1970];
            myParty.endDate = [[formatter dateFromString:endDate] timeIntervalSince1970];
            myParty.creator_id = [LWTPartyStorage partiesStorage].creatorID;
            myParty.latitude = party.latitude;
            myParty.longitude = party.longtitude;
        } else {
            [self addPartyToDatabaseWithContext:party context:context];
        }
    }
    NSArray *fetchedParties = [Party fetchPartiesWithContext:context];
    NSMutableArray *myPartyArray = [[NSMutableArray alloc]init];
    for(Party *party in fetchedParties){
        [myPartyArray addObject:[LWTParty getMyPartyWithParty:party]];
    }
    for(LWTParty *party in myPartyArray){
        if(![[LWTPartyStorage partiesStorage].tempInternetBase containsObject:party]){
            Party *partyToDelete = [Party fetchPartiesWithIDInContext:party.partyID context:context];
            [context deleteObject:partyToDelete];
        }
    }
}

- (void) performWriteOperation:(void (^)(NSManagedObjectContext*))writeBlock completion:(void(^)())completion {
    [self.backgroundThreadContext performBlock:^{
        writeBlock(self.backgroundThreadContext);
        
        if ( self.backgroundThreadContext.hasChanges ) {
            NSError *error = nil;
            [self.backgroundThreadContext save:&error];
            NSLog(@"%s, error happened - %@", __PRETTY_FUNCTION__, error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
    
}

-(void)addPartyToDatabaseWithContext:(LWTParty*)party context:(NSManagedObjectContext*)context{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyyHH:mm";
    Party *newParty;
    
    newParty = [NSEntityDescription insertNewObjectForEntityForName:@"Party" inManagedObjectContext:context];
    
    
    newParty.desc = party.partyDescription;
    NSString *beginDate = [party.partyDate stringByAppendingString:[NSNumber timeFromFloat:party.partyStartTime]];
    NSString *endDate =[party.partyDate stringByAppendingString:[NSNumber timeFromFloat:party.partyEndTime]];
    newParty.beginDate = [[formatter dateFromString:beginDate] timeIntervalSince1970];
    newParty.endDate = [[formatter dateFromString:endDate] timeIntervalSince1970];
    newParty.name = party.partyName;
    newParty.partyID = party.partyID;
    newParty.iconNumber = [party.partyImageNumber intValue];
    newParty.creator_id = [LWTPartyStorage partiesStorage].creatorID;
    newParty.latitude = party.latitude;
    newParty.longitude = party.longtitude;
}

#pragma mark -CoreData stack init
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Parties.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)mainThreadContext {
    if (_mainThreadContext != nil) {
        return _mainThreadContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_mainThreadContext setPersistentStoreCoordinator:coordinator];
    return _mainThreadContext;
}

- (NSManagedObjectContext *)backgroundThreadContext {
    if (_backgroundThreadContext != nil) {
        return _backgroundThreadContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _backgroundThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_backgroundThreadContext setPersistentStoreCoordinator:coordinator];
    return _backgroundThreadContext;
}

@end
