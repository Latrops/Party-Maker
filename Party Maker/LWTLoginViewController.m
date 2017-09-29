//
//  LWTLoginViewController.m
//  Party Maker
//
//  Created by 2 on 2/15/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTLoginViewController.h"
#import "LWTPartyMakerSDK.h"
#import "LWTPartyStorage.h"
@interface LWTLoginViewController()
@property IBOutlet UITextField *loginTextField;
@property IBOutlet UITextField *passwordTextField;
@property IBOutlet UIView *containerView;
@property IBOutlet UILabel *errorLabel;
@property (nonatomic) IBOutlet NSLayoutConstraint *errorLabelYConstraint;

@end

@implementation LWTLoginViewController
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.containerView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.containerView.layer setBorderWidth:1];
    if ([self.loginTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:76/255. green:82/255. blue:92/255. alpha:1];
        self.loginTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"Login", @"language", nil) attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cant change placeholder's text color.");
    }
    if ([self.passwordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:76/255. green:82/255. blue:92/255. alpha:1];
        self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"Password", @"language", nil) attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cant change placeholder's text color.");
    }
}

#pragma mark - UI Implementation
-(IBAction)nameFinished:(id)sender{
    [self.passwordTextField becomeFirstResponder];
}
-(IBAction)passwordFinished:(id)sender{
    [self loginButtonPressed:sender];
}
-(IBAction)loginButtonPressed:(id)sender{
    [self.containerView setUserInteractionEnabled:NO];
    if(![[LWTPartyStorage partiesStorage] isWebReachable]){
        [self showError:NSLocalizedStringFromTable(@"Cannot connect to server", @"language", nil)];
        return;
    }
    
    [[LWTPartyStorage partiesStorage]loginWithUsernamePassword:self.loginTextField.text
                                                      password:self.passwordTextField.text
                                                    completion:^(NSString *error) {
        if(error){
            [self showError:error];
        } else {
            [LWTPartyStorage partiesStorage].changesToLoad = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
-(IBAction)registerButtonPressed:(id)sender{
    [self.containerView setUserInteractionEnabled:NO];
    if(![[LWTPartyStorage partiesStorage] isWebReachable]){
        [self showError:NSLocalizedStringFromTable(@"Cannot connect to server", @"language", nil)];
        return;
    }
    [[LWTPartyStorage partiesStorage] registerUserWithUsernamePassword:self.loginTextField.text
                                                              password:self.passwordTextField.text
                                                            completion:^(NSString *error) {
        if(error){
            [self showError:error];
        } else {
            [LWTPartyStorage partiesStorage].changesToLoad = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
-(void)showError:(NSString*)error{
    __weak LWTLoginViewController *weakself = self;
    self.errorLabel.text = error;
    [self.containerView setUserInteractionEnabled:YES];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        weakself.errorLabelYConstraint.constant =15;
        [weakself.view layoutIfNeeded];
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
