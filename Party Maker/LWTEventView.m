//
//  LWTEventView.m
//  Party Maker
//
//  Created by 2 on 2/8/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTEventView.h"
#import "LWTPartyStorage.h"
#import "NSNumber+Utility.h"
#import "LWTMapViewController.h"

@interface LWTEventView () <UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic) LWTParty *displayedParty;
@property (nonatomic) float scrollViewXSize;

@property (nonatomic) NSMutableArray <UIView*> *points;
@property (nonatomic) IBOutlet UILabel *beginTime;
@property (nonatomic) IBOutlet UILabel *endTime;
@property (nonatomic) IBOutlet UISlider *beginTimeSlider;
@property (nonatomic) IBOutlet UISlider *endTimeSlider;
@property (nonatomic) BOOL datePickerDisplayed;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) IBOutlet UIView *datePickerView;
@property (nonatomic) NSDate *tempPartyDate;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *longitude;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) UIView *interactionBlocker;
@property (nonatomic) IBOutlet UITextField *partyNameField;
@property (nonatomic) IBOutlet UITextView *partyDescription;
@property (nonatomic) NSString *partyDescriptionText;
@property (nonatomic,weak) IBOutlet UIButton *chooseDateButton;
@property (nonatomic,weak) IBOutlet UIButton *locationButton;
@property (nonatomic) IBOutlet UIView *dateView;

@property (nonatomic) IBOutlet NSLayoutConstraint *movingCircleYConstraint;
@property (nonatomic,weak) IBOutlet UIView *moveingCircle;
@property (nonatomic,weak) IBOutlet UIView *circle1;
@property (nonatomic,weak) IBOutlet UIView *circle2;
@property (nonatomic,weak) IBOutlet UIView *circle3;
@property (nonatomic,weak) IBOutlet UIView *circle4;
@property (nonatomic,weak) IBOutlet UIView *circle5;
@property (nonatomic,weak) IBOutlet UIView *circle6;
@property (nonatomic,weak) IBOutlet UIView *circle7;

@property (nonatomic,weak) IBOutlet UIView *test;

@end

@implementation LWTEventView
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
-(void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"MyriadPro-Bold" size:15]}];
    
    self.navigationItem.hidesBackButton = YES;
    self.scrollView.delegate = self;
    self.partyDescription.delegate = self;
    
    NSArray *viewArray = [NSArray arrayWithObjects:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PartyLogo_Small_0.png"]],
                          [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PartyLogo_Small_1.png"]],
                          [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PartyLogo_Small_2.png"]],
                          [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PartyLogo_Small_3.png"]],
                          [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PartyLogo_Small_4.png"]],
                          [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PartyLogo_Small_5.png"]],nil];
    float scrollViewYOffset = 184;
    self.scrollViewXSize = self.view.frame.size.width - 125;
    float scrollViewYSize = (self.view.frame.size.height - scrollViewYOffset -56 - self.navigationController.navigationBar.layer.frame.size.height - self.tabBarController.tabBar.layer.frame.size.height - 12)/2.;
    for(int i=0; i<viewArray.count; i++)
    {
        CGRect frame;
        UIImageView *image = [viewArray objectAtIndex:i];
        frame.origin.x = self.scrollViewXSize * i+(self.scrollViewXSize/2. - image.frame.size.width/2.);
        frame.origin.y = (scrollViewYSize)/2. - image.frame.size.height/2. -10;
        frame.size = image.frame.size;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        [subview addSubview:[viewArray objectAtIndex:i]];
        [self.scrollView addSubview:subview];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollViewXSize*6, scrollViewYSize);
    
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 375, 50)];
    toolbar.barTintColor = [UIColor colorWithRed:68/255.f green:73/255.f blue:83/255.f alpha:1.f];
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"language", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardBarCancel)];
    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Done", @"language", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onKeyBoardBarDone)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    itemDone.tintColor = itemCancel.tintColor = [UIColor whiteColor];
    toolbar.items = @[itemCancel, flexibleSpace, itemDone];
    [toolbar sizeToFit];
    
    self.interactionBlocker = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.interactionBlocker.userInteractionEnabled = YES;
    
    self.partyDescription.inputAccessoryView = toolbar;
    self.partyNameField.textAlignment = NSTextAlignmentCenter;
    if ([self.partyNameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:76/255. green:82/255. blue:92/255. alpha:1];
        self.partyNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedStringFromTable(@"Your party name", @"language", nil) attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cant change placeholder's text color.");
    }
    self.partyNameField.backgroundColor = [UIColor colorWithRed:35/255.f green:37/255.f blue:43/255.f alpha:1.f];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getDate:) name:@"LocationString" object:nil];
    self.latitude=@"";
    self.longitude=@"";
    if(self.displayedPartyNumber>=0){
        [self initWithParty];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if(self.latitude){
        if(![self.latitude isEqualToString:@""])
            [self.locationButton setTitle:self.latitude forState:UIControlStateNormal];
        
    }
    
    
}
- (void)getDate:(NSNotification*)notification
{
    NSArray *strings = [(NSString*)notification.object componentsSeparatedByString: @"#"];
    self.latitude = [strings objectAtIndex:0];
    self.longitude = [strings objectAtIndex:1];
}
#pragma mark -Actions
- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}
- (void)onKeyBoardBarCancel {
    self.partyDescription.text = self.partyDescriptionText;
    [self.partyDescription resignFirstResponder];
}
- (void)onKeyBoardBarDone {
    self.partyDescriptionText = self.partyDescription.text;
    [self.partyDescription resignFirstResponder];
}
- (void)keyboardWillShow:(NSNotification*)notification {
    if(![[self.view subviews] containsObject:self.interactionBlocker])
        [self.view addSubview:self.interactionBlocker];
    else return;
    if(self.partyNameField.isFirstResponder)
        return;
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    __block __weak LWTEventView *weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:0 animations:^{
        CGRect viewFrame = weakSelf.view.frame;
        viewFrame.origin.y -= keyboardRect.size.height-self.tabBarController.tabBar.frame.size.height;
        weakSelf.view.frame = viewFrame;
    } completion:nil];
}
-(void)keyboardWillHide:(NSNotification*)notification {
    [self.interactionBlocker removeFromSuperview];
    if(self.partyNameField.isFirstResponder)
        return;
    float duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    __weak LWTEventView *weakSelf = self;
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        CGRect viewFrame = weakSelf.view.frame;
        viewFrame.origin.y += keyboardRect.size.height-self.tabBarController.tabBar.frame.size.height;
        weakSelf.view.frame = viewFrame;
    }];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"CreatePartyLocationSegue"]){
        LWTMapViewController *vc = segue.destinationViewController;
        if(self.displayedPartyNumber>=0)
            vc.selectedPartyNumber = @(self.displayedPartyNumber);
        vc.pinShoudBeEditable = YES;
    }
}
- (IBAction)onPageChanged:(UIPageControl*)sender{
    [self moveCircle:(4)];
    CGPoint contentOffset = CGPointMake(sender.currentPage*self.scrollView.frame.size.width, 0);
    [self.scrollView setContentOffset:contentOffset animated:YES];
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self moveCircle:(4)];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self moveCircle:(4)];
    NSInteger currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    [self.pageControl setCurrentPage:currentPage];
}
-(IBAction)beginTimeSliderMoved:(id)sender{
    int time = self.beginTimeSlider.value;
    self.beginTime.text = [NSNumber timeFromFloat:@(time)];
    if((self.endTimeSlider.value-30)<time){
        self.endTimeSlider.value = time+30;
        if(self.endTimeSlider.value==1440){
            self.endTime.text = @"00:00";
        }else{
            self.endTime.text = [NSNumber timeFromFloat:@(time+30)];
        }
    }
}
-(IBAction)endTimeSliderMoved:(id)sender{
    int time = self.endTimeSlider.value;
    if(self.endTimeSlider.value == 1440){
        self.endTime.text = @"00:00";
    } else {
        self.endTime.text = [NSNumber timeFromFloat:@(time)];
    }
    if((time-30)<self.beginTimeSlider.value){
        self.beginTimeSlider.value = time-30;
        self.beginTime.text = [NSNumber timeFromFloat:@(time-30)];
    }
}
-(IBAction)datePickerActionDone:(id)sender{
    [self removeDateView];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy";
    if (self.tempPartyDate) {
        [self.chooseDateButton setTitle:[dateFormatter stringFromDate:self.tempPartyDate]forState:UIControlStateNormal];
    } else {
        [self.chooseDateButton setTitle:[dateFormatter stringFromDate:[NSDate date]]forState:UIControlStateNormal];
    }
    self.tempPartyDate = nil;
}
-(IBAction)datePickerActionCancel:(id)sender{
    [self removeDateView];
}
-(void)removeDateView{
    __block __weak LWTEventView *weakBackground = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect viewFrame = weakBackground.dateView.frame;
        viewFrame.origin.y += 260+self.tabBarController.tabBar.frame.size.height;
        weakBackground.dateView.frame = viewFrame;
    } completion:^(BOOL finished) {
        [weakBackground.dateView removeFromSuperview];
        [weakBackground.interactionBlocker removeFromSuperview];
    }];
}
-(IBAction)datePickerValueChanged:(id)sender{
    self.tempPartyDate = self.datePicker.date;
}
-(IBAction)btnChooseDatePressed:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if([[self.view subviews] containsObject:self.dateView])
        return;
    [self.view addSubview:self.interactionBlocker];
    if (![self.chooseDateButton.titleLabel.text  isEqual: NSLocalizedStringFromTable(@"CHOOSE DATE", @"language", nil)]){
        formatter.dateFormat = @"dd.MM.yyyy";
        [self.datePicker setDate:[formatter dateFromString:self.chooseDateButton.titleLabel.text]];
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += 260;
    self.dateView.frame = viewFrame;
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.view addSubview:self.dateView];
    __block __weak UIView *weakBackground = self.dateView;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect viewFrame = weakBackground.frame;
        viewFrame.origin.y -= 260+self.tabBarController.tabBar.frame.size.height;
        weakBackground.frame = viewFrame;
    }];
}
-(IBAction)cancelButtonPressed:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)saveButtonPressed:(id)sender{
    if ([self.chooseDateButton.titleLabel.text  isEqual: NSLocalizedStringFromTable(@"CHOOSE DATE", @"language", nil)]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"Error!", @"language", nil) message:NSLocalizedStringFromTable(@"Choose date.", @"language", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if ([self.partyNameField.text isEqual:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedStringFromTable(@"Error!", @"language", nil) message:NSLocalizedStringFromTable(@"Enter party name.", @"language", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if(![[LWTPartyStorage partiesStorage] isWebReachable]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: NSLocalizedStringFromTable(@"Error!", @"language", nil) message:NSLocalizedStringFromTable(@"Cannot connect to server", @"language", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    LWTParty *partyData = [[LWTParty alloc] init];
    partyData.partyName = [self.partyNameField.text stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    partyData.partyDate = self.chooseDateButton.titleLabel.text;
    partyData.partyStartTime = @(self.beginTimeSlider.value);
    partyData.partyEndTime = @(self.endTimeSlider.value);
    partyData.partyImageNumber = @(self.pageControl.currentPage);
    partyData.partyDescription = [self.partyDescriptionText stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    partyData.partyID = self.displayedParty.partyID;
    partyData.longtitude = self.longitude;
    partyData.latitude = [[self.latitude stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"] stringByReplacingOccurrencesOfString:@"|" withString:@"\\|"];
    
    [[LWTPartyStorage partiesStorage] saveParty:partyData completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(IBAction)dateTouchDown:(id)sender{
    [self moveCircle:(0)];
}
-(IBAction)nameTouchDown:(id)sender{
    [self moveCircle:(1)];
}
-(IBAction)beginTimeTouchDown:(id)sender{
    [self moveCircle:(2)];
}
-(IBAction)endTimeTouchDown:(id)sender{
    [self moveCircle:(3)];
}
-(IBAction)descriptionTouchDown:(id)sender{
    [self moveCircle:(5)];
}
-(IBAction)endButtonsTouchDown:(id)sender{
    [self moveCircle:(6)];
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self moveCircle:(5)];
}
-(void)moveCircle:(int) circlePos{
    float yCoordinate;
    switch (circlePos) {
        case 0:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle1.frame.origin.y +2;
            break;
        case 1:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle2.frame.origin.y +2;
            break;
        case 2:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle3.frame.origin.y +2;
            break;
        case 3:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle4.frame.origin.y +2;
            break;
        case 4:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle5.frame.origin.y +2;
            break;
        case 5:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle6.frame.origin.y +2;
            break;
        case 6:
            yCoordinate = self.moveingCircle.frame.origin.y - self.circle7.frame.origin.y +2;
            break;
        default:
            yCoordinate = 0;
            break;
    }
    [self.view layoutIfNeeded];
    __block __weak LWTEventView *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.movingCircleYConstraint.constant -=yCoordinate;
        [weakSelf.view layoutIfNeeded];
    }];
}
-(IBAction)locationBtnDown:(id)sender{
    [self moveCircle:(6)];
}

#pragma mark - Init
-(void)initWithParty{
    self.displayedParty = [LWTPartyStorage partiesStorage].parties[(int)self.displayedPartyNumber];
    self.partyNameField.text = self.displayedParty.partyName;
    self.beginTimeSlider.value = [self.displayedParty.partyStartTime floatValue];
    self.beginTime.text = [NSNumber timeFromFloat:self.displayedParty.partyStartTime];
    self.endTimeSlider.value = [self.displayedParty.partyEndTime floatValue];
    self.endTime.text = [NSNumber timeFromFloat:self.displayedParty.partyEndTime];
    [self.chooseDateButton setTitle:self.displayedParty.partyDate forState:UIControlStateNormal];
    CGPoint contentOffset = CGPointMake([self.displayedParty.partyImageNumber intValue]*self.scrollViewXSize, 0);
    [self.scrollView setContentOffset:contentOffset animated:NO];
    [self.pageControl setCurrentPage:[self.displayedParty.partyImageNumber intValue]];
    self.partyDescription.text = self.displayedParty.partyDescription;
    self.partyDescriptionText = self.displayedParty.partyDescription;
    if(self.displayedParty.latitude){
        if(![self.displayedParty.latitude isEqualToString:@""])
            [self.locationButton setTitle:self.displayedParty.latitude forState:UIControlStateNormal];
        
    }
}

@end
