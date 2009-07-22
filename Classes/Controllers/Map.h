//
//  Map.h
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Map : UIViewController 
{
@private
    IBOutlet MKMapView *_mapView;
    CLLocation *_location;
}

@property (nonatomic, retain) CLLocation *location;

- (IBAction)done:(id)sender;

@end
