//
//  CALayer+StoryBoardConfiguration.m
//  Party Maker
//
//  Created by 2 on 2/25/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "CALayer+StoryBoardConfiguration.h"

@implementation CALayer(StoryBoardConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end