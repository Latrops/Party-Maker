//
//  LWTSettingsViewController.m
//  Party Maker
//
//  Created by 2 on 2/29/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTSettingsViewController.h"
#import "LWTAppDelegate.h"

@interface LWTSettingsViewController ()

@end

@implementation LWTSettingsViewController

- (IBAction)actionLogout:(id)sender {
    LWTAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate logout];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
