//
//  LWTParty.m
//  Party Maker
//
//  Created by 2 on 2/8/16.
//  Copyright © 2016 latrops. All rights reserved.
//a
#import "LWTParty.h"
#import "Party.h"
NSMutableArray* parties;
@implementation LWTParty
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.partyName = [decoder decodeObjectForKey:@"partyName"];
        self.partyDate = [decoder decodeObjectForKey:@"partyDate"];
        self.partyStartTime = [decoder decodeObjectForKey:@"partyStartTime"];
        self.partyEndTime = [decoder decodeObjectForKey:@"partyEndTime"];
        self.partyImageNumber = [decoder decodeObjectForKey:@"partyImageNumber"];
        self.partyDescription = [decoder decodeObjectForKey:@"partyDescription"];
        self.partyID = [decoder decodeObjectForKey:@"partyID"];
    }
    return self;
}
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToParty:other];
}
-(BOOL)isEqualToParty:(LWTParty*)party1{
    if(![party1.partyID isEqualToString:self.partyID])
        return NO;
    if(![party1.latitude isEqualToString:self.latitude])
        return NO;
    if(![party1.longtitude isEqualToString:self.longtitude])
        return NO;
    if(![party1.partyDescription isEqualToString:self.partyDescription])
        return NO;
    if(![party1.partyName isEqualToString:self.partyName])
        return NO;
    if(![party1.partyDate isEqualToString:self.partyDate])
        return NO;
    if(![party1.partyStartTime isEqual:self.partyStartTime])
        return NO;
    if(![party1.partyEndTime isEqual:self.partyEndTime])
        return NO;
    if(![party1.partyImageNumber isEqual:self.partyImageNumber])
        return NO;
    return YES;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.partyName forKey:@"partyName"];
    [encoder encodeObject:self.partyDate forKey:@"partyDate"];
    [encoder encodeObject:self.partyStartTime forKey:@"partyStartTime"];
    [encoder encodeObject:self.partyEndTime forKey:@"partyEndTime"];
    [encoder encodeObject:self.partyImageNumber forKey:@"partyImageNumber"];
    [encoder encodeObject:self.partyDescription forKey:@"partyDescription"];
    [encoder encodeObject:self.partyID forKey:@"partyID"];
}
+(LWTParty*)initWithDictionary:(NSDictionary*)dictionary{
    LWTParty *newParty = [[LWTParty alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
    
    newParty.partyName = [dictionary valueForKey:@"name"];
    newParty.partyDescription = [dictionary valueForKey:@"comment"];
    newParty.partyImageNumber = @([[dictionary valueForKey:@"logo_id"] intValue]);
    int dateTime = [[dictionary valueForKey:@"start_time"] intValue];
    newParty.partyDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateTime]];
    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate dateWithTimeIntervalSince1970:dateTime]];
    newParty.partyStartTime = @(components.hour * 60 + components.minute);
    dateTime = [[dictionary valueForKey:@"end_time"] intValue];
    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate dateWithTimeIntervalSince1970:dateTime]];
    newParty.partyEndTime = @(components.hour * 60 + components.minute);
    newParty.partyID = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"id"]];
    newParty.latitude = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"latitude"]];
    newParty.longtitude = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"longitude"]];
    //newParty.latitude = [party valueForKey:@"latitude"];
    //newParty.longitude = [party valueForKey:@"longitude"];
    return newParty;
}
+(LWTParty*)getMyPartyWithParty:(Party*)party{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
    
    LWTParty *myParty = [LWTParty new];
    
    myParty.partyName = party.name;
    myParty.partyDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:party.beginDate]];
    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate dateWithTimeIntervalSince1970:party.beginDate]];
    myParty.partyStartTime = @(components.hour * 60 + components.minute);
    components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate dateWithTimeIntervalSince1970:party.endDate]];
    myParty.partyEndTime = @(components.hour * 60 + components.minute);
    myParty.partyDescription = party.desc;
    myParty.partyImageNumber = @(party.iconNumber);
    myParty.partyID = party.partyID;
    myParty.latitude = party.latitude;
    myParty.longtitude = party.longitude;
    return myParty;
}

@end
