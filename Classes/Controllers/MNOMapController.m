//
//  MNOMapController.m
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNOMapController.h"
#import "MNOModels.h"

@interface MNOMapController ()

@property (nonatomic, strong) MKPlacemark *placemark;

@end


@implementation MNOMapController

- (void)dealloc 
{
    [_mapView removeAnnotation:_placemark];

    _delegate = nil;
}

#pragma mark - IBAction methods

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController methods

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animate
{
    self.titleItem.title = NSLocalizedString(@"MAP_TITLE", @"Title of the map view");
    
    CLLocationCoordinate2D coordinate = self.note.location.coordinate;
    self.mapView.delegate = self.delegate;
    self.mapView.centerCoordinate = coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000.0, 10000.0);
    
    self.mapView.region = region;
    
    [self.mapView removeAnnotation:self.placemark];
    self.placemark = nil;

    self.placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate 
                                            addressDictionary:nil];
    [self.mapView addAnnotation:self.placemark];
}

@end
