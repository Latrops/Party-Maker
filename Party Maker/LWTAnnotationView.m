//
//  LWTAnnotationView.m
//  Party Maker
//
//  Created by 2 on 2/23/16.
//  Copyright © 2016 latrops. All rights reserved.
//

#import "LWTAnnotationView.h"

@implementation LWTAnnotationView


-(MKAnnotationView*)annotationView{
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"asdasd"];
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.draggable = YES;
    annotationView.animatesDrop = YES;
    if(self.imageNumber){
        UIImageView *myCustomImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        myCustomImage.contentMode = UIViewContentModeScaleAspectFit;
        switch ([self.imageNumber intValue]) {
            case 0:
                myCustomImage.image =  [UIImage imageNamed:@"PartyLogo_Small_0.png"];
                annotationView.pinTintColor =[UIColor grayColor];
                break;
            case 1:
                myCustomImage.image =  [UIImage imageNamed:@"PartyLogo_Small_1.png"];
                annotationView.pinTintColor =[UIColor purpleColor];
                break;
            case 2:
                myCustomImage.image =  [UIImage imageNamed:@"PartyLogo_Small_2.png"];
                annotationView.pinTintColor =[UIColor greenColor];
                break;
            case 3:
                myCustomImage.image =  [UIImage imageNamed:@"PartyLogo_Small_3.png"];
                annotationView.pinTintColor =[UIColor yellowColor];
                break;
            case 4:
                myCustomImage.image =  [UIImage imageNamed:@"PartyLogo_Small_4.png"];
                annotationView.pinTintColor =[UIColor redColor];
                break;
            case 5:
                myCustomImage.image =  [UIImage imageNamed:@"PartyLogo_Small_5.png"];
                annotationView.pinTintColor =[UIColor blueColor];
                break;
                
            default:
                break;
        }
        annotationView.leftCalloutAccessoryView = myCustomImage;
    }
    
    return annotationView;
}
-(id)initWithPartyAndSubtitle:(LWTParty*)party subtitle:(NSString*)subtitle location:(CLLocationCoordinate2D)location{
    self = [super init];
    
    if(self){
        if(party){
            self.title = party.partyName;
            self.imageNumber = party.partyImageNumber;
        } else {
            self.title = NSLocalizedStringFromTable(@"New party", @"language", nil);
        }
        self.coordinate = location;
        self.subtitle = subtitle;
    }
    
    return self;
}
-(id)initWithParty:(LWTParty*)party{
    self = [super init];
    
    if(self){
        self.title = party.partyName;
        self.imageNumber = party.partyImageNumber;
        CLLocationCoordinate2D location;
        NSArray *strings = [(NSString*)party.longtitude componentsSeparatedByString: @";"];
        if([strings count]>1){
            location.latitude = [[strings objectAtIndex:0] floatValue];
            location.longitude = [[strings objectAtIndex:1] floatValue];
            self.coordinate = location;
        } else {
            NSLog(@"Location had wrong format");
        }
        self.subtitle = party.latitude;
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
