//
//  Party.h
//  Party Maker
//
//  Created by 2 on 2/17/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LWTPartyStorage.h"
#import "NSNumber+Utility.h"

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface Party : NSManagedObject
+(NSArray*)fetchPartiesWithContext:(NSManagedObjectContext*)context;
+(Party*)fetchPartiesWithIDInContext:(NSString*)partyID context:(NSManagedObjectContext*)context;
@end

NS_ASSUME_NONNULL_END

#import "Party+CoreDataProperties.h"
