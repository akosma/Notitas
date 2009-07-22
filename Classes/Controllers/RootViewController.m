//
//  RootViewController.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "RootViewController.h"
#import "NoteCell.h"
#import "Note.h"
#import "NoteThumbnail.h"
#import "NoteEditor.h"
#import "NotitasAppDelegate.h"
#import "ColorCode.h"

static double randomAngle()
{
    // Create an angle for this note on the cardboard
    CGFloat sign = (arc4random() % 2) == 0 ? -1.0 : 1.0;
    CGFloat angle = sign * (arc4random() % 20) * M_PI / 180.0;
    return angle;
}

@interface RootViewController (Private)
- (NSFetchedResultsController *)fetchedResultsController;
- (Note *)createNoteInContext:(NSManagedObjectContext *)context;
- (void)scrollToBottomRow;
- (void)checkTrashIconEnabled;
@end


@implementation RootViewController

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
    }
    return self;
}

- (void)dealloc 
{
    _locationManager.delegate = nil;
    [_locationManager release];

    [_thumbnail release];
    _editor.delegate = nil;
    [_editor release];
	[_fetchedResultsController release];
	[_managedObjectContext release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIView methods

- (void)viewDidLoad 
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.rowHeight = 150.0;
	self.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) 
    {
	}
    
    [self checkTrashIconEnabled];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100;
    [_locationManager startUpdatingLocation];
    
    _locationInformationAvailable = NO;
    
    NSString *firstRunKey = @"firstRunKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstRun = [defaults boolForKey:firstRunKey];
    if (!firstRun)
    {
        [self about:nil];
        [defaults setBool:YES forKey:firstRunKey];
    }
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

#pragma mark -
#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation
{
    int latitude = (int)newLocation.coordinate.latitude;
    int longitude = (int)newLocation.coordinate.longitude;
    if (latitude != 0 && longitude != 0)
    {
        _locationInformationAvailable = YES;
        _locationButton.enabled = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_locationManager stopUpdatingLocation];
    _locationInformationAvailable = NO;
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

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
            NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
            NSArray *notes = [_fetchedResultsController fetchedObjects];
            for (Note *note in notes)
            {
                [context deleteObject:note];
            }
            
            NSError *error;
            if ([context save:&error]) 
            {
                [[NotitasAppDelegate sharedDelegate] playEraseSound];
                [self.tableView reloadData];
                _trashButton.enabled = NO;
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark IBOutlet methods

- (IBAction)shakeNotes:(id)sender
{
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    NSArray *notes = [_fetchedResultsController fetchedObjects];
    for (Note *note in notes)
    {
        note.angle = [NSNumber numberWithDouble:randomAngle()];
    }
    
    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
    }
}

- (IBAction)newNoteWithLocation:(id)sender
{
    if (_locationInformationAvailable)
    {
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        Note *newNote = [self createNoteInContext:context];
        CLLocationDegrees latitude = _locationManager.location.coordinate.latitude;
        CLLocationDegrees longitude = _locationManager.location.coordinate.longitude;
        NSString *template = NSLocalizedString(@"Current location:\n\nLatitude: %1.3f\nLongitude: %1.3f", @"Message created by the 'location' button");
        newNote.contents = [NSString stringWithFormat:template, latitude, longitude];
        
        NSError *error;
        if ([context save:&error]) 
        {
            [self.tableView reloadData];
            [self scrollToBottomRow];
            _trashButton.enabled = YES;
        }
    }
}

- (IBAction)removeAllNotes:(id)sender
{
    NSString *title = NSLocalizedString(@"Remove all the notes?", @"Title of the 'remove all notes' dialog");
    NSString *message = NSLocalizedString(@"You will remove all the notes!\nThis action cannot be undone.", @"Warning message of the 'remove all notes' dialog");
    NSString *cancelText = NSLocalizedString(@"Cancel", @"The 'Cancel' word");
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
	NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
	Note *newNote = [self createNoteInContext:context];
    
    NSString *copyright = NSLocalizedString(@"Notitas by akosma\nhttp://akosma.com\nCopyright 2009 © akosma software\nAll Rights Reserved", @"Copyright text");
    newNote.contents = copyright;

    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
        [self scrollToBottomRow];
        _trashButton.enabled = YES;
    }
}

- (IBAction)insertNewObject:(id)sender
{
	NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
	[self createNoteInContext:context];
    
    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
        [self scrollToBottomRow];
        _trashButton.enabled = YES;
    }
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
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
    static NSString *cellIdentifier = @"NoteCell";
    
    NoteCell *cell = (NoteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) 
    {
        cell = [[[NoteCell alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
    }

    cell.delegate = self;

    // There are two notes per cell. The one on the left always appears.
    NSInteger noteIndex = (indexPath.row * 2);
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForRow:noteIndex inSection:0];
    Note *leftNote = [_fetchedResultsController objectAtIndexPath:leftIndexPath];
    cell.leftNote = leftNote;

    // Let's check whether we need to add a note at the right:
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:indexPath.section];
    NSInteger notesCount = [sectionInfo numberOfObjects];
    if (notesCount > (noteIndex + 1))
    {
        noteIndex += 1;
        NSIndexPath *rightIndexPath = [NSIndexPath indexPathForRow:noteIndex inSection:0];
        Note *rightNote = [_fetchedResultsController objectAtIndexPath:rightIndexPath];
        cell.rightNote = rightNote;        
    }
    else 
    {
        cell.rightNote = nil;
    }

    return cell;
}

#pragma mark -
#pragma mark NoteCellDelegate methods

- (void)noteCell:(NoteCell *)cell didSelectNote:(Note *)note atFrame:(CGRect)frame
{
    _currentNote = note;
    CGRect realFrame = [self.tableView.window convertRect:frame fromView:cell];
    if (_thumbnail == nil)
    {
        _thumbnail = [[NoteThumbnail alloc] initWithFrame:realFrame];
    }
    _thumbnail.frame = realFrame;
    _thumbnail.color = (ColorCode)[_currentNote.color intValue];
    if (_editor == nil)
    {
        _editor = [[NoteEditor alloc] init];
        _editor.view.alpha = 0.0;
        _editor.delegate = self;
    }
    _editor.note = _currentNote;

    _thumbnail.alpha = 1.0;
    _thumbnail.transform = CGAffineTransformMakeRotation([note.angle doubleValue]);

    [self.tableView.window addSubview:_thumbnail];
    [self.tableView.window addSubview:_editor.view];
    [_editor viewWillAppear:NO];
    
    [UIView beginAnimations:@"maximize" context:NULL];
    [UIView setAnimationDuration:0.5];
    CGFloat offsetX = self.tableView.contentOffset.x - _thumbnail.frame.origin.x;
    CGFloat offsetY = self.tableView.contentOffset.y - _thumbnail.frame.origin.y;
    CGAffineTransform trans = CGAffineTransformMakeTranslation(offsetX / 5.0, offsetY / 5.0);
    CGAffineTransform scale = CGAffineTransformScale(trans, 10.0, 10.0);
    CGAffineTransform rotation = CGAffineTransformRotate(scale, 0.0);
    _thumbnail.transform = rotation;
    _editor.view.alpha = 1.0;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark noteEditorDelegate methods

- (void)noteEditorDidFinishedEditing:(NoteEditor *)editor
{
    NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
    }
    
    [UIView beginAnimations:@"minimize" context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    _thumbnail.transform = CGAffineTransformMakeRotation([_currentNote.angle doubleValue]);
    _editor.view.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)noteEditorDidSendNoteToTrash:(NoteEditor *)editor
{
	NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
    [context deleteObject:_currentNote];
    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
        [self checkTrashIconEnabled];
    }

    [UIView beginAnimations:@"trash" context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    _thumbnail.alpha = 0.0;
    _editor.view.alpha = 0.0;
    [UIView commitAnimations];
    
    [[NotitasAppDelegate sharedDelegate] playEraseSound];
}

#pragma mark -
#pragma mark UIView animation delegate methods

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if ([animationID isEqualToString:@"minimize"] || [animationID isEqualToString:@"trash"])
    {
        _thumbnail.transform = CGAffineTransformIdentity;
        [_thumbnail removeFromSuperview];
        [_editor.view removeFromSuperview];
    }
}


#pragma mark -
#pragma mark Private methods

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (_fetchedResultsController != nil) 
    {
        return _fetchedResultsController;
    }
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                    managedObjectContext:_managedObjectContext 
                                                                      sectionNameKeyPath:nil 
                                                                               cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
	[fetchRequest release];
	
	return _fetchedResultsController;
}    

- (Note *)createNoteInContext:(NSManagedObjectContext *)context
{
	Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                  inManagedObjectContext:context];
	
    newNote.timeStamp = [NSDate date];
    newNote.angle = [NSNumber numberWithDouble:randomAngle()];
    
    newNote.hasLocation = [NSNumber numberWithBool:_locationInformationAvailable];
    if (_locationInformationAvailable)
    {
        newNote.latitude = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
        newNote.longitude = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
    }
    return newNote;
}

- (void)scrollToBottomRow
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
    NSInteger itemCount = [sectionInfo numberOfObjects];
    NSInteger rowsCount = ceil(itemCount / 2.0);
    NSInteger row = rowsCount - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionNone
                                  animated:YES];
    
}

- (void)checkTrashIconEnabled
{
    NSArray *sections = [_fetchedResultsController sections];
    if ([sections count] > 0)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
        NSInteger itemCount = [sectionInfo numberOfObjects];
        _trashButton.enabled = (itemCount > 0);
    }
    else 
    {
        _trashButton.enabled = NO;
    }

}

@end
