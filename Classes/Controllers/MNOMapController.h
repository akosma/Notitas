//
//  MNOMapController.h
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class Note;

@interface MNOMapController : UIViewController 

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UINavigationItem *titleItem;
@property (nonatomic, strong) Note *note;
@property (nonatomic, weak) id<MKMapViewDelegate> delegate;

- (IBAction)done:(id)sender;

@end
