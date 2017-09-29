//
//  LWTTableScreenEViewController.m
//  Party Maker
//
//  Created by 2 on 2/12/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTTableScreenViewController.h"
#import "LWTTableViewCell.h"
#import "LWTPartyStorage.h"
#import "LWTPartyInfoViewController.h"
#import "LWTEventView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LWTTableScreenViewController ()
@property IBOutlet UITableView *table;
@property NSIndexPath *selectedRow;
@property (nonatomic) UIRefreshControl *refreshControl;
@end

@implementation LWTTableScreenViewController
-(void)reloadTable:(NSNotification *)notification{
    [self.table reloadData];
    [self.refreshControl endRefreshing];
    [LWTPartyStorage partiesStorage].changesToLoad = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self replaceNotifications];
    if([LWTPartyStorage partiesStorage].lastError){
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode = MBProgressHUDModeText;
        [hud setLabelText:[LWTPartyStorage partiesStorage].lastError];
        [self.view addSubview:hud];
        [hud show:YES];
        [hud hide:YES afterDelay:3];
        [LWTPartyStorage partiesStorage].lastError = nil;
    }
}
-(void)replaceNotifications{
    UIApplication *app = [UIApplication sharedApplication];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *beginDate;
    UILocalNotification *localNotification;
    
    formatter.dateFormat = @"dd.MM.yyyyHH:mm";
    for(UILocalNotification *notification in [app scheduledLocalNotifications]){
        [app cancelLocalNotification:notification];
    }
    for(LWTParty *party in [LWTPartyStorage partiesStorage].parties){
        beginDate = [party.partyDate stringByAppendingString:[NSNumber timeFromFloat:party.partyStartTime]];
        if([[formatter dateFromString:beginDate] compare:[NSDate date]]==NSOrderedAscending)
            continue;
        localNotification = [[UILocalNotification alloc] init];
        
        localNotification.alertBody = NSLocalizedStringFromTable(@"Party time!", @"language", nil);
        localNotification.alertAction = [NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"is about to begin!", @"language", nil),party.partyName];
        localNotification.fireDate = [[formatter dateFromString:beginDate] dateByAddingTimeInterval:10];
        localNotification.userInfo = @{ @"party_id" : party.partyID };
        localNotification.applicationIconBadgeNumber = 1;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.repeatInterval = 0;
        localNotification.category = @"LocalNotificationDefaultCategory";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        UIMutableUserNotificationAction *doneAction = [[UIMutableUserNotificationAction alloc] init];
        doneAction.identifier = @"doneActionIdentifier";
        doneAction.destructive = NO;
        doneAction.title = NSLocalizedStringFromTable(@"Mark done", @"language", nil);
        doneAction.activationMode = UIUserNotificationActivationModeBackground;
        doneAction.authenticationRequired = NO;
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = @"LocalNotificationDefaultCategory";
        [category setActions:@[doneAction] forContext:UIUserNotificationActionContextMinimal];
        [category setActions:@[doneAction] forContext:UIUserNotificationActionContextDefault];
        NSSet *categories = [[NSSet alloc] initWithArray:@[category]];
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings
                                                            settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([LWTPartyStorage partiesStorage].changesToLoad){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadTheTable" object:nil];
    [[LWTCoreDataAPI coreData] loadPartiesFromDatabase];
    [LWTPartyStorage partiesStorage].changesToLoad = YES;
    if([LWTPartyStorage partiesStorage].creatorID){
        [[LWTPartyStorage partiesStorage] loadPartiesFromInternetToMainArray];
    }
    self.table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.table addSubview:self.refreshControl];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Back", @"language", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor colorWithRed:29/255. green:31/255. blue:36/255. alpha:1],
                                        NSForegroundColorAttributeName,
                                        [UIFont fontWithName:@"MyriadPro-Regular" size:16], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:29/255. green:31/255. blue:36/255. alpha:1];
}
- (void)refresh:(UIRefreshControl *)refreshControl {
    [[LWTPartyStorage partiesStorage] loadPartiesFromInternetToMainArray];
}
-(void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int selectedRow = (int)indexPath.row;
    NSLog(@"touch on row %d", selectedRow);
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"PartyInfoSegue"] ){
        LWTPartyInfoViewController *vc = segue.destinationViewController;
        vc.selectedPartyNumber = (int)[self.table indexPathForSelectedRow].row;
    }
    else if([segue.identifier isEqualToString:@"NewPartySegue"]){
        LWTEventView *vc = segue.destinationViewController;
        vc.displayedPartyNumber = -1;
    }
}
#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[LWTPartyStorage partiesStorage].parties count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LWTTableViewCell *cell = (LWTTableViewCell*) [tableView dequeueReusableCellWithIdentifier:[LWTTableViewCell reuseIdentifier] forIndexPath:indexPath];
    
    [cell configureWithParty:[[LWTPartyStorage partiesStorage].parties objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
