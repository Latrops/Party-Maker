//
//  LWTTableViewCell.m
//  Party Maker
//
//  Created by 2 on 2/12/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTTableViewCell.h"
#import <UIKit/UIKit.h>
#import "NSNumber+Utility.h"

@implementation LWTTableViewCell
-(void)configureWithParty:(LWTParty *)party {
    int iconNumber = [party.partyImageNumber intValue];
    switch (iconNumber) {
        case 0:
            self.partyIcon.image =  [UIImage imageNamed:@"PartyLogo_Small_0.png"];
            break;
        case 1:
            self.partyIcon.image =  [UIImage imageNamed:@"PartyLogo_Small_1.png"];
            break;
        case 2:
            self.partyIcon.image =  [UIImage imageNamed:@"PartyLogo_Small_2.png"];
            break;
        case 3:
            self.partyIcon.image =  [UIImage imageNamed:@"PartyLogo_Small_3.png"];
            break;
        case 4:
            self.partyIcon.image =  [UIImage imageNamed:@"PartyLogo_Small_4.png"];
            break;
        case 5:
            self.partyIcon.image =  [UIImage imageNamed:@"PartyLogo_Small_5.png"];
            break;
            
        default:
            break;
    }
    self.nameLabel.text = party.partyName;
    self.locationLabel.text = party.latitude;
    self.dateLabel.text = [NSString stringWithFormat:@"%@: %@ %@ - %@ ",NSLocalizedStringFromTable(@"Date", @"language", nil),party.partyDate, [NSNumber timeFromFloat:party.partyStartTime],[NSNumber timeFromFloat:party.partyEndTime]];
}

+ (NSString*) reuseIdentifier{
    return @"MyTableViewCellReuseIdentifier";
}
@end
