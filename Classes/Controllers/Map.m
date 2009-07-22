//
//  Map.m
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "Map.h"

@implementation Map

@synthesize location = _location;

#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if (self = [super initWithNibName:@"Map" bundle:nil]) 
    {
    }
    return self;
}

- (void)dealloc 
{
    [_location release];
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D coordinate = _location.coordinate;
    _mapView.centerCoordinate = coordinate;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(1.0, 1.0);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    
    _mapView.region = region;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate 
                                                   addressDictionary:nil];
    [_mapView addAnnotation:placemark];
}

@end
