//
//  LWTPartyMakerSDK.h
//  Party Maker
//
//  Created by 2 on 2/16/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWTPartyStorage.h"

@interface LWTPartyMakerSDK : NSObject
+(instancetype) SDK;
-(NSMutableURLRequest*)createRequest:(NSDictionary*)parameters :(NSDictionary*)header :(NSString*)method :(NSString*) path;
- (void) loginWithUser :(NSString*)_username password:(NSString*)_pass callback:(void (^) (NSDictionary *response, NSError *error))block;
- (void) registerWithUser :(NSString*)_email password:(NSString*)_pass name:(NSString*)_username callback:(void (^) (NSDictionary *response, NSError *error))block;
- (void) getPartiesWithUserID :(int)_userID callback:(void (^) (NSDictionary *response, NSError *error))block;
- (void) addPartyWithLWTParty :(LWTParty*)_party callback:(void (^) (NSDictionary *response, NSError *error))block;
- (void) deleteParty :(NSString*)_partyID :(int)_userID callback:(void (^) (NSDictionary *response, NSError *error))block;
- (void) getUsers :(void (^) (NSDictionary *response, NSError *error))block;
- (void) deleteUserWithID :(int)_userID callback:(void (^) (NSDictionary *response, NSError *error))block;
@end
