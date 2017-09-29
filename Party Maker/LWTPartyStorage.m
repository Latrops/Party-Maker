//
//  LWTPartyStorage.m
//  Party Maker
//
//  Created by 2 on 2/13/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTPartyStorage.h"
#import "LWTPartyMakerSDK.h"
#import "NSNumber+Utility.h"

@interface LWTPartyStorage ()
{
    Reachability *internetReachableFoo;
}
@end
@implementation LWTPartyStorage

+ (instancetype) partiesStorage {
    static dispatch_once_t pred;
    static id parties = nil;
    dispatch_once(&pred, ^{
        parties = [[super alloc] init];
    });
    
    return parties;
}
-(void)clearData{
    self.parties = nil;
    self.creatorID = 0;
    self.changesToLoad = NO;
    self.tempInternetBase = nil;
}
-(BOOL)isWebReachable{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.itworksinua.km.ua"];
    return [internetReachableFoo isReachable];
}
-(void)loadAllUsers:(void(^)())completion{
    [[LWTPartyMakerSDK SDK]getUsers:^(NSDictionary *response, NSError *error) {
        LWTUser *user;
        NSMutableArray *unsortedUsers = [[NSMutableArray alloc] init];
        self.usersBase = [[NSMutableArray alloc]init];
        if([[response valueForKey:@"statusCode"] longValue]==200){
            if(![[[response valueForKey:@"response"]class]isSubclassOfClass:[NSNull class]]){
                for(id party in [response valueForKey:@"response"]) {
                    user = [[LWTUser alloc] init];
                    user.userName = [party valueForKey:@"name"];
                    user.userID = [party valueForKey:@"id"];
                    [unsortedUsers addObject:user];
                }
                self.usersBase = [unsortedUsers sortedArrayUsingComparator:^NSComparisonResult(LWTUser *a, LWTUser *b) {
                    NSString *first = [a userName];
                    NSString *second = [b userName];
                    return [first compare:second];
                }];
            }
        } else {
            if(error)
                self.lastError = [error localizedDescription];
            else
                self.lastError = [[response valueForKey:@"response"] valueForKey:@"msg"];
            return;
        }
        if(completion){
            completion();
        }
    }];
}
-(void)removePartyWithID:(NSString*)partyID{
    [LWTPartyStorage partiesStorage].changesToLoad = YES;
    [[LWTPartyMakerSDK SDK] deleteParty:partyID :[LWTPartyStorage partiesStorage].creatorID callback:^(NSDictionary *response, NSError *error) {
        if([[response valueForKey:@"statusCode"] longValue]==200){
            [[LWTPartyStorage partiesStorage] loadPartiesFromInternetToMainArray];
            NSLog(@"%@",response);
        } else {
            if(error)
                [LWTPartyStorage partiesStorage].lastError = [error localizedDescription];
            else
                [LWTPartyStorage partiesStorage].lastError = [[response valueForKey:@"response"] valueForKey:@"msg"];
        }
    }];
}
-(void)loadPartiesFromInternetWithUserID:(int)userID completion:(void(^)())completion{
    [[LWTPartyMakerSDK SDK] getPartiesWithUserID:userID callback:^(NSDictionary *response, NSError *error) {
        LWTParty *newParty;
        self.tempInternetBase = [[NSMutableArray alloc] init];
        if([[response valueForKey:@"statusCode"] longValue]==200){
            if(![[[response valueForKey:@"response"]class]isSubclassOfClass:[NSNull class]]){
                for(id party in [response valueForKey:@"response"]) {
                    newParty = [LWTParty initWithDictionary:party];
                    [self.tempInternetBase addObject:newParty];
                }
            }
        } else {
            if(error)
                self.lastError = [error localizedDescription];
            else
                self.lastError = [[response valueForKey:@"response"] valueForKey:@"msg"];
            return;
        }
        if(completion){
            completion();
        }
    }];
}
-(void)loadPartiesFromInternetToMainArray{
    [[LWTPartyMakerSDK SDK] getPartiesWithUserID:self.creatorID callback:^(NSDictionary *response, NSError *error) {
        LWTParty *newParty;
        self.tempInternetBase = [[NSMutableArray alloc] init];
        if([[response valueForKey:@"statusCode"] longValue]==200){
            if(![[[response valueForKey:@"response"]class]isSubclassOfClass:[NSNull class]]){
                for(id party in [response valueForKey:@"response"]) {
                    newParty = [LWTParty initWithDictionary:party];
                    [self.tempInternetBase addObject:newParty];
                }
            }
        } else {
            if(error)
                self.lastError = [error localizedDescription];
            else
                self.lastError = [[response valueForKey:@"response"] valueForKey:@"msg"];
            return;
        }
        //clear and fill DB
        [[LWTCoreDataAPI coreData] performWriteOperation:^(NSManagedObjectContext *context) {
            [[LWTCoreDataAPI coreData] mergeDatabaseWithContext:context];
            
        } completion:^{
            [[LWTCoreDataAPI coreData] loadPartiesFromDatabase];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTheTable" object:nil];
            });
        }];
    }];
}
-(void)saveParty:(LWTParty*)_party completion:(void(^)())completion{
    [[LWTPartyMakerSDK SDK] addPartyWithLWTParty:_party callback:^(NSDictionary *response, NSError *error) {
        if([[response valueForKey:@"statusCode"] longValue]==200){
            [self loadPartiesFromInternetToMainArray];
        } else {
            if(error)
                self.lastError = [error localizedDescription];
            else
                self.lastError = [[response valueForKey:@"response"] valueForKey:@"msg"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}
-(void)registerUserWithUsernamePassword:(NSString*)username password:(NSString*)password completion:(void(^)(NSString* error))completion{
    [[LWTPartyMakerSDK SDK] registerWithUser:username password:password name:username callback:^(NSDictionary *response, NSError *error) {
        __block NSString *errorMessage;
        
        if([[response valueForKey:@"statusCode"] longValue]==200){
            [self loginWithUsernamePassword:username password:password completion:^(NSString *loginError) {
                errorMessage = loginError;
            }];
        } else {
            if ([[response objectForKey:@"statusCode"] isEqual: @400]) {
                errorMessage = NSLocalizedStringFromTable(@"User exists", @"language", nil);
            } else if ([[response objectForKey:@"statusCode"] isEqual: @404]){
                errorMessage = NSLocalizedStringFromTable(@"Enter data", @"language", nil);
            }
        }
        if(completion)
            completion(errorMessage);
    }];
}
-(void)loginWithUsernamePassword:(NSString*)username password:(NSString*)password completion:(void(^)(NSString* error))completion{
    [[LWTPartyMakerSDK SDK] loginWithUser:username password:password callback:^(NSDictionary *response, NSError *error) {
        NSString *errorMessage;
        
        if([[response valueForKey:@"statusCode"] longValue]==200){
            [LWTPartyStorage partiesStorage].creatorID = [[[response valueForKey:@"response"] valueForKey:@"id"] intValue];
            NSLog(@"%d %d",[[[response valueForKey:@"response"] valueForKey:@"id"] intValue], [LWTPartyStorage partiesStorage].creatorID);
            [LWTPartyStorage partiesStorage].changesToLoad = YES;
            [[LWTPartyStorage partiesStorage] loadPartiesFromInternetToMainArray];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTheTable" object:self];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:[LWTPartyStorage partiesStorage].creatorID forKey:@"loggedUserID"];
            [defaults synchronize];
            
        } else {
            if ([[response objectForKey:@"statusCode"] isEqual: @400]) {
                errorMessage = NSLocalizedStringFromTable(@"Wrong data", @"language", nil);
            } else if ([[response objectForKey:@"statusCode"] isEqual: @404]){
                errorMessage = NSLocalizedStringFromTable(@"Enter data", @"language", nil);
            }
        }
        if(completion)
            completion(errorMessage);
    }];
}
@end
