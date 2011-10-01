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


@interface MNORootController ()

@property (nonatomic, retain) Note *currentNote;
@property (nonatomic, retain) MNONoteEditorController *editor;
@property (nonatomic, retain) MNONoteThumbnail *thumbnail;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL locationInformationAvailable;

- (void)scrollToBottomRowAnimated:(BOOL)animated;
- (void)checkTrashIconEnabled;
- (Note *)createNote;

@end


@implementation MNORootController

@synthesize locationInformationAvailable = _locationInformationAvailable;
@synthesize currentNote = _currentNote;
@synthesize editor = _editor;
@synthesize thumbnail = _thumbnail;
@synthesize locationManager = _locationManager;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize trashButton = _trashButton;
@synthesize locationButton = _locationButton;
@synthesize toolbar = _toolbar;
@synthesize tableView = _tableView;

- (void)dealloc 
{
    [_locationButton release];
    [_currentNote release];
    _locationManager.delegate = nil;
    [_locationManager release];
    [_toolbar release];
    [_tableView release];

    [_thumbnail release];
    _editor.delegate = nil;
    [_editor release];
	[_fetchedResultsController release];
    [_trashButton release];
    [super dealloc];
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
    
    self.toolbar.frame = CGRectMake(0.0, 416.0, 320.0, 44.0);
    [self.view addSubview:self.toolbar];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = 160.0;
	self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    
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
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
    
    self.locationInformationAvailable = NO;
    
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

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
    [_thumbnail release];
    _thumbnail = nil;
    
    _editor.delegate = nil;
    [_editor release];
    _editor = nil;
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
    [self.tableView reloadData];
    [self scrollToBottomRowAnimated:YES];
    self.trashButton.enabled = YES;
}

- (IBAction)shakeNotes:(id)sender
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] shakeNotes];
    [self.tableView reloadData];
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
        [self.tableView reloadData];
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
    [alert release];
}

- (IBAction)about:(id)sender
{
	Note *newNote = [self createNote];
    
    NSString *copyright = NSLocalizedString(@"COPYRIGHT_TEXT", @"Copyright text");
    newNote.contents = copyright;

    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self.tableView reloadData];
    [self scrollToBottomRowAnimated:YES];
    self.trashButton.enabled = YES;
}

- (IBAction)insertNewObject:(id)sender
{
	[self createNote];
    
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
    [self.tableView reloadData];
    [self scrollToBottomRowAnimated:YES];
    self.trashButton.enabled = YES;
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger rowsCount = ceil([sectionInfo numberOfObjects] / 2.0);
    return rowsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *cellIdentifier = @"MNONoteCell";
    
    MNONoteCell *cell = (MNONoteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [[[MNONoteCell alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
    }

    cell.delegate = self;

    // There are two notes per cell. The one on the left always appears.
    NSInteger noteIndex = (indexPath.row * 2);
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForRow:noteIndex inSection:0];
    Note *leftNote = [self.fetchedResultsController objectAtIndexPath:leftIndexPath];
    cell.leftNote = leftNote;

    // Let's check whether we need to add a note at the right:
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    NSInteger notesCount = [sectionInfo numberOfObjects];
    if (notesCount > (noteIndex + 1))
    {
        noteIndex += 1;
        NSIndexPath *rightIndexPath = [NSIndexPath indexPathForRow:noteIndex inSection:0];
        Note *rightNote = [self.fetchedResultsController objectAtIndexPath:rightIndexPath];
        cell.rightNote = rightNote;        
    }
    else 
    {
        cell.rightNote = nil;
    }

    return cell;
}

#pragma mark - MNONoteCellDelegate methods

- (void)noteCell:(MNONoteCell *)cell didSelectNote:(Note *)note atFrame:(CGRect)frame
{
	[self resignFirstResponder];
    [[MNOCoreDataManager sharedMNOCoreDataManager] beginUndoGrouping];

    self.currentNote = note;
    CGRect realFrame = [self.tableView.window convertRect:frame fromView:cell];
    if (self.thumbnail == nil)
    {
        self.thumbnail = [[[MNONoteThumbnail alloc] initWithFrame:realFrame] autorelease];
    }
    self.thumbnail.frame = realFrame;
    self.thumbnail.color = self.currentNote.colorCode;
    [self.thumbnail setNeedsDisplay];
    if (self.editor == nil)
    {
        self.editor = [[[MNONoteEditorController alloc] init] autorelease];
        self.editor.view.alpha = 0.0;
        self.editor.delegate = self;
    }
    self.editor.note = self.currentNote;

    self.thumbnail.alpha = 1.0;
    self.thumbnail.transform = CGAffineTransformMakeRotation(note.angleRadians);

    [self.tableView.window addSubview:self.thumbnail];
    [self.tableView.window addSubview:self.editor.view];
    [self.editor viewWillAppear:NO];
    
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
    [self.tableView reloadData];

    [UIView animateWithDuration:0.5
                     animations:^{
                         self.thumbnail.transform = CGAffineTransformMakeRotation(self.currentNote.angleRadians);
                         self.editor.view.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         self.thumbnail.transform = CGAffineTransformIdentity;
                         [self.thumbnail removeFromSuperview];
                         [self.editor.view removeFromSuperview];
                         self.editing = NO;
                     }];

    [[MNOCoreDataManager sharedMNOCoreDataManager] endUndoGrouping];
}

- (void)noteEditorDidSendNoteToTrash:(MNONoteEditorController *)editor
{
	[self becomeFirstResponder];
    [[MNOCoreDataManager sharedMNOCoreDataManager] deleteObject:self.currentNote];
    [self.tableView reloadData];
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
            [self.tableView reloadData];
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
	[self.tableView reloadData];
    [self checkTrashIconEnabled];
}

- (void)undoManagerDidRedo:(NSNotification *)notification 
{
	[self.tableView reloadData];
    [self checkTrashIconEnabled];
}

- (void)noteImported:(NSNotification *)notification
{
	[self.tableView reloadData];
    [self checkTrashIconEnabled];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (!self.editing)
    {
        [self.tableView reloadData];
        [self checkTrashIconEnabled];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.fetchedResultsController)
    {
        [self.tableView reloadData];
    }
}

#pragma mark - Private methods

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

- (void)scrollToBottomRowAnimated:(BOOL)animated
{
    NSArray *sections = [self.fetchedResultsController sections];
    if ([sections count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        NSInteger itemCount = [sectionInfo numberOfObjects];
        NSInteger rowsCount = ceil(itemCount / 2.0);
        NSInteger row = rowsCount - 1;
        if (row >= 0) // this fixes a crash in the device, but works on the simulator
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionNone
                                          animated:animated];
        }
    }
}

- (void)checkTrashIconEnabled
{
    NSArray *sections = [self.fetchedResultsController sections];
    if ([sections count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        NSInteger itemCount = [sectionInfo numberOfObjects];
        self.trashButton.enabled = (itemCount > 0);
    }
    else 
    {
        self.trashButton.enabled = NO;
    }

}

@end
