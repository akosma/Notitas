//
//  MNORootViewController.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "MNORootController.h"
#import "MNOHelpers.h"
#import "MNOViews.h"
#import "MNOModels.h"
#import "MNONoteEditorController.h"


static NSString *CELL_IDENTIFIER = @"MNONoteCell";

@interface MNORootController ()

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, strong) MNONoteEditorController *editor;
@property (nonatomic, strong) MNONoteThumbnail *thumbnail;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL locationInformationAvailable;

- (void)scrollToBottomRowAnimated:(BOOL)animated;
- (void)checkTrashIconEnabled;
- (Note *)createNote;

@end


@implementation MNORootController

- (void)dealloc 
{
    _locationManager.delegate = nil;

    _editor.delegate = nil;
}

#pragma mark - UIViewController methods

-(BOOL)canBecomeFirstResponder 
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // To avoid memory problems on startup, avoid the animation
    // when this screen is shown; if there is an animation here,
    // all the items are loaded into memory at once, which may 
    // crash the application.
    [self scrollToBottomRowAnimated:NO];
	[self becomeFirstResponder];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.fetchedResultsController = [[MNOCoreDataManager sharedMNOCoreDataManager] createFetchedResultsController];
    self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController performFetch:nil];
    
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

    [self checkTrashIconEnabled];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
    
    self.locationInformationAvailable = NO;
    
    [self.collectionView registerClass:[MNONoteCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
    
    NSString *firstRunKey = @"firstRunKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstRun = [defaults boolForKey:firstRunKey];
    if (!firstRun)
    {
        [self about:nil];
        [defaults setBool:YES forKey:firstRunKey];
    }
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[self resignFirstResponder];
	[super viewWillDisappear:animated];
}

#pragma mark - Shake events

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self shakeNotes:self];
}

#pragma mark - Public methods

- (void)createNewNoteWithContents:(NSString *)contents
{
	Note *newNote = [self createNote];
    newNote.contents = contents;

    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self.collectionView reloadData];
    [self scrollToBottomRowAnimated:YES];
    self.trashButton.enabled = YES;
}

- (IBAction)shakeNotes:(id)sender
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] shakeNotes];
    [self.collectionView reloadData];
}

- (IBAction)newNoteWithLocation:(id)sender
{
    if (self.locationInformationAvailable)
    {
        Note *newNote = [self createNote];
        CLLocationDegrees latitude = _locationManager.location.coordinate.latitude;
        CLLocationDegrees longitude = _locationManager.location.coordinate.longitude;
        NSString *template = NSLocalizedString(@"CURRENT_LOCATION", @"Message created by the 'location' button");
        newNote.contents = [NSString stringWithFormat:template, latitude, longitude];

        [[MNOCoreDataManager sharedMNOCoreDataManager] save];
        [self.collectionView reloadData];
        [self scrollToBottomRowAnimated:YES];
        self.trashButton.enabled = YES;
    }
}

- (IBAction)removeAllNotes:(id)sender
{
    NSString *title = NSLocalizedString(@"REMOVE_ALL_NOTES_QUESTION", @"Title of the 'remove all notes' dialog");
    NSString *message = NSLocalizedString(@"ALL_NOTES_UNDO_POSSIBLE", @"Warning message of the 'remove all notes' dialog");
    NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelText
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)about:(id)sender
{
	Note *newNote = [self createNote];
    
    NSString *copyright = NSLocalizedString(@"COPYRIGHT_TEXT", @"Copyright text");
    newNote.contents = copyright;

    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self.collectionView reloadData];
    [self scrollToBottomRowAnimated:YES];
    self.trashButton.enabled = YES;
}

- (IBAction)insertNewObject:(id)sender
{
	[self createNote];
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self.collectionView reloadData];
    [self scrollToBottomRowAnimated:YES];
    self.trashButton.enabled = YES;
}

#pragma mark - Table view methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MNONoteCell *cell = (MNONoteCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                 forIndexPath:indexPath];
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.note = note;

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(120.0, 120.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20.0, 25.0, 50.0, 25.0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self resignFirstResponder];
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];

    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.currentNote = note;
    
    MNONoteCell *cell = (MNONoteCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    CGRect realFrame = [self.view convertRect:frame fromView:self.collectionView];
    if (self.thumbnail == nil)
    {
        self.thumbnail = [[MNONoteThumbnail alloc] initWithFrame:realFrame];
    }
    self.thumbnail.frame = realFrame;
    self.thumbnail.color = self.currentNote.colorCode;
    [self.thumbnail setNeedsDisplay];
    if (self.editor == nil)
    {
        self.editor = [[MNONoteEditorController alloc] init];
        self.editor.view.alpha = 0.0;
        self.editor.delegate = self;
    }
    [self addChildViewController:self.editor];
    self.editor.note = self.currentNote;
    
    self.thumbnail.alpha = 1.0;
    self.thumbnail.transform = CGAffineTransformMakeRotation(note.angleRadians);
    
    [self.view addSubview:self.thumbnail];
    [self.view addSubview:self.editor.view];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGAffineTransform trans = CGAffineTransformMakeTranslation(-realFrame.origin.x, -realFrame.origin.y);
                         CGAffineTransform scale = CGAffineTransformScale(trans, 10.0, 10.0);
                         CGAffineTransform rotation = CGAffineTransformRotate(scale, -note.angleRadians);
                         self.thumbnail.transform = rotation;
                         self.editor.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.editing = YES;
                         }
                     }];
}

#pragma mark - NoteEditorDelegate methods

- (void)noteEditorDidFinishedEditing:(MNONoteEditorController *)editor
{
	[self becomeFirstResponder];

    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self.collectionView reloadData];

    [UIView animateWithDuration:0.5
                     animations:^{
                         self.thumbnail.transform = CGAffineTransformMakeRotation(self.currentNote.angleRadians);
                         self.editor.view.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         self.thumbnail.transform = CGAffineTransformIdentity;
                         [self.thumbnail removeFromSuperview];
                         [self.editor.view removeFromSuperview];
                         [self.editor removeFromParentViewController];
                         self.editing = NO;
                     }];

    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
}

- (void)noteEditorDidSendNoteToTrash:(MNONoteEditorController *)editor
{
	[self becomeFirstResponder];
    [[MNOCoreDataManager sharedMNOCoreDataManager] deleteObject:self.currentNote];
    [self.collectionView reloadData];
    [self checkTrashIconEnabled];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.thumbnail.alpha = 0.0;
                         self.editor.view.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         self.thumbnail.transform = CGAffineTransformIdentity;
                         [self.thumbnail removeFromSuperview];
                         [self.editor.view removeFromSuperview];
                     }];
    
    [[MNOSoundManager sharedMNOSoundManager] playEraseSound];
    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
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
            [[MNOCoreDataManager sharedMNOCoreDataManager] deleteAllObjectsOfType:@"Note"];
            [[MNOSoundManager sharedMNOSoundManager] playEraseSound];
            [self.collectionView reloadData];
            self.trashButton.enabled = NO;
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Notification handlers

- (void)undoManagerDidUndo:(NSNotification *)notification 
{
	[self.collectionView reloadData];
    [self checkTrashIconEnabled];
}

- (void)undoManagerDidRedo:(NSNotification *)notification 
{
	[self.collectionView reloadData];
    [self checkTrashIconEnabled];
}

- (void)noteImported:(NSNotification *)notification
{
	[self.collectionView reloadData];
    [self checkTrashIconEnabled];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (!self.editing)
    {
        [self.collectionView reloadData];
        [self checkTrashIconEnabled];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.fetchedResultsController)
    {
        [self.collectionView reloadData];
    }
}

#pragma mark - Private methods

- (Note *)createNote
{
	Note *newNote = [[MNOCoreDataManager sharedMNOCoreDataManager] createNote];

    newNote.hasLocation = @(self.locationInformationAvailable);
    if (self.locationInformationAvailable)
    {
        newNote.latitude = @(self.locationManager.location.coordinate.latitude);
        newNote.longitude = @(self.locationManager.location.coordinate.longitude);
    }
    return newNote;
}

- (void)scrollToBottomRowAnimated:(BOOL)animated
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger itemCount = [sectionInfo numberOfObjects] - 1;
    if (itemCount >= 0) // this fixes a crash in the device, but works on the simulator
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:itemCount inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
    }
}

- (void)checkTrashIconEnabled
{
    NSArray *sections = [self.fetchedResultsController sections];
    if ([sections count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        NSInteger itemCount = [sectionInfo numberOfObjects];
        self.trashButton.enabled = (itemCount > 0);
    }
    else 
    {
        self.trashButton.enabled = NO;
    }

}

@end
