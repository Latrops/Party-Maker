//
//  LWTPartyStorage.h
//  Party Maker
//
//  Created by 2 on 2/13/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTParty.h"
#import <CoreData/CoreData.h>
#import "Party.h"
#import "LWTUser.h"
#import "LWTCoreDataAPI.h"
#import <MapKit/MapKit.h>
#import <Reachability/Reachability.h>

@interface LWTPartyStorage : NSObject

@property (nonatomic) int creatorID;
@property (nonatomic) BOOL changesToLoad;
@property (nonatomic) NSString *lastError;

@property (nonatomic) NSMutableArray *parties;
@property (nonatomic) NSMutableArray *tempInternetBase;
@property (nonatomic) NSArray *usersBase;

-(void)clearData;
- (BOOL)isWebReachable;

-(void)saveParty:(LWTParty*)_party completion:(void(^)())completion;
+(instancetype)partiesStorage;

-(void)removePartyWithID:(NSString*)partyID;
-(void)loadPartiesFromInternetToMainArray;
-(void)loadPartiesFromInternetWithUserID:(int)userID completion:(void(^)())completion;
-(void)loadAllUsers:(void(^)())completion;

-(void)loginWithUsernamePassword:(NSString*)username password:(NSString*)password completion:(void(^)(NSString* error))completion;
-(void)registerUserWithUsernamePassword:(NSString*)username password:(NSString*)password completion:(void(^)(NSString* error))completion;
@end
