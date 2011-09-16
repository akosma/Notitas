//
//  RootViewControllerPad.m
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "RootViewControllerPad.h"
#import "MNOHelpers.h"
#import "Note.h"
#import "NoteThumbnail.h"

@interface RootViewControllerPad ()

@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) NSMutableArray *noteViews;

- (void)refresh;

@end



@implementation RootViewControllerPad

@synthesize notes = _notes;
@synthesize noteViews = _noteViews;
@synthesize trashButton = _trashButton;
@synthesize locationButton = _locationButton;

- (void)dealloc
{
    [_trashButton release];
    [_locationButton release];
    [_notes release];
    [_noteViews release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noteViews = [NSMutableArray array];
    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Gesture recognizer handlers

- (void)drag:(UIPanGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.view bringSubviewToFront:thumb];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:self.view];
        thumb.center = point;
        thumb.note.position = point;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    }
}

#pragma mark - Private methods

- (void)refresh
{
    self.notes = [[MNOCoreDataManager sharedMNOCoreDataManager] allNotes];
    self.noteViews = nil;
    for (Note *note in self.notes)
    {
        NoteThumbnail *thumb = [[[NoteThumbnail alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 150.0)] autorelease];
        CGAffineTransform trans = CGAffineTransformMakeRotation(note.angleRadians);
        thumb.transform = trans;
        thumb.color = note.colorCode;
        thumb.font = note.fontCode;
        
        // This must come last, so that the size calculation
        // of the label inside the thumbnail is done!
        thumb.text = note.contents;
        thumb.center = note.position;
        thumb.note = note;
        
        UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(drag:)] autorelease];
        [thumb addGestureRecognizer:pan];
        
        [self.noteViews addObject:thumb];
        [self.view addSubview:thumb];
    }
}

@end
