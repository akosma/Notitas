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

@property (nonatomic, retain) MKPlacemark *placemark;

@end


@implementation MNOMapController

@synthesize note = _note;
@synthesize delegate = _delegate;
@synthesize placemark = _placemark;
@synthesize mapView = _mapView;
@synthesize titleItem = _titleItem;

- (void)dealloc 
{
    [_mapView removeAnnotation:_placemark];
    [_mapView release];
    [_placemark release];
    [_titleItem release];

    _delegate = nil;
    [_note release];
    [super dealloc];
}

#pragma mark - IBAction methods

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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

    self.placemark = [[[MKPlacemark alloc] initWithCoordinate:coordinate 
                                            addressDictionary:nil] autorelease];
    [self.mapView addAnnotation:self.placemark];
}

@end
