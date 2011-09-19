//
//  MapControllerPad.h
//  Notitas
//
//  Created by Adrian on 9/18/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapControllerPad : UIViewController

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) UIViewController *parent;

- (IBAction)done:(id)sender;

@end
