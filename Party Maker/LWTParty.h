//
//  LWTParty.h
//  Party Maker
//
//  Created by 2 on 2/8/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Party;

@interface LWTParty : NSObject <NSCoding>

@property (nonatomic,readwrite) NSString* partyDate;
@property (nonatomic,readwrite) NSString* partyName;
@property (nonatomic,readwrite) NSNumber* partyStartTime;
@property (nonatomic,readwrite) NSNumber* partyEndTime;
@property (nonatomic,readwrite) NSNumber* partyImageNumber;
@property (nonatomic,readwrite) NSString* partyDescription;
@property (nonatomic,readwrite) NSString* partyID;
@property (nonatomic,readwrite) NSString* latitude;
@property (nonatomic,readwrite) NSString* longtitude;

+(LWTParty*)getMyPartyWithParty:(Party*)party;
+(LWTParty*)initWithDictionary:(NSDictionary*)dictionary;
-(BOOL)isEqual:(id)other;
-(BOOL)isEqualToParty:(LWTParty*)party1;
@end
