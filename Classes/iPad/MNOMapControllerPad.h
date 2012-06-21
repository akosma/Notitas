//
//  MNOMapControllerPad.h
//  Notitas
//
//  Created by Adrian on 9/18/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MNOMapControllerPad : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) UIViewController *parent;

- (IBAction)done:(id)sender;
- (IBAction)changeMapType:(id)sender;

@end
