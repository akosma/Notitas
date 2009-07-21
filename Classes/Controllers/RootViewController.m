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

@interface RootViewController (Private)
- (NSFetchedResultsController *)fetchedResultsController;
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
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                               target:self 
                                                                               action:@selector(insertNewObject:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                   target:nil 
                                                                                   action:nil];
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(about:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    NSArray *items = [[NSArray alloc] initWithObjects:addButton, flexibleSpace, infoBarButton, nil];
    addButton.style = UIBarButtonItemStylePlain;
    self.toolbarItems = items;
    [items release];
    [addButton release];
    [flexibleSpace release];
    [infoBarButton release];
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) 
    {
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

//- (void)viewDidUnload 
//{
//}

#pragma mark -
#pragma mark IBOutlet methods

- (void)about:(id)sender
{
	NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
	Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                  inManagedObjectContext:context];
	
    newNote.timeStamp = [NSDate date];
    newNote.contents = @"Notitas by akosma\nhttp://akosma.com\nCopyright 2009 © akosma software\nAll Rights Reserved";
    
    // Create an angle for this note on the cardboard
    CGFloat sign = (random() % 2) == 0 ? -1.0 : 1.0;
    CGFloat angle = sign * (random() % 20) * M_PI / 180.0;
    newNote.angle = [NSNumber numberWithDouble:angle];
	
    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
        NSInteger rowsCount = ceil([sectionInfo numberOfObjects] / 2.0);
        NSInteger row = rowsCount - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:YES];
    }
}

- (void)insertNewObject:(id)sender
{
	NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
	Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                  inManagedObjectContext:context];
	
    newNote.timeStamp = [NSDate date];

    // Create an angle for this note on the cardboard
    CGFloat sign = (random() % 2) == 0 ? -1.0 : 1.0;
    CGFloat angle = sign * (random() % 20) * M_PI / 180.0;
    newNote.angle = [NSNumber numberWithDouble:angle];
	
    NSError *error;
    if ([context save:&error]) 
    {
        [self.tableView reloadData];
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:0];
        NSInteger rowsCount = ceil([sectionInfo numberOfObjects] / 2.0);
        NSInteger row = rowsCount - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:YES];
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
    CGRect realFrame = [self.navigationController.view convertRect:frame fromView:cell];
    if (_thumbnail == nil)
    {
        _thumbnail = [[NoteThumbnail alloc] initWithFrame:realFrame];
    }
    _thumbnail.frame = realFrame;
    if (_editor == nil)
    {
        _editor = [[NoteEditor alloc] init];
        _editor.view.alpha = 0.0;
        _editor.delegate = self;
    }
    _editor.note = _currentNote;

    _thumbnail.alpha = 1.0;
    _thumbnail.transform = CGAffineTransformMakeRotation([note.angle doubleValue]);

    [self.navigationController.view addSubview:_thumbnail];
    [self.navigationController.view addSubview:_editor.view];
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
    }

    [UIView beginAnimations:@"trash" context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    _thumbnail.alpha = 0.0;
    _editor.view.alpha = 0.0;
    [UIView commitAnimations];
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

@end
