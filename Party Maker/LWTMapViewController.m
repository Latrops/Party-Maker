//
//  LWTMapViewController.m
//  Party Maker
//
//  Created by 2 on 2/23/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTMapViewController.h"
#import "LWTAnnotationView.h"
#import "LWTPartyStorage.h"

@interface LWTMapViewController ()
@property IBOutlet MKMapView *mapView;
@property (nonatomic,strong)CLLocationManager *manager;
@property (nonatomic) LWTAnnotationView *pin;
@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) LWTParty *selectedParty;

@property (nonatomic) BOOL showUserLocation;
@end

@implementation LWTMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[CLLocationManager alloc]init];
    self.manager.delegate = self;
    self.mapView.delegate = self;
    
    if(!self.selectedParty && self.selectedPartyNumber){
        CLLocationCoordinate2D location;
        self.selectedParty = [[LWTPartyStorage partiesStorage].parties objectAtIndex:[self.selectedPartyNumber intValue]];
        NSArray *strings = [(NSString*)self.selectedParty.longtitude componentsSeparatedByString: @";"];
        if([strings count]>1){
            location.latitude = [[strings objectAtIndex:0] floatValue];
            location.longitude = [[strings objectAtIndex:1] floatValue];
            [self geocodeLocation:location];
        }else
            self.showUserLocation = YES;
    } else
        self.showUserLocation = YES;
    if(self.showUserLocation)
       [self.manager requestWhenInUseAuthorization];
    if(self.pinShoudBeEditable){
        UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapClicked:)];
        longTapRecognizer.delegate = self;
        longTapRecognizer.minimumPressDuration =0.5;
        [self.mapView addGestureRecognizer:longTapRecognizer];
    }
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == 2){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    
    if(status==4 && self.showUserLocation){
        NSLog(@"We are authorized for location check");
        self.mapView.showsUserLocation = YES;
    }
}
- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    CLLocationCoordinate2D location;
    
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    self.mapView.showsUserLocation = NO;
    [self geocodeLocation:location];
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    NSLog(@"%@",touch.view.class);
    if (![touch.view isKindOfClass:[MKAnnotationView class]]) {
        return YES;
    }
    return NO;
}
-(IBAction)mapClicked:(UITapGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan){
        if(self.pin){
            [self.mapView removeAnnotation:self.pin.annotationView.annotation];
            self.mapView.showsUserLocation = NO;
        }
        CGPoint point = [recognizer locationInView:self.mapView];
        CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        [self geocodeLocation:tapPoint];
    }
}
- (void)geocodeLocation:(CLLocationCoordinate2D)location {
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    if(!self.geocoder){
        self.geocoder = [[CLGeocoder alloc]init];
    }
    [self.geocoder reverseGeocodeLocation:loc completionHandler: ^(NSArray* placemarks, NSError* error){
        if ([placemarks count] > 0) {
            CLPlacemark *placemark =  [placemarks objectAtIndex:0];
            if(self.selectedPartyNumber){
                self.pin = [[LWTAnnotationView alloc] initWithPartyAndSubtitle:[[LWTPartyStorage partiesStorage].parties objectAtIndex:[self.selectedPartyNumber intValue]] subtitle:placemark.name location:location];
            } else
                self.pin = [[LWTAnnotationView alloc] initWithPartyAndSubtitle:nil subtitle:placemark.name location:location];
            [self.mapView showAnnotations:@[self.pin] animated:YES];
        }
    }];
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        [view.annotation setCoordinate:droppedAt];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        if(!self.geocoder){
            self.geocoder = [[CLGeocoder alloc]init];
        }
        
        __weak LWTMapViewController *weakSelf = self;
        [self.geocoder reverseGeocodeLocation:loc completionHandler: ^(NSArray* placemarks, NSError* error){
            if ([placemarks count] > 0) {
                CLPlacemark *placemark =  [placemarks objectAtIndex:0];
                weakSelf.pin.subtitle = placemark.name;
                //[view.annotation setc:droppedAt];
            }
        }];
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //Replacing user location with our annotation
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        [self geocodeLocation:((MKUserLocation*)annotation).location.coordinate];
        self.mapView.showsUserLocation = NO;
        return [[LWTAnnotationView alloc] initWithPartyAndSubtitle:[LWTPartyStorage partiesStorage].parties[0] subtitle:@"" location:((MKUserLocation*)annotation).location.coordinate].annotationView;
    }
    if ([annotation isKindOfClass:[LWTAnnotationView class]]) {
        LWTAnnotationView *myAnnotation = (LWTAnnotationView*)annotation;
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyAnnotationReuseIdentifier"];
        if (!pinView) {
            pinView = (MKPinAnnotationView*)myAnnotation.annotationView;
            if(!self.pinShoudBeEditable){
                [pinView setDraggable:NO];
            } else {
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
                [rightButton addTarget:nil action:@selector(saveParty) forControlEvents:UIControlEventTouchUpInside];
                pinView.rightCalloutAccessoryView = rightButton;
            }
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    return nil;
}
-(void)saveParty{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationString" object:[NSString stringWithFormat:@"%@#%f;%f",self.pin.subtitle, self.pin.coordinate.latitude, self.pin.coordinate.longitude]];
    
    [self.navigationController popViewControllerAnimated:YES];
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
