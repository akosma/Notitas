//
//  MapControllerPad.m
//  Notitas
//
//  Created by Adrian on 9/18/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "MapControllerPad.h"
#import "MNOModels.h"
#import "MNOHelpers.h"

@interface MapControllerPad ()

@property (nonatomic, retain) NSArray *notes;

@end


@implementation MapControllerPad

@synthesize mapView = _mapView;
@synthesize parent = _parent;
@synthesize notes = _notes;
@synthesize segmentedControl = _segmentedControl;

- (void)dealloc
{
    _parent = nil;
    [_notes release];
    [_segmentedControl release];
    [_mapView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.notes count] > 0)
    {
        [self.mapView removeAnnotations:self.notes];
    }
    
    self.notes = [[MNOCoreDataManager sharedMNOCoreDataManager] allNotes];

    for (Note *note in self.notes)
    {
        [self.mapView addAnnotation:note];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(note.coordinate, 100000.0, 100000.0);
        self.mapView.region = region;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - IBAction methods

- (IBAction)done:(id)sender
{
    [UIView transitionFromView:self.view 
                        toView:self.parent.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:nil];
}

- (IBAction)changeMapType:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex) 
    {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
            
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
            
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }

    static NSString *identifier = @"Annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil)
    {
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation 
                                                       reuseIdentifier:identifier] autorelease];
        annotationView.canShowCallout = YES;
    }
    
    Note *note = (Note *)annotation;
    ColorCode code = note.colorCode;
    NSString *imageName = [NSString stringWithFormat:@"small_thumbnail%d.png", code];
    annotationView.image = [UIImage imageNamed:imageName];
    annotationView.transform = CGAffineTransformMakeRotation(note.angleRadians);
    return annotationView;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
