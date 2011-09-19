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

#define DEFAULT_WIDTH 200.0
static CGRect DEFAULT_RECT = {{0.0, 0.0}, {DEFAULT_WIDTH, DEFAULT_WIDTH}};

@interface RootViewControllerPad ()

@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) NSMutableArray *noteViews;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationInformationAvailable;
@property (nonatomic, retain) NoteThumbnail *currentThumbnail;
@property (nonatomic, retain) UIAlertView *deleteAllNotesAlertView;
@property (nonatomic, retain) UIAlertView *deleteNoteAlertView;
@property (nonatomic, getter = isShowingLocationView) BOOL showingLocationView;
@property (nonatomic, getter = isShowingEditionView) BOOL showingEditionView;
@property (nonatomic, retain) MapControllerPad *map;
@property (nonatomic, retain) NoteThumbnail *animationThumbnail;

- (void)refresh;
- (Note *)createNote;
- (void)scrollNoteIntoView:(Note *)note;
- (void)checkToolbarButtonsEnabled;
- (void)deleteCurrentNote;
- (void)editCurrentNote;
- (void)animateThumbnailAndPerformSelector:(SEL)selector;
- (void)returnCurrentThumbnailToOriginalPosition;

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
@synthesize auxiliaryView = _auxiliaryView;
@synthesize mapView = _mapView;
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize modalBlockerView = _modalBlockerView;
@synthesize showingLocationView = _showingLocationView;
@synthesize showingEditionView = _showingEditionView;
@synthesize editorView = _editorView;
@synthesize textView = _textView;
@synthesize map = _map;
@synthesize animationThumbnail = _animationThumbnail;
@synthesize editingToolbar = _editingToolbar;

- (void)dealloc
{
    [_editingToolbar release];
    [_map release];
    [_textView release];
    [_editorView release];
    [_modalBlockerView release];
    [_undoButton release];
    [_redoButton release];
    [_auxiliaryView release];
    [_mapView release];
    [_currentThumbnail release];
    [_deleteAllNotesAlertView release];
    [_deleteNoteAlertView release];
    [_scrollView release];
    [_holderView release];
    [_locationManager release];
    [_trashButton release];
    [_locationButton release];
    [_notes release];
    [_noteViews release];
    [_animationThumbnail release];
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
    self.showingLocationView = NO;
    self.showingEditionView = NO;
    self.modalBlockerView.alpha = 0.0;
    self.animationThumbnail = [[[NoteThumbnail alloc] initWithFrame:CGRectZero] autorelease];

    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                           action:@selector(dismissBlockerView:)] autorelease];
    [self.modalBlockerView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(undoManagerDidUndo:) 
                                                 name:NSUndoManagerDidUndoChangeNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(undoManagerDidRedo:) 
                                                 name:NSUndoManagerDidRedoChangeNotification 
                                               object:nil];

    [self refresh];
    [self checkToolbarButtonsEnabled];
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

- (void)copy:(id)sender
{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.currentThumbnail.note.contents;
    self.currentThumbnail = nil;
}

- (void)cut:(id)sender
{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.currentThumbnail.note.contents;
    [self deleteCurrentNote];
}

- (void)showMap:(id)sender
{
    [self animateThumbnailAndPerformSelector:@selector(transitionToMap)];
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
                [self deleteCurrentNote];
            }
            else if (alertView == self.deleteAllNotesAlertView)
            {
                [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
                [[MNOCoreDataManager sharedMNOCoreDataManager] deleteAllObjectsOfType:@"Note"];
                [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
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
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
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
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        [self checkToolbarButtonsEnabled];
    }
}

- (void)rotate:(UIRotationGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        [self.holderView bringSubviewToFront:thumb];
        thumb.originalTransform = thumb.transform;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat angle = recognizer.rotation;
        thumb.transform = CGAffineTransformRotate(thumb.originalTransform, angle);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGFloat angle = recognizer.rotation;
        thumb.note.angleRadians += angle;
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        [self checkToolbarButtonsEnabled];
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
            UIMenuItem *locationItem = [[[UIMenuItem alloc] initWithTitle:locationText 
                                                                   action:@selector(showMap:)] autorelease];
            NSArray *items = [NSArray arrayWithObjects:locationItem, nil];
            [UIMenuController sharedMenuController].menuItems = items;
        }
        
        [[UIMenuController sharedMenuController] setTargetRect:CGRectInset(thumb.frame, 50.0, 50.0)
                                                        inView:self.holderView];
        [[UIMenuController sharedMenuController] setMenuVisible:YES 
                                                       animated:YES];
    }    
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
    NoteThumbnail *thumb = (NoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self becomeFirstResponder];
        [self.holderView bringSubviewToFront:thumb];
        
        [self editCurrentNote];
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

#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.textView resignFirstResponder];
    [self becomeFirstResponder];
    [self dismissBlockerView:nil];
    return YES;
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)composer 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error
{
    [composer dismissModalViewControllerAnimated:YES];
}

#pragma mark - Public methods

- (IBAction)undo:(id)sender
{
    [[[MNOCoreDataManager sharedMNOCoreDataManager] undoManager] undo];
    [self checkToolbarButtonsEnabled];
}

- (IBAction)redo:(id)sender
{
    [[[MNOCoreDataManager sharedMNOCoreDataManager] undoManager] redo];
    [self checkToolbarButtonsEnabled];
}

- (IBAction)showMapWithAllNotes:(id)sender
{
    if (self.map == nil)
    {
        self.map = [[[MapControllerPad alloc] init] autorelease];
    }
    self.map.parent = self;
    [UIView transitionFromView:self.view 
                        toView:self.map.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:nil];
}

- (void)createNewNoteWithContents:(NSString *)contents
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
	Note *newNote = [self createNote];
    newNote.contents = contents;
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];

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
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        Note *newNote = [self createNote];
        CLLocationDegrees latitude = _locationManager.location.coordinate.latitude;
        CLLocationDegrees longitude = _locationManager.location.coordinate.longitude;
        NSString *template = NSLocalizedString(@"Current location:\n\nLatitude: %1.3f\nLongitude: %1.3f", @"Message created by the 'location' button");
        newNote.contents = [NSString stringWithFormat:template, latitude, longitude];
        
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
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
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
	Note *newNote = [self createNote];
    
    NSString *copyright = NSLocalizedString(@"Notitas by akosma\nhttp://akosma.com\nCopyright 2009-2011 © akosma software\nAll Rights Reserved", @"Copyright text");
    newNote.contents = copyright;
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
    [self refresh];
    self.trashButton.enabled = YES;

    [self scrollNoteIntoView:newNote];
}

- (IBAction)insertNewObject:(id)sender
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
	Note *newNote = [self createNote];
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self refresh];
    self.trashButton.enabled = YES;
    [self scrollNoteIntoView:newNote];
    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
}

#pragma mark - Undo support

- (void)undoManagerDidUndo:(NSNotification *)notification 
{
	[self refresh];
    [self checkToolbarButtonsEnabled];
}

- (void)undoManagerDidRedo:(NSNotification *)notification 
{
	[self refresh];
    [self checkToolbarButtonsEnabled];
}

#pragma mark - Private methods

- (void)refresh
{
    self.notes = [[MNOCoreDataManager sharedMNOCoreDataManager] allNotes];
    [self.noteViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.noteViews = [NSMutableArray array];
    for (Note *note in self.notes)
    {
        NoteThumbnail *thumb = [[[NoteThumbnail alloc] initWithFrame:DEFAULT_RECT] autorelease];
        thumb.note = note;
        [thumb refreshDisplay];
        
        [[NSNotificationCenter defaultCenter] removeObserver:thumb];
        
        UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(drag:)] autorelease];
        UIRotationGestureRecognizer *rotation = [[[UIRotationGestureRecognizer alloc] initWithTarget:self 
                                                                                              action:@selector(rotate:)] autorelease];
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                               action:@selector(tap:)] autorelease];
        UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                     action:@selector(doubleTap:)] autorelease];
        doubleTap.numberOfTapsRequired = 2;
        
        [thumb addGestureRecognizer:pan];
        [thumb addGestureRecognizer:rotation];
        [thumb addGestureRecognizer:tap];
        [thumb addGestureRecognizer:doubleTap];
        
        [self.noteViews addObject:thumb];
        [self.holderView addSubview:thumb];
        [thumb mno_addShadow];
    }
    [self checkToolbarButtonsEnabled];
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

- (void)checkToolbarButtonsEnabled
{
    self.trashButton.enabled = ([self.notes count] > 0);
    self.undoButton.enabled = [[[MNOCoreDataManager sharedMNOCoreDataManager] undoManager] canUndo];
    self.redoButton.enabled = [[[MNOCoreDataManager sharedMNOCoreDataManager] undoManager] canRedo];
}

- (void)scrollNoteIntoView:(Note *)note
{
    CGPoint point = note.position;
    CGRect rect = CGRectMake(point.x - 100.0, point.y - 100.0, 200.0, 200.0);
    [self.scrollView scrollRectToVisible:rect animated:YES];
    self.trashButton.enabled = YES;
}

- (void)deleteCurrentNote
{
    if (self.currentThumbnail != nil)
    {
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        [[MNOCoreDataManager sharedMNOCoreDataManager] deleteObject:self.currentThumbnail.note];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];

        [UIView animateWithDuration:0.5
                      animations:^{
                          self.currentThumbnail.alpha = 0.0;
                      } 
                      completion:^(BOOL finished){
                          [self.currentThumbnail removeFromSuperview];
                          self.currentThumbnail = nil;
                          [[MNOSoundManager sharedMNOSoundManager] playEraseSound];
                          [self refresh];
                          [self checkToolbarButtonsEnabled];
                      }];
    }
}

- (void)editCurrentNote
{
    [self animateThumbnailAndPerformSelector:@selector(transitionToEdition)];
}

#pragma mark - Methods to animate the notes for maps and edition

- (void)animateThumbnailAndPerformSelector:(SEL)selector
{
    CGRect frame = [self.view convertRect:self.currentThumbnail.frame 
                                 fromView:self.holderView];
    self.animationThumbnail.frame = frame;
    [self.view addSubview:self.animationThumbnail];
    self.currentThumbnail.hidden = YES;                                   
    CGAffineTransform trans = CGAffineTransformMakeRotation(self.currentThumbnail.note.angleRadians);
    self.animationThumbnail.transform = trans;
    self.animationThumbnail.color = self.currentThumbnail.color;
    
    [UIView animateWithDuration:0.3 
                     animations:^{
                         self.animationThumbnail.transform = CGAffineTransformIdentity;
                         self.animationThumbnail.frame = self.auxiliaryView.frame;
                         self.modalBlockerView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.auxiliaryView.hidden = NO;
                             [self.auxiliaryView addSubview:self.animationThumbnail];
                             self.animationThumbnail.frame = self.auxiliaryView.bounds;
                             [self performSelector:selector
                                        withObject:nil
                                        afterDelay:0.1];
                         }
                     }];
}

- (void)transitionToMap
{
    [self.auxiliaryView insertSubview:self.mapView 
                         belowSubview:self.animationThumbnail];
    CLLocationCoordinate2D coordinate = self.currentThumbnail.note.location.coordinate;
    self.mapView.centerCoordinate = coordinate;
    if (self.map == nil)
    {
        self.map = [[[MapControllerPad alloc] init] autorelease];
    }
    self.mapView.delegate = self.map;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 10000.0, 10000.0);
    self.mapView.region = region;
    [self.mapView addAnnotation:self.currentThumbnail.note];

    [UIView transitionFromView:self.animationThumbnail
                        toView:self.mapView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews
                    completion:^(BOOL finished) {
                        if (finished)
                        {
                            [self.auxiliaryView bringSubviewToFront:self.mapView];
                            [self.auxiliaryView mno_addShadow];
                            self.showingLocationView = YES;
                        }
                    }];
}

- (void)transitionToEdition
{
    [self.auxiliaryView addSubview:self.editorView];
    self.editorView.alpha = 0.0;
    self.textView.inputAccessoryView = self.editingToolbar;
    self.textView.text = self.currentThumbnail.note.contents;
    self.textView.font = [UIFont fontWithName:fontNameForCode(self.currentThumbnail.note.fontCode) size:30.0];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.modalBlockerView.alpha = 1.0;
                         self.editorView.alpha = 1.0;
                         self.textView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         [self.textView becomeFirstResponder];
                         self.showingEditionView = YES;
                         [self.auxiliaryView mno_addShadow];
                     }];
}

- (void)dismissBlockerView:(UITapGestureRecognizer *)recognizer
{
    [self.auxiliaryView mno_removeShadow];
    if (self.isShowingLocationView)
    {
        [self.mapView removeAnnotation:self.currentThumbnail.note];
        [UIView transitionFromView:self.mapView
                            toView:self.animationThumbnail
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionShowHideTransitionViews
                        completion:^(BOOL finished) {
                            if (finished)
                            {
                                [self.auxiliaryView bringSubviewToFront:self.animationThumbnail];
                                [self returnCurrentThumbnailToOriginalPosition];
                            }
                        }];
    }
    else if (self.isShowingEditionView)
    {
        if (![self.textView.text isEqualToString:self.currentThumbnail.note.contents])
        {
            [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
            self.currentThumbnail.note.contents = self.textView.text;
            self.currentThumbnail.summaryLabel.text = self.textView.text;
            [[MNOCoreDataManager sharedMNOCoreDataManager] save];
            [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        }
        [self checkToolbarButtonsEnabled];
        [self.editorView removeFromSuperview];
        [self returnCurrentThumbnailToOriginalPosition];
    }
}

- (void)returnCurrentThumbnailToOriginalPosition
{
    self.auxiliaryView.hidden = YES;
    [self.view addSubview:self.animationThumbnail];
    self.animationThumbnail.center = self.auxiliaryView.center;

    [UIView animateWithDuration:0.3 
                     animations:^{
                         self.modalBlockerView.alpha = 0.0;
                         self.animationThumbnail.frame = [self.view convertRect:self.currentThumbnail.frame fromView:self.holderView];
                         CGAffineTransform trans = CGAffineTransformMakeRotation(self.currentThumbnail.note.angleRadians);
                         self.animationThumbnail.transform = trans;
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.currentThumbnail.hidden = NO;
                             [self.animationThumbnail removeFromSuperview];
                             self.showingLocationView = NO;
                             self.showingEditionView = NO;
                             [self becomeFirstResponder];
                         }
                     }];
}

#pragma mark - Toolbar edition actions

- (IBAction)changeColor:(id)sender
{
    int value = self.currentThumbnail.note.colorCode + 1;
    value = value % 4;
    self.currentThumbnail.note.color = [NSNumber numberWithInt:value];
    self.animationThumbnail.color = value;
    self.currentThumbnail.color = value;
}

- (IBAction)changeFont:(id)sender
{
    int value = self.currentThumbnail.note.fontCode + 1;
    value = value % 4;
    self.currentThumbnail.note.fontFamily = [NSNumber numberWithInt:value];
    self.currentThumbnail.font = value;
    self.textView.font = [UIFont fontWithName:fontNameForCode(value) size:24.0];
//    _timeStampLabel.font = [UIFont fontWithName:fontNameForCode(value) size:12.0];
}

- (IBAction)sendViaEmail:(id)sender
{
    MFMailComposeViewController *composer = [[[MFMailComposeViewController alloc] init] autorelease];
    composer.modalPresentationStyle = UIModalPresentationFormSheet;
    composer.mailComposeDelegate = self;
    
    NSMutableString *message = [NSMutableString string];
    if (self.currentThumbnail.note.contents == nil || [self.currentThumbnail.note.contents length] == 0)
    {
        NSString *emptyNoteText = NSLocalizedString(@"(empty note)", @"To be used when en empty note is sent via e-mail");
        [message appendString:emptyNoteText];
    }
    else
    {
        [message appendString:self.currentThumbnail.note.contents];
    }
    NSString *sentFromText = NSLocalizedString(@"\n\nSent from Notitas by akosma - http://akosma.com/", @"Some marketing here");
    [message appendString:sentFromText];
    NSString *subject = NSLocalizedString(@"Note sent from Notitas by akosma", @"Title of the e-mail sent by the application");
    [composer setSubject:subject];
    [composer setMessageBody:message isHTML:NO];
    [self presentModalViewController:composer animated:YES];
}

- (IBAction)sendToTwitter:(id)sender
{
}

@end
