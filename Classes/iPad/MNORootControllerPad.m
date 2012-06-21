//
//  MNORootControllerPad.m
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "MNORootControllerPad.h"
#import "MNOHelpers.h"
#import "MNOModels.h"
#import "MNONoteThumbnail.h"
#import "MNOMapControllerPad.h"

#define DEFAULT_WIDTH 200.0
static CGRect DEFAULT_RECT = {{0.0, 0.0}, {DEFAULT_WIDTH, DEFAULT_WIDTH}};

@interface MNORootControllerPad ()

@property (nonatomic, strong) NSArray *notes;
@property (nonatomic, strong) NSMutableArray *noteViews;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationInformationAvailable;
@property (nonatomic, strong) MNONoteThumbnail *currentThumbnail;
@property (nonatomic, strong) UIAlertView *deleteAllNotesAlertView;
@property (nonatomic, strong) UIAlertView *deleteNoteAlertView;
@property (nonatomic, getter = isShowingLocationView) BOOL showingLocationView;
@property (nonatomic, getter = isShowingEditionView) BOOL showingEditionView;
@property (nonatomic, strong) MNOMapControllerPad *map;
@property (nonatomic, strong) MNONoteThumbnail *animationThumbnail;
@property (nonatomic, strong) UIActionSheet *twitterChoiceSheet;
@property (nonatomic) CGPoint handlePointOffset;
@property (nonatomic, weak) Note *newlyCreatedNote;
@property (nonatomic, weak) MNONoteThumbnail *newlyCreatedNoteThumbnail;

- (void)refresh;
- (Note *)createNote;
- (void)scrollNoteIntoView:(Note *)note;
- (void)checkToolbarButtonsEnabled;
- (void)deleteCurrentNote;
- (void)editCurrentNote;
- (void)animateThumbnailAndPerformSelector:(SEL)selector;
- (void)returnCurrentThumbnailToOriginalPosition;
- (void)positionEditorAndAuxiliaryViews;

@end



@implementation MNORootControllerPad

- (void)dealloc
{
    _newlyCreatedNoteThumbnail = nil;
    _newlyCreatedNote = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];

    self.scrollView.contentSize = CGSizeMake(1024.0, 1004.0);

    self.locationInformationAvailable = NO;
    self.showingLocationView = NO;
    self.showingEditionView = NO;
    self.modalBlockerView.alpha = 0.0;
    self.animationThumbnail = [[MNONoteThumbnail alloc] initWithFrame:CGRectZero];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                           action:@selector(dismissBlockerView:)];
    [self.modalBlockerView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(undoManagerDidUndo:) 
                                                 name:NSUndoManagerDidUndoChangeNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(undoManagerDidRedo:) 
                                                 name:NSUndoManagerDidRedoChangeNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteImported:)
                                                 name:MNOCoreDataManagerNoteImportedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidBecomeActive:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];

    [self refresh];
    [self checkToolbarButtonsEnabled];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [UIView animateWithDuration:0.3
                     animations:^{
                         [self positionEditorAndAuxiliaryViews];
                     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSString *firstRunKey = @"firstRunKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstRun = [defaults boolForKey:firstRunKey];
    if (!firstRun)
    {
        [defaults setBool:YES forKey:firstRunKey];
        [self about:nil];
    }
}

#pragma mark - UIResponderStandardEditActions methods

- (BOOL)canBecomeFirstResponder
{
    return !self.isShowingEditionView;
}

- (void)delete:(id)sender
{
    if (self.deleteNoteAlertView == nil)
    {
        NSString *title = NSLocalizedString(@"ARE_YOU_SURE", @"Title of the 'trash' dialog of the editor controller");
        NSString *message = NSLocalizedString(@"UNDO_POSSIBLE", @"Explanation of the 'trash' dialog of the editor controller");
        NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
        self.deleteNoteAlertView = [[UIAlertView alloc] initWithTitle:title
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:cancelText
                                                     otherButtonTitles:@"OK", nil];
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
    self.showingLocationView = YES;
    [self positionEditorAndAuxiliaryViews];
    [self animateThumbnailAndPerformSelector:@selector(transitionToMap)];
}

- (IBAction)sendViaEmail:(id)sender
{
    NSDictionary *dict = [self.currentThumbnail.note exportAsDictionary];
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dict 
                                                              format:NSPropertyListXMLFormat_v1_0 
                                                             options:0
                                                               error:&error];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.notita", self.currentThumbnail.note.filename];
    
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    [composer addAttachmentData:data mimeType:@"application/octet-stream" fileName:fileName];
    composer.modalPresentationStyle = UIModalPresentationFormSheet;
    composer.mailComposeDelegate = self;
    
    NSMutableString *message = [NSMutableString string];
    if (self.currentThumbnail.note.contents == nil || [self.currentThumbnail.note.contents length] == 0)
    {
        NSString *emptyNoteText = NSLocalizedString(@"EMPTY_NOTE", @"To be used when en empty note is sent via e-mail");
        [message appendString:emptyNoteText];
    }
    else
    {
        [message appendString:self.currentThumbnail.note.contents];
    }
    NSString *sentFromText = NSLocalizedString(@"SENT_BY_NOTITAS", @"Some marketing here");
    [message appendString:sentFromText];
    NSString *subject = NSLocalizedString(@"EMAIL_SUBJECT", @"Title of the e-mail sent by the application");
    [composer setSubject:subject];
    [composer setMessageBody:message isHTML:NO];
    [self presentViewController:composer animated:YES completion:nil];
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
    MNONoteThumbnail *thumb = (MNONoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.scrollView.scrollEnabled = NO;
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        [self.holderView bringSubviewToFront:thumb];
        [thumb mno_removeShadow];
        thumb.note.lastModificationTime = [NSDate date];
        thumb.alpha = 0.75;
        CGPoint gestureCenter = [recognizer locationInView:thumb];
        self.handlePointOffset = CGPointMake(thumb.frame.size.width / 2.0 - gestureCenter.x, 
                                             thumb.frame.size.height / 2.0 - gestureCenter.y);
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint gestureLocation = [recognizer locationInView:self.holderView];
        CGPoint newCenter = CGPointMake(gestureLocation.x + self.handlePointOffset.x, 
                                        gestureLocation.y + self.handlePointOffset.y);
        thumb.center = newCenter;
        thumb.note.position = newCenter;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || 
             recognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.scrollView.scrollEnabled = YES;
        thumb.alpha = 1.0;
        [thumb mno_addShadow];
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        [self checkToolbarButtonsEnabled];
    }
}

- (void)rotate:(UIRotationGestureRecognizer *)recognizer
{
    MNONoteThumbnail *thumb = (MNONoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.scrollView.scrollEnabled = NO;
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        [self.holderView bringSubviewToFront:thumb];
        thumb.note.lastModificationTime = [NSDate date];
        thumb.originalTransform = thumb.transform;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat angle = recognizer.rotation;
        thumb.transform = CGAffineTransformRotate(thumb.originalTransform, angle);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || 
             recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat angle = recognizer.rotation;
        thumb.note.angleRadians += angle;
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        [self checkToolbarButtonsEnabled];
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    MNONoteThumbnail *thumb = (MNONoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;
    
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self becomeFirstResponder];
        [self.holderView bringSubviewToFront:thumb];

        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        thumb.note.lastModificationTime = [NSDate date];
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        
        NSString *locationText = NSLocalizedString(@"VIEW_LOCATION", @"Button to view the note location");
        NSString *emailText = NSLocalizedString(@"SEND_VIA_EMAIL", @"Button to send notes via e-mail");
        NSString *twitterText = NSLocalizedString(@"SEND_VIA_TWITTER", @"Button to send notes via Twitter");
        NSMutableArray *items = [NSMutableArray array];
        BOOL locationAvailable = [thumb.note.hasLocation boolValue];
        if (locationAvailable)
        {
            UIMenuItem *locationItem = [[UIMenuItem alloc] initWithTitle:locationText 
                                                                   action:@selector(showMap:)];
            [items addObject:locationItem];
        }

        if ([MFMailComposeViewController canSendMail])
        {
            UIMenuItem *emailItem = [[UIMenuItem alloc] initWithTitle:emailText 
                                                                action:@selector(sendViaEmail:)];
            [items addObject:emailItem];
        }
        
        MNOTwitterClientManager *clientManager = [MNOTwitterClientManager sharedMNOTwitterClientManager];
        if ([[clientManager availableClients] count] > 0)
        {
            UIMenuItem *twitterItem = [[UIMenuItem alloc] initWithTitle:twitterText
                                                                action:@selector(sendToTwitter:)];
            [items addObject:twitterItem];
        }

        [UIMenuController sharedMenuController].menuItems = items;
        
        [[UIMenuController sharedMenuController] setTargetRect:CGRectInset(thumb.frame, 50.0, 50.0)
                                                        inView:self.holderView];
        [[UIMenuController sharedMenuController] setMenuVisible:YES 
                                                       animated:YES];
    }    
}

- (void)doubleTap:(UITapGestureRecognizer *)recognizer
{
    MNONoteThumbnail *thumb = (MNONoteThumbnail *)recognizer.view;
    self.currentThumbnail = thumb;

    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self becomeFirstResponder];
        [self.holderView bringSubviewToFront:thumb];
        [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
        thumb.note.lastModificationTime = [NSDate date];
        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
        
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
    [composer dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.twitterChoiceSheet)
    {
        MNOTwitterClientManager *clientManager = [MNOTwitterClientManager sharedMNOTwitterClientManager];
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        [clientManager setSelectedClientName:buttonTitle];
        [clientManager send:self.currentThumbnail.note.contents];
        
        self.twitterChoiceSheet = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

-                          (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Public methods

- (IBAction)orderNotes:(id)sender
{
    __block CGPoint currentPoint = CGPointMake(-128.0f, 128.0f);
    CGAffineTransform transform = CGAffineTransformMakeTranslation(256.0f, 0.0f);
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
    [UIView animateWithDuration:0.4 
                     animations:^{
                         for (MNONoteThumbnail *noteView in self.noteViews)
                         {
                             currentPoint = CGPointApplyAffineTransform(currentPoint, transform);
                             if (currentPoint.x > 1024.0f)
                             {
                                 currentPoint = CGPointMake(128.0f, currentPoint.y + 256.0f);
                                 
                                 if (currentPoint.y > 1024.0f)
                                 {
                                     currentPoint = CGPointMake(128.0f, 128.0f);
                                 }
                             }
                             noteView.center = currentPoint;
                             noteView.note.position = currentPoint;
                         }    
                     }];
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
    [self checkToolbarButtonsEnabled];
}

- (IBAction)makeStacks:(id)sender
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
    [UIView animateWithDuration:0.4 
                     animations:^{
                         CGPoint point1 = CGPointMake(128.0f, 128.0f);
                         CGPoint point2 = CGPointMake(128.0f, 384.0f);
                         CGPoint point3 = CGPointMake(384.0f, 128.0f);
                         CGPoint point4 = CGPointMake(384.0f, 384.0f);
                         
                         NSValue *value1 = [NSValue valueWithCGPoint:point1];
                         NSValue *value2 = [NSValue valueWithCGPoint:point2];
                         NSValue *value3 = [NSValue valueWithCGPoint:point3];
                         NSValue *value4 = [NSValue valueWithCGPoint:point4];
                         
                         NSMutableArray *stack = [NSMutableArray arrayWithObjects:value4, value3, value2, value1, nil];

                         CGPoint redPoint = CGPointZero;
                         CGPoint greenPoint = CGPointZero;
                         CGPoint yellowPoint = CGPointZero;
                         CGPoint bluePoint = CGPointZero;
                         for (MNONoteThumbnail *noteView in self.noteViews)
                         {
                             switch (noteView.color) 
                             {
                                 case MNOColorCodeRed:
                                 {
                                     if (CGPointEqualToPoint(redPoint, CGPointZero))
                                     {
                                         NSValue *value = [stack lastObject];
                                         redPoint = [value CGPointValue];
                                         [stack removeLastObject];
                                     }
                                     noteView.center = redPoint;
                                     noteView.note.position = redPoint;
                                     break;
                                 }
                                     
                                 case MNOColorCodeGreen:
                                 {
                                     if (CGPointEqualToPoint(greenPoint, CGPointZero))
                                     {
                                         NSValue *value = [stack lastObject];
                                         greenPoint = [value CGPointValue];
                                         [stack removeLastObject];
                                     }
                                     noteView.center = greenPoint;
                                     noteView.note.position = greenPoint;
                                     break;
                                 }
                                     
                                 case MNOColorCodeYellow:
                                 {
                                     if (CGPointEqualToPoint(yellowPoint, CGPointZero))
                                     {
                                         NSValue *value = [stack lastObject];
                                         yellowPoint = [value CGPointValue];
                                         [stack removeLastObject];
                                     }
                                     noteView.center = yellowPoint;
                                     noteView.note.position = yellowPoint;
                                     break;
                                 }
                                     
                                 case MNOColorCodeBlue:
                                 {
                                     if (CGPointEqualToPoint(bluePoint, CGPointZero))
                                     {
                                         NSValue *value = [stack lastObject];
                                         bluePoint = [value CGPointValue];
                                         [stack removeLastObject];
                                     }
                                     noteView.center = bluePoint;
                                     noteView.note.position = bluePoint;
                                     break;
                                 }
                                     
                                 default:
                                     break;
                             }
                         }    
                     }];
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
    [self checkToolbarButtonsEnabled];
    [self.scrollView scrollRectToVisible:CGRectMake(0.0f, 0.0f, 128.0f, 128.0f) 
                                animated:YES];
}

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
        self.map = [[MNOMapControllerPad alloc] init];
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
        NSString *template = NSLocalizedString(@"CURRENT_LOCATION", @"Message created by the 'location' button");
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
        NSString *title = NSLocalizedString(@"REMOVE_ALL_NOTES_QUESTION", @"Title of the 'remove all notes' dialog");
        NSString *message = NSLocalizedString(@"ALL_NOTES_UNDO_POSSIBLE", @"Warning message of the 'remove all notes' dialog");
        NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
        self.deleteAllNotesAlertView = [[UIAlertView alloc] initWithTitle:title
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:cancelText
                                                         otherButtonTitles:@"OK", nil];
    }
    [self.deleteAllNotesAlertView show];
}

- (IBAction)about:(id)sender
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];
	Note *newNote = [self createNote];
    
    NSString *copyright = NSLocalizedString(@"COPYRIGHT_TEXT", @"Copyright text");
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

- (void)noteImported:(NSNotification *)notification 
{
	[self refresh];
    [self checkToolbarButtonsEnabled];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
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
        MNONoteThumbnail *thumb = [[MNONoteThumbnail alloc] initWithFrame:DEFAULT_RECT];
        thumb.note = note;
        [thumb refreshDisplay];
        
        [[NSNotificationCenter defaultCenter] removeObserver:thumb];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(drag:)];
        pan.delegate = self;
        
        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self 
                                                                                              action:@selector(rotate:)];
        rotation.delegate = self;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                               action:@selector(tap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                     action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        
        [thumb addGestureRecognizer:pan];
        [thumb addGestureRecognizer:rotation];
        [thumb addGestureRecognizer:tap];
        [thumb addGestureRecognizer:doubleTap];
        
        [self.noteViews addObject:thumb];
        [self.holderView addSubview:thumb];
        
        if (note == self.newlyCreatedNote)
        {
            self.newlyCreatedNoteThumbnail = thumb;
            thumb.center = CGPointMake(-128.0f, -128.0f);
        }
        else
        {
            [thumb mno_addShadow];
        }
    }
    [self checkToolbarButtonsEnabled];
    
    [UIView animateWithDuration:0.4 
                     animations:^{
                         self.newlyCreatedNoteThumbnail.center = self.newlyCreatedNote.position;
                     } 
                     completion:^(BOOL finished){
                         if (finished)
                         {
                             [self.newlyCreatedNoteThumbnail mno_addShadow];
                             self.newlyCreatedNoteThumbnail = nil;
                             self.newlyCreatedNote = nil;
                         }
                     }];
}

- (Note *)createNote
{
	Note *newNote = [[MNOCoreDataManager sharedMNOCoreDataManager] createNote];
    
    newNote.hasLocation = @(self.locationInformationAvailable);
    if (self.locationInformationAvailable)
    {
        newNote.latitude = @(self.locationManager.location.coordinate.latitude);
        newNote.longitude = @(self.locationManager.location.coordinate.longitude);
    }
    self.newlyCreatedNote = newNote;
    return newNote;
}

- (void)checkToolbarButtonsEnabled
{
    BOOL moreThanOneNote = ([self.notes count] > 0);
    self.trashButton.enabled = moreThanOneNote;
    self.mapButton.enabled = moreThanOneNote;
    self.stackButton.enabled = moreThanOneNote;
    self.gridButton.enabled = moreThanOneNote;
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
    self.showingEditionView = YES;
    [self positionEditorAndAuxiliaryViews];
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
        self.map = [[MNOMapControllerPad alloc] init];
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
                        }
                    }];
}

- (void)transitionToEdition
{
    [self.auxiliaryView addSubview:self.editorView];
    self.editorView.alpha = 0.0;
    self.textView.inputAccessoryView = self.editingToolbar;
    self.mailButton.enabled = [MFMailComposeViewController canSendMail];
    MNOTwitterClientManager *clientManager = [MNOTwitterClientManager sharedMNOTwitterClientManager];
    self.twitterButton.enabled = ([[clientManager availableClients] count] > 0);
    
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
            self.currentThumbnail.note.lastModificationTime = [NSDate date];
            [[MNOCoreDataManager sharedMNOCoreDataManager] save];
            [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];

            self.currentThumbnail.summaryLabel.text = self.textView.text;
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

- (void)positionEditorAndAuxiliaryViews
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        self.textView.frame = CGRectMake(20.0, 20.0, 410.0, 390.0);
        self.auxiliaryView.frame = CGRectMake(159.0, 277.0, 450.0, 450.0);
    }
    else
    {
        self.textView.frame = CGRectMake(20.0, 20.0, 410.0, 300.0);
        self.auxiliaryView.frame = CGRectMake(287.0, 149.0, 450.0, 450.0);
        if (self.isShowingEditionView)
        {
            self.auxiliaryView.frame = CGRectMake(287.0, 30.0, 450.0, 450.0);
        }
    }
}

#pragma mark - Toolbar edition actions

- (IBAction)changeColor:(id)sender
{
    int value = self.currentThumbnail.note.colorCode + 1;
    value = value % 4;
    self.currentThumbnail.note.color = @(value);
    self.animationThumbnail.color = value;
    self.currentThumbnail.color = value;
}

- (IBAction)changeFont:(id)sender
{
    int value = self.currentThumbnail.note.fontCode + 1;
    value = value % 4;
    self.currentThumbnail.note.fontFamily = @(value);
    self.currentThumbnail.font = value;
    self.textView.font = [UIFont fontWithName:fontNameForCode(value) size:24.0];
//    _timeStampLabel.font = [UIFont fontWithName:fontNameForCode(value) size:12.0];
}

- (IBAction)sendToTwitter:(id)sender
{
    MNOTwitterClientManager *clientManager = [MNOTwitterClientManager sharedMNOTwitterClientManager];
    if ([clientManager canSendMessage])
    {
        // A client is installed and ready to be used!
        // Let's send a message using it. We don't care which client this is!
        [clientManager send:self.currentThumbnail.note.contents];
    }
    else 
    {
        // This path means that a client has been installed in the device,
        // but the current value in the preferences is "None" or other device not installed.
        NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
        self.twitterChoiceSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a Twitter Client"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:nil];
        NSArray *availableClients = [clientManager availableClients];
        for (NSString *client in availableClients)
        {
            [self.twitterChoiceSheet addButtonWithTitle:client];
        }
        [self.twitterChoiceSheet addButtonWithTitle:cancelText];
        self.twitterChoiceSheet.cancelButtonIndex = [availableClients count];
        
        if (self.isShowingEditionView)
        {
            [self.twitterChoiceSheet showFromBarButtonItem:self.twitterButton 
                                                  animated:YES];
        }
        else
        {
            [self.twitterChoiceSheet showFromRect:self.currentThumbnail.frame 
                                           inView:self.holderView 
                                         animated:YES];
        }
    }
}

@end
