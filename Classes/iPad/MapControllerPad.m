//
//  MapControllerPad.m
//  Notitas
//
//  Created by Adrian on 9/18/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "MapControllerPad.h"

@implementation MapControllerPad

@synthesize mapView = _mapView;

- (void)dealloc
{
    [_mapView release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - IBAction methods

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
