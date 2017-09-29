//
//  CALayer+StoryBoardConfiguration.h
//  Party Maker
//
//  Created by 2 on 2/25/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(StoryBoardConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end
