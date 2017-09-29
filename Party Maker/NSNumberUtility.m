//
//  NSString+Utility.m
//  Party Maker
//
//  Created by 2 on 2/14/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "NSNumber+Utility.h"

@implementation NSNumber(Utility)

+(NSString*)timeFromFloat:(NSNumber*)floatValue{
    return [NSString stringWithFormat:@"%02d:%02d",[floatValue intValue]/60, [floatValue intValue]%60];
}

@end
