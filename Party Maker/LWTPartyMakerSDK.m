//
//  LWTPartyMakerSDK.m
//  Party Maker
//
//  Created by 2 on 2/16/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTPartyMakerSDK.h"

@interface LWTPartyMakerSDK()
@property (strong,nonatomic)NSURLSession *defaultSession;
@end
NSString *APIString;
@implementation LWTPartyMakerSDK
-(void) configureSession{
    APIString = @"http://itworksinua.km.ua/party";
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest=5.01;
    sessionConfig.timeoutIntervalForResource=10.0;
    sessionConfig.allowsCellularAccess=NO;
    self.defaultSession = [NSURLSession sessionWithConfiguration:sessionConfig];
}
-(instancetype) initUniqueInstance {
    [self configureSession];
    return [super init];
}
+ (instancetype) SDK {
    static dispatch_once_t pred;
    static LWTPartyMakerSDK *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[super alloc] initUniqueInstance];
    });
    return instance;
    
}
-(NSMutableURLRequest*)createRequest:(NSDictionary*)parameters :(NSDictionary*)header :(NSString*)method :(NSString*) path {
    NSString *URLString = [APIString stringByAppendingString:path];
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method];
    if([method isEqualToString:@"GET"]){
        URLString = [URLString stringByAppendingString:@"?"];
        for(NSString* key in parameters){
            URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[parameters objectForKey:key]]];
        }
        URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        request.URL = [NSURL URLWithString:URLString];
    } else if([method isEqualToString:@"POST"]){
        NSString *newUrl = @"";
        for(NSString* key in parameters){
            newUrl = [newUrl stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[parameters objectForKey:key]]];
        }
        newUrl = [newUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSData *reqData = [newUrl dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:reqData];
    }
    NSLog(@"%@",request.URL);//NSLog(@"%@",request.HTTPBody);
    return request;
}

- (void) loginWithUser :(NSString*)_username password:(NSString*)_pass callback:(void (^) (NSDictionary *response, NSError *error))block{
    
    NSMutableURLRequest *URLRrequest = [self createRequest:@{@"name":_username, @"password":_pass} :nil :@"GET" :@"/login" ];
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self performBlockOnMainThread:block :[self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]] : error];
    }] resume];
}

- (void) registerWithUser :(NSString*)_email password:(NSString*)_pass name:(NSString*)_username callback:(void (^) (NSDictionary *response, NSError *error))block{
    NSMutableURLRequest *URLRrequest;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict addEntriesFromDictionary:@{ @"password":_pass , @"name":_username}];
    if(_email){
        [dict addEntriesFromDictionary:@{@"email":_email, @"password":_pass}];
    }
    
    URLRrequest = [self createRequest:dict :nil :@"POST" :@"/register" ];
    
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self performBlockOnMainThread:block :[self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]] : error];
    }] resume];
}
- (void) getPartiesWithUserID :(int)_userID callback:(void (^) (NSDictionary *response, NSError *error))block{
    NSMutableURLRequest *URLRrequest = [self createRequest:@{@"creator_id":@(_userID)} :nil :@"GET" :@"/party" ];
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [self performBlockOnMainThread:block :[self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]] : error];
    }] resume];
}
- (void) deleteUserWithID :(int)_userID callback:(void (^) (NSDictionary *response, NSError *error))block{
    NSMutableURLRequest *URLRrequest = [self createRequest:@{@"creator_id":@(_userID)} :nil :@"GET" :@"/deleteUser" ];
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [self performBlockOnMainThread:block :[self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]] : error];
    }] resume];
}
- (void) addPartyWithLWTParty :(LWTParty*)_party callback:(void (^) (NSDictionary *response, NSError *error))block{
    NSMutableURLRequest *URLRrequest;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"dd.MM.yyyyHH:mm";
    NSString *beginDate = [_party.partyDate stringByAppendingString:[NSNumber timeFromFloat:_party.partyStartTime]];
    NSString *endDate =[_party.partyDate stringByAppendingString:[NSNumber timeFromFloat:_party.partyEndTime]];
    [dict addEntriesFromDictionary: @{ @"name":_party.partyName,
                                       @"start_time":@([[formatter dateFromString:beginDate] timeIntervalSince1970]),
                                       @"end_time":@([[formatter dateFromString:endDate] timeIntervalSince1970]),
                                       @"creator_id":@([LWTPartyStorage partiesStorage].creatorID),
                                       @"latitude":_party.latitude,
                                       @"longitude":_party.longtitude}];
    
    if(_party.partyID){
        [dict addEntriesFromDictionary:@{@"party_id":_party.partyID}];
    }
    if(_party.partyImageNumber){
        [dict addEntriesFromDictionary:@{@"logo_id":_party.partyImageNumber}];
    }
    if(_party.partyDescription){
        [dict addEntriesFromDictionary:@{@"comment":_party.partyDescription}];
    }
    URLRrequest = [self createRequest:dict :nil :@"POST" :@"/addParty" ];
    
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self performBlockOnMainThread:block :[self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]] : error];
    }] resume];
}

- (void) deleteParty :(NSString*)_partyID :(int)_userID callback:(void (^) (NSDictionary *response, NSError *error))block{
    NSMutableURLRequest *URLRrequest = [self createRequest:@{@"party_id":_partyID,@"creator_id":@(_userID)} :nil :@"GET" :@"/deleteParty" ];
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (block) block([self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]], error);
    }] resume];
}
- (void) getUsers :(void (^) (NSDictionary *response, NSError *error))block{
    NSMutableURLRequest *URLRrequest = [self createRequest:nil :nil :@"GET" :@"/allUsers" ];
    [[self.defaultSession dataTaskWithRequest:URLRrequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self performBlockOnMainThread:block :[self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]] : error];
        //if (block) block([self serialize:data statusCode:(NSNumber *)[response valueForKey:@"statusCode"]], error);
    }] resume];
}
- (NSDictionary *) serialize:(NSData *) data statusCode:(NSNumber *) statusCode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (statusCode)
        [dict setValue:statusCode forKey:@"statusCode"];
    else
        [dict setValue:@505 forKey:@"statusCode"];
    id jsonArray;
    if (data) jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (!jsonArray) jsonArray = [NSNull null];
    [dict setValue:jsonArray forKey:@"response"];
    return dict;
}
-(void) performBlockOnMainThread :(void (^) (NSDictionary *response, NSError *error))block : (NSDictionary*)response : (NSError*)error{
    if(block){
        dispatch_async(dispatch_get_main_queue(), ^{
            block(response,error);
        });
    }
}
//    
//}
@end
