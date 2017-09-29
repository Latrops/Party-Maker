//
//  AppDelegate.m
//  Party Maker
//
//  Created by 2 on 2/3/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTAppDelegate.h"
#import "LWTPartyMakerSDK.h"
#import "LWTPartyStorage.h"
#import "LWTLoginViewController.h"
#import "LWTTabViewController.h"

@interface LWTAppDelegate ()
@end

@implementation LWTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor colorWithRed:35/255. green:37/255. blue:43/255. alpha:1]}
                                           forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor whiteColor]}
                                           forState:UIControlStateSelected];
    
    self.window.backgroundColor = [UIColor colorWithRed:46/255. green:49/255. blue:56/255. alpha:1];

//    [[LWTPartyMakerSDK SDK]  deleteUserWithID:380 callback:^(NSDictionary *response, NSError *error) {
//        NSLog(@"%@",response);
//    }];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults integerForKey:@"loggedUserID"]){
        [LWTPartyStorage partiesStorage].creatorID = (int)[defaults integerForKey:@"loggedUserID"];
    } else
        [self showLoginScreen:NO];
    return YES;
}

-(void) showLoginScreen:(BOOL)animated{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LWTLoginViewController *viewController = (LWTLoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LWTLogin"];
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:viewController
                                                 animated:animated
                                               completion:nil];
}
-(void)logout{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"loggedUserID"];
    [defaults synchronize];
    
    [[LWTPartyStorage partiesStorage] clearData];
    // Reset view controller (this will quickly clear all the views)
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LWTTabViewController *viewController = (LWTTabViewController *)[storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    [self.window setRootViewController:viewController];
    
    // Show login screen
    [self showLoginScreen:YES];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
