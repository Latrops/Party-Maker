//
//  Party+CoreDataProperties.h
//  Party Maker
//
//  Created by 2 on 2/24/16.
//  Copyright © 2016 latrops. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Party.h"

NS_ASSUME_NONNULL_BEGIN

@interface Party (CoreDataProperties)

@property (nonatomic) NSTimeInterval beginDate;
@property (nonatomic) int32_t creator_id;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nonatomic) NSTimeInterval endDate;
@property (nonatomic) int32_t iconNumber;
@property (nullable, nonatomic, retain) NSString *latitude;
@property (nullable, nonatomic, retain) NSString *longitude;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *partyID;

@end

NS_ASSUME_NONNULL_END
