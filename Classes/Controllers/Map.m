//
//  Map.m
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "Map.h"
#import "Note.h"

@implementation Map

@synthesize note = _note;
@synthesize delegate = _delegate;

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
    _delegate = nil;
    [_note release];
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

- (void)viewDidLoad
{
    CLLocationCoordinate2D coordinate = _note.location.coordinate;
    _mapView.delegate = _delegate;
    _mapView.centerCoordinate = coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000.0, 10000.0);
    
    _mapView.region = region;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate 
                                                   addressDictionary:nil];
    [_mapView addAnnotation:placemark];
    [placemark release];
}

@end
