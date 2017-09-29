//
//  LWTMapViewController.h
//  Party Maker
//
//  Created by 2 on 2/23/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LWTParty.h"

@interface LWTMapViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,UIGestureRecognizerDelegate>
@property NSNumber *selectedPartyNumber;
@property (nonatomic) BOOL pinShoudBeEditable;
@end
