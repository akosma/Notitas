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
#import "MapControllerPad.h"

@interface RootViewControllerPad ()

@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) NSMutableArray *noteViews;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationInformationAvailable;
@property (nonatomic, assign) NoteThumbnail *currentThumbnail;
@property (nonatomic, retain) UIAlertView *deleteAllNotesAlertView;
@property (nonatomic, retain) UIAlertView *deleteNoteAlertView;

- (void)refresh;
- (Note *)createNote;
- (void)checkTrashIconEnabled;
- (void)scrollNoteIntoView:(Note *)note;

@end



@implementation RootViewControllerPad

@synthesize notes = _notes;
@synthesize noteViews = _noteViews;
@synthesize trashButton = _trashButton;
@synthesize locationButton = _locationButton;
@synthesize locationManager = _locationManager;
@synthesize locationInformationAvailable = _locationInformationAvailable;
@synthesize holderView = _holderView;
@synthesize scrollView = _scrollView;
@synthesize currentThumbnail = _currentThumbnail;
@synthesize deleteAllNotesAlertView = _deleteAllNotesAlertView;
@synthesize deleteNoteAlertView = _deleteNoteAlertView;
@synthesize locationView = _locationView;
@synthesize mapView = _mapView;
@synthesize flipView = _flipView;
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize modalBlockerView = _modalBlockerView;

- (void)dealloc
{
    [_modalBlockerView release];
    [_undoButton release];
    [_redoButton release];
    [_flipView release];
    [_locationView release];
    [_mapView release];
    _currentThumbnail = nil;
    [_deleteAllNotesAlertView release];
    [_deleteNoteAlertView release];
    [_scrollView release];
    [_holderView release];
    [_locationManager release];
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
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];

    self.scrollView.contentSize = CGSizeMake(1024.0, 1004.0);

    self.locationInformationAvailable = NO;
    self.modalBlockerView.alpha = 0.0;
    
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                           action:@selector(hideLocationView:)] autorelease];
    [self.modalBlockerView addGestureRecognizer:tap];
    
    [self refresh];
    [self checkTrashIconEnabled];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UIResponderStandardEditActions methods

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)delete:(id)sender
{
    if (self.deleteNoteAlertView == nil)
    {
        NSString *title = NSLocalizedString(@"Are you sure?", @"Title of the 'trash' dialog of the editor controller");
        NSString *message = NSLocalizedString(@"This action cannot be undone.", @"Explanation of the 'trash' dialog of the editor controller");
        NSString *cancelText = NSLocalizedString(@"Cancel", @"The 'cancel' word");
        self.deleteNoteAlertView = [[[UIAlertView alloc] initWithTitle:title
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:cancelText
                                                     otherButtonTitles:@"OK", nil] autorelease];
    }
    [self.deleteNoteAlertView show];
}

- (void)showMap:(id)sender
{
    [self.currentThumbnail mno_removeShadow];
    self.currentThumbnail.originalTransform = self.currentThumbnail.transform;
    self.currentThumbnail.originalFrame = self.currentThumbnail.frame;
    [self.view addSubview:self.currentThumbnail];
    CGRect rect = [self.view convertRect:self.currentThumbnail.frame
                                fromView:self.holderView];
    self.currentThumbnail.frame = rect;

    [UIView animateWithDuration:0.3 
                     animations:^{
                         self.currentThumbnail.transform = CGAffineTransformIdentity;
                         self.currentThumbnail.frame = self.locationView.frame;
                     } 
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.locationView.hidden = NO;
                             [self.locationView addSubview:self.currentThumbnail];
                             self.currentThumbnail.frame = self.locationView.bounds;
                             [self performSelector:@selector(transition) 
                                        withObject:nil
                                        afterDelay:0.1];
                         }
                     }];
}

- (void)transition
{
    [UIView transitionWithView:self.locationView
                      duration:0.3
                       options:UIViewAnimationOptionAllowAnimatedContent + 
                               UIViewAnimationOptionTransitionFlipFromLeft + 
                               UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.modalBlockerView.alpha = 1.0;
                        [self.locationView addSubview:self.flipView];
                        [self.currentThumbnail removeFromSuperview];
                    }
                    completion:^(BOOL finished) {
                        if (finished)
                        {
                            CLLocationCoordinate2D coordinate = self.currentThumbnail.note.location.coordinate;
                            self.mapView.centerCoordinate = coordinate;
                            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000.0, 10000.0);
                            self.mapView.region = region;
                            [self.locationView mno_addShadow];
                        }
                    }];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 0:
            // Cancel
            break;
            
        case 1:
        {
            // OK
            if (alertView == self.deleteNoteAlertView)
            {
                [[MNOCoreDataManager sharedMNOCoreDataManager] deleteObject:self.currentThumbnail.note];
                [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
                
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     self.currentThumbnail.alpha = 0.0;
                                 } 
                                 completion:^(BOOL finished){
                                     [self.currentThumbnail removeFromSuperview];
                                 }];
                
                self.currentThumbnail = nil;
                [[MNOSoundManager sharedMNOSoundManager] playEraseSound];
                [self refresh];
                [self checkTrashIconEnabled];
            }
            else if (alertView == self.deleteAllNotesAlertView)
            {
                [[MNOCoreDataManager sharedMNOCoreDataManager] deleteAllObjectsOfType:@"Note"];
                [[MNOSoundManager sharedMNOSoundManager] playEraseSound];
                [self refresh];
                self.trashButton.enabled = NO;
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Gesture recognizer handlers

- (void)drag:(UIPanGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.holderView bringSubviewToFront:thumb];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [recognizer locationInView:self.holderView];
        thumb.center = point;
        thumb.note.position = point;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.holderView bringSubviewToFront:thumb];
        thumb.originalTransform = thumb.transform;
    }    
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (thumb.note.scale > 0.5 && thumb.note.scale < 2.0)
        {
            CGFloat scale = recognizer.scale;
            thumb.transform = CGAffineTransformScale(thumb.originalTransform, scale, scale);
            thumb.note.scale = recognizer.scale;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    }
}

- (void)rotate:(UIRotationGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.holderView bringSubviewToFront:thumb];
        thumb.originalTransform = thumb.transform;
    }    
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat angle = recognizer.rotation;
        thumb.transform = CGAffineTransformRotate(thumb.originalTransform, angle);
        thumb.note.angleRadians = angle;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    }
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;
    
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self becomeFirstResponder];
        [self.holderView bringSubviewToFront:thumb];
        
        NSString *locationText = NSLocalizedString(@"View location", @"Button to view the note location");
        BOOL locationAvailable = [thumb.note.hasLocation boolValue];
        if (locationAvailable)
        {
            UIMenuItem *locationItem = [[[UIMenuItem alloc] initWithTitle:locationText action:@selector(showMap:)] autorelease];
            NSArray *items = [NSArray arrayWithObjects:locationItem, nil];
            [UIMenuController sharedMenuController].menuItems = items;
        }
        
        [[UIMenuController sharedMenuController] setTargetRect:CGRectInset(thumb.frame, 50.0, 50.0)
                                                        inView:self.holderView];
        [[UIMenuController sharedMenuController] setMenuVisible:YES 
                                                       animated:YES];
    }    
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    int latitude = (int)newLocation.coordinate.latitude;
    int longitude = (int)newLocation.coordinate.longitude;
    if (latitude != 0 && longitude != 0)
    {
        self.locationInformationAvailable = YES;
        self.locationButton.enabled = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    self.locationInformationAvailable = NO;
}

#pragma mark - Public methods

- (IBAction)undo:(id)sender
{
    [[[MNOCoreDataManager sharedMNOCoreDataManager] undoManager] undo];
    [self refresh];
}

- (IBAction)redo:(id)sender
{
    [[[MNOCoreDataManager sharedMNOCoreDataManager] undoManager] redo];
    [self refresh];
}

- (IBAction)showMapWithAllNotes:(id)sender
{
    MapControllerPad *map = [[[MapControllerPad alloc] init] autorelease];
    map.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:map animated:YES];
}

- (IBAction)hideLocationView:(id)sender
{
    [self.locationView mno_removeShadow];
    [UIView transitionWithView:self.locationView
                      duration:0.3
                       options:UIViewAnimationOptionAllowAnimatedContent + 
                               UIViewAnimationOptionTransitionFlipFromRight + 
                               UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.modalBlockerView.alpha = 0.0;
                        [self.locationView addSubview:self.currentThumbnail];
                        [self.flipView removeFromSuperview];
                    }
                    completion:^(BOOL finished) {
                        if (finished)
                        {
                            self.locationView.hidden = YES;
                            [self.holderView addSubview:self.currentThumbnail];
                            CGRect rect = [self.holderView convertRect:self.locationView.frame
                                                              fromView:self.view];
                            self.currentThumbnail.frame = rect;
                            [UIView animateWithDuration:0.3 
                                             animations:^{
                                                 self.currentThumbnail.frame = self.currentThumbnail.originalFrame;
                                                 self.currentThumbnail.transform = self.currentThumbnail.originalTransform;
                                             } 
                                             completion:^(BOOL finished) {
                                                 if (finished)
                                                 {
                                                     [self.currentThumbnail mno_addShadow];
                                                 }
                                             }];
                        }
                    }];
}

- (void)createNewNoteWithContents:(NSString *)contents
{
	Note *newNote = [self createNote];
    newNote.contents = contents;
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self refresh];
    [self scrollNoteIntoView:newNote];
}

- (IBAction)shakeNotes:(id)sender
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] shakeNotes];
    [self refresh];
}

- (IBAction)newNoteWithLocation:(id)sender
{
    if (self.locationInformationAvailable)
    {
        Note *newNote = [self createNote];
        CLLocationDegrees latitude = _locationManager.location.coordinate.latitude;
        CLLocationDegrees longitude = _locationManager.location.coordinate.longitude;
        NSString *template = NSLocalizedString(@"Current location:\n\nLatitude: %1.3f\nLongitude: %1.3f", @"Message created by the 'location' button");
        newNote.contents = [NSString stringWithFormat:template, latitude, longitude];
        
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [self refresh];
        self.trashButton.enabled = YES;
        [self scrollNoteIntoView:newNote];
    }
}

- (IBAction)removeAllNotes:(id)sender
{
    if (self.deleteAllNotesAlertView == nil)
    {
        NSString *title = NSLocalizedString(@"Remove all the notes?", @"Title of the 'remove all notes' dialog");
        NSString *message = NSLocalizedString(@"You will remove all the notes!\nThis action cannot be undone.", @"Warning message of the 'remove all notes' dialog");
        NSString *cancelText = NSLocalizedString(@"Cancel", @"The 'cancel' word");
        self.deleteAllNotesAlertView = [[[UIAlertView alloc] initWithTitle:title
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:cancelText
                                                         otherButtonTitles:@"OK", nil] autorelease];
    }
    [self.deleteAllNotesAlertView show];
}

- (IBAction)about:(id)sender
{
	Note *newNote = [self createNote];
    
    NSString *copyright = NSLocalizedString(@"Notitas by akosma\nhttp://akosma.com\nCopyright 2009-2011 © akosma software\nAll Rights Reserved", @"Copyright text");
    newNote.contents = copyright;
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self refresh];
    self.trashButton.enabled = YES;

    [self scrollNoteIntoView:newNote];
}

- (IBAction)insertNewObject:(id)sender
{
	Note *newNote = [self createNote];
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self refresh];
    self.trashButton.enabled = YES;
    [self scrollNoteIntoView:newNote];
}

#pragma mark - Private methods

- (void)refresh
{
    self.notes = [[MNOCoreDataManager sharedMNOCoreDataManager] allNotes];
    [self.noteViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.noteViews = [NSMutableArray array];
    for (Note *note in self.notes)
    {
        NoteThumbnail *thumb = [[[NoteThumbnail alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)] autorelease];
        CGAffineTransform trans = CGAffineTransformMakeRotation(note.angleRadians);
        CGFloat size = [note.size floatValue];
        trans = CGAffineTransformScale(trans, size, size);
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
        UIPinchGestureRecognizer *pinch = [[[UIPinchGestureRecognizer alloc] initWithTarget:self 
                                                                                     action:@selector(pinch:)] autorelease];
        UIRotationGestureRecognizer *rotation = [[[UIRotationGestureRecognizer alloc] initWithTarget:self 
                                                                                              action:@selector(rotate:)] autorelease];
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                               action:@selector(tap:)] autorelease];
        [thumb addGestureRecognizer:pan];
        [thumb addGestureRecognizer:pinch];
        [thumb addGestureRecognizer:rotation];
        [thumb addGestureRecognizer:tap];
        
        [self.noteViews addObject:thumb];
        [self.holderView addSubview:thumb];
        [thumb mno_addShadow];
    }
}

- (Note *)createNote
{
	Note *newNote = [[MNOCoreDataManager sharedMNOCoreDataManager] createNote];
    
    newNote.hasLocation = [NSNumber numberWithBool:self.locationInformationAvailable];
    if (self.locationInformationAvailable)
    {
        newNote.latitude = [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude];
        newNote.longitude = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
    }
    return newNote;
}

- (void)checkTrashIconEnabled
{
    self.trashButton.enabled = ([self.notes count] > 0);
}

- (void)scrollNoteIntoView:(Note *)note
{
    CGPoint point = note.position;
    CGRect rect = CGRectMake(point.x - 100.0, point.y - 100.0, 200.0, 200.0);
    [self.scrollView scrollRectToVisible:rect animated:YES];
    self.trashButton.enabled = YES;
}

@end
