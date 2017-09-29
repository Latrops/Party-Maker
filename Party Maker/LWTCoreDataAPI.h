//
//  LWTCoreDataAPI.h
//  Party Maker
//
//  Created by 2 on 2/22/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Party.h"
#import "LWTPartyStorage.h"

@interface LWTCoreDataAPI : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *mainThreadContext;
@property (readwrite, strong, nonatomic) NSManagedObjectContext *backgroundThreadContext;

+ (instancetype) coreData;

-(void)performWriteOperation:(void (^)(NSManagedObjectContext*))writeBlock completion:(void(^)())completion;
-(void)addPartyToDatabaseWithContext:(LWTParty*)party context:(NSManagedObjectContext*)context;
-(void)loadPartiesFromDatabase;
-(void)mergeDatabaseWithContext:(NSManagedObjectContext *)context;
@end
