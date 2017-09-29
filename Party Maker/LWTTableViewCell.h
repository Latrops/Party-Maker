//
//  LWTTableViewCell.h
//  Party Maker
//
//  Created by 2 on 2/12/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWTParty.h"

@interface LWTTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView *partyIcon;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;
@property (nonatomic,strong) IBOutlet UILabel *locationLabel;

+ (NSString*) reuseIdentifier;
-(void)configureWithParty:(LWTParty*)party;

@end
