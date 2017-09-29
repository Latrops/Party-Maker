//
//  LWTMapMultiplePartiesViewController.m
//  Party Maker
//
//  Created by 2 on 2/25/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTMapMultiplePartiesViewController.h"
#import "LWTAnnotationView.h"
#import "LWTPartyInfoViewController.h"
#import "LWTPartyMakerSDK.h"
#import "LWTUser.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LWTMapMultiplePartiesViewController ()
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,strong)CLLocationManager *manager;
@property NSArray <LWTUser*> *usersToDisplay;
@property NSMutableArray *partiesToDisplay;
@property NSMutableArray <LWTAnnotationView *> *pinsWithParties;
@property LWTPartyInfoViewController *partyInfoViewController;

@property (nonatomic) BOOL tableViewIsDisplayed;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet NSLayoutConstraint *tableYConstaint;
@property (nonatomic) IBOutlet NSLayoutConstraint *tableHeightConstaint;
@end
@implementation LWTMapMultiplePartiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[CLLocationManager alloc]init];
    self.manager.delegate = self;
    self.mapView.delegate = self;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    tapRecognizer.delegate = self;
    [self.mapView addGestureRecognizer:tapRecognizer];
    [self showLoggedUserParties];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(self.tableViewIsDisplayed)
       [self hideTableView];
    return YES;
}
-(IBAction)userPickButtonPressed:(id)sender{
    if(self.tableViewIsDisplayed){
        [self hideTableView];
        return;
    }
    [[LWTPartyStorage partiesStorage] loadAllUsers:^{
        self.usersToDisplay = [LWTPartyStorage partiesStorage].usersBase;
        NSInteger userCount = [self.usersToDisplay count];
        self.tableHeightConstaint.constant = userCount>10?424:38.5*(userCount+1);
        [self.view layoutIfNeeded];
        [self.tableView reloadData];
        [self showTableView];
    }];
}
-(IBAction)resetUserButtonPressed:(id)sender{
    if(self.tableViewIsDisplayed)
       [self hideTableView];
    [self showLoggedUserParties];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[LWTAnnotationView class]]) {
        LWTAnnotationView *myAnnotation = (LWTAnnotationView*)annotation;
        MKAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyAnnotationReuseIdentifier"];
        if (!pinView) {
            pinView = myAnnotation.annotationView;
            pinView.draggable = false;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    return nil;
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    LWTParty *party = self.partiesToDisplay[((LWTAnnotationView*)view.annotation).partyNumber];
    
    self.partyInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PartyInfo"];
    self.partyInfoViewController.mapParty = party;
    [self.navigationController pushViewController:self.partyInfoViewController animated:YES];
}
-(void)showLoggedUserParties{
    LWTParty *party;
    
    self.partiesToDisplay = [LWTPartyStorage partiesStorage].parties;
    if(self.pinsWithParties)
        [self.mapView removeAnnotations:self.pinsWithParties];
    
    self.pinsWithParties = [[NSMutableArray alloc] init];
    for(int i=0; i<[self.partiesToDisplay count]; i++){
        party = self.partiesToDisplay[i];
        if(![party.latitude isEqualToString:@""]){
            LWTAnnotationView *annotation = [[LWTAnnotationView alloc] initWithParty:party];
            annotation.partyNumber = i;
            [self.pinsWithParties addObject:annotation];
        }
    }
    [self.mapView showAnnotations:self.pinsWithParties animated:YES];
}

#pragma mark -TableView methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [[LWTPartyStorage partiesStorage] loadPartiesFromInternetWithUserID:[self.usersToDisplay[(int)indexPath.row].userID intValue] completion:^{
        [self hideTableView];
        
        self.partiesToDisplay = [LWTPartyStorage partiesStorage].tempInternetBase;
        [self.mapView removeAnnotations:self.pinsWithParties];
        
        if([self.partiesToDisplay count]>0){
            self.pinsWithParties = [[NSMutableArray alloc] init];
            LWTParty *party;
            for(int i=0; i<[self.partiesToDisplay count]; i++){
                party = self.partiesToDisplay[i];
                if(![party.latitude isEqualToString:@""]){
                    LWTAnnotationView *annotation = [[LWTAnnotationView alloc] initWithParty:party];
                    annotation.partyNumber = i;
                    [self.pinsWithParties addObject:annotation];
                    [self.mapView showAnnotations:self.pinsWithParties animated:YES];
                }
            }
        }
        if([self.pinsWithParties count]<1){
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            
            hud.labelText = @"No parties to display";
            [hud hide:YES afterDelay:2];
        }
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersToDisplay count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InternsCellReuseIdentifier"];
    if(!cell){
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = [self.usersToDisplay objectAtIndex:indexPath.row].userName;
    } else
        cell.textLabel.text = [self.usersToDisplay objectAtIndex:indexPath.row].userName;
    
    return cell;
}
-(void)showTableView{
    self.tableViewIsDisplayed = YES;
    __weak LWTMapMultiplePartiesViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.tableYConstaint.constant +=424;
        [weakSelf.view layoutIfNeeded];
    }];
}
-(void)hideTableView{
    self.tableViewIsDisplayed = NO;
    __weak LWTMapMultiplePartiesViewController *weakSelf = self;
    [weakSelf.view layoutIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.tableYConstaint.constant -=424;
        [weakSelf.view layoutIfNeeded];
    }];
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
