//
//  LWTPartyInfoViewController.m
//  Party Maker
//
//  Created by 2 on 2/13/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTPartyInfoViewController.h"
#import "LWTPartyStorage.h"
#import "LWTEventView.h"
#import "NSNumber+Utility.h"
#import "LWTPartyMakerSDK.h"
#import "LWTMapViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

@interface LWTPartyInfoViewController ()

@property IBOutlet UILabel *partyNameLabel;
@property IBOutlet UILabel *partyDescriptionLabel;
@property IBOutlet UILabel *partyDateLabel;
@property IBOutlet UILabel *partyStartLabel;
@property IBOutlet UILabel *partyEndLabel;
@property IBOutlet UIImageView *partyImage;
@property IBOutlet UIButton *deleteButton;
@property IBOutlet UIButton *locationButton;
@property IBOutlet UIButton *editButton;

@property IBOutlet NSLayoutConstraint *scrollViewContentBottomConstraint;

@end

@implementation LWTPartyInfoViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initWithParty];
}
-(IBAction)locationButtonTouchUpInside:(id)sender{
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getDate:) name:@"LocationString" object:nil]; 
}
-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(IBAction)deleteButtonTouchUpInside:(id)sender{
    if(![[LWTPartyStorage partiesStorage] isWebReachable]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedStringFromTable(@"Error!", @"language", nil) message:NSLocalizedStringFromTable(@"Cannot connect to server", @"language", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    __block __weak LWTParty *partyToDelete = [LWTPartyStorage partiesStorage].parties[(int)self.selectedPartyNumber];
    
    [[LWTCoreDataAPI coreData] performWriteOperation:^(NSManagedObjectContext *context) {
        [[LWTPartyStorage partiesStorage] removePartyWithID:partyToDelete.partyID];
    } completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)getDate:(NSNotification*)notification
{
    LWTParty *selectedParty = [LWTPartyStorage partiesStorage].parties[self.selectedPartyNumber];
    // Update the UILabel's text to that of the notification object posted from the other view controller
    NSArray *strings = [(NSString*)notification.object componentsSeparatedByString: @"#"];
    selectedParty.latitude = [strings objectAtIndex:0];
    selectedParty.longtitude = [strings objectAtIndex:1];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LWTPartyStorage partiesStorage] saveParty:selectedParty completion:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"PartyInfoLocationSegue"]){
        LWTParty *selectedParty = [LWTPartyStorage partiesStorage].parties[self.selectedPartyNumber];
        if([selectedParty.longtitude isEqualToString:@""]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedStringFromTable(@"Error!", @"language", nil) message:NSLocalizedStringFromTable(@"Location not set", @"language", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"EditPartySegue"] ){
        LWTEventView *vc = segue.destinationViewController;
        vc.displayedPartyNumber = self.selectedPartyNumber;
    }
    if([segue.identifier isEqualToString:@"PartyInfoLocationSegue"]){
        LWTMapViewController *vc = segue.destinationViewController;
        vc.selectedPartyNumber = @(self.selectedPartyNumber);
    }
}
-(void)initWithParty{
    LWTParty *selectedParty;
    if(self.mapParty){
        selectedParty = self.mapParty;
        self.scrollViewContentBottomConstraint.constant -= 175;
        [self.view layoutIfNeeded];
        [self.deleteButton setHidden:YES];
        [self.locationButton setHidden:YES];
        [self.editButton setHidden:YES];
    }
    else
        selectedParty = [LWTPartyStorage partiesStorage].parties[self.selectedPartyNumber];
    
    self.partyNameLabel.text = selectedParty.partyName;
    self.partyStartLabel.text = [NSNumber timeFromFloat:selectedParty.partyStartTime];
    self.partyEndLabel.text = [NSNumber timeFromFloat:selectedParty.partyEndTime];
    self.partyDateLabel.text = selectedParty.partyDate;
    switch ([selectedParty.partyImageNumber intValue]) {
        case 0:
            self.partyImage.image =  [UIImage imageNamed:@"PartyLogo_Small_0.png"];
            break;
        case 1:
            self.partyImage.image =  [UIImage imageNamed:@"PartyLogo_Small_1.png"];
            break;
        case 2:
            self.partyImage.image =  [UIImage imageNamed:@"PartyLogo_Small_2.png"];
            break;
        case 3:
            self.partyImage.image =  [UIImage imageNamed:@"PartyLogo_Small_3.png"];
            break;
        case 4:
            self.partyImage.image =  [UIImage imageNamed:@"PartyLogo_Small_4.png"];
            break;
        case 5:
            self.partyImage.image =  [UIImage imageNamed:@"PartyLogo_Small_5.png"];
            break;
            
        default:
            break;
    }
    self.partyDescriptionLabel.text = selectedParty.partyDescription;
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
