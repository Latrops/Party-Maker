//
//  LWTAnnotationView.h
//  Party Maker
//
//  Created by 2 on 2/23/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "LWTParty.h"
#import "LWTPartyStorage.h"

@interface LWTAnnotationView : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic) CLPlacemark *placemark;
@property (nonatomic) NSNumber *imageNumber;
@property (nonatomic) int partyNumber;

-(MKAnnotationView*)annotationView;
-(id)initWithPartyAndSubtitle:(LWTParty*)party subtitle:(NSString*)subtitle location:(CLLocationCoordinate2D)location;
-(id)initWithParty:(LWTParty*)party;
@end
