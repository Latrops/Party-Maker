//
//  User+CoreDataProperties.h
//  Party Maker
//
//  Created by 2 on 2/18/16.
//  Copyright © 2016 latrops. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nonatomic) int32_t creator_id;
@property (nullable, nonatomic, retain) NSSet<Party *> *related_parties;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addRelated_partiesObject:(Party *)value;
- (void)removeRelated_partiesObject:(Party *)value;
- (void)addRelated_parties:(NSSet<Party *> *)values;
- (void)removeRelated_parties:(NSSet<Party *> *)values;

@end

NS_ASSUME_NONNULL_END
