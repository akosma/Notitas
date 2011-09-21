//
//  MNOCoreDataManager.m
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "MNOCoreDataManager.h"
#import "MNOModels.h"
#import "MNOHelpers.h"

static NSString *cacheName = @"Root";

static double randomAngle()
{
    // Returns an angle between -19 and 19 degrees, in radians
    CGFloat sign = (arc4random() % 2) == 0 ? -1.0 : 1.0;
    CGFloat angle = sign * (arc4random() % 20) * M_PI / 180.0;
    return angle;
}

static FontCode randomFont()
{
    FontCode code = (FontCode)(arc4random() % 4);
    return code;
}

static ColorCode randomColorCode()
{
    ColorCode code = (ColorCode)(arc4random() % 4);
    return code;
}

static float randomXPosition()
{
    float position = (float)(arc4random() % 824) + 100;
    return position;
}

static float randomYPosition()
{
    float position = (float)(arc4random() % 804) + 100;
    return position;
}

@implementation MNOCoreDataManager

@dynamic undoManager;

SYNTHESIZE_SINGLETON_FOR_CLASS(MNOCoreDataManager)

- (id)init
{
    self = [super initWithFilename:@"Notitas"];
    if (self) 
    {
        NSUndoManager *undoManager = [[[NSUndoManager alloc] init] autorelease];
        [undoManager setLevelsOfUndo:10];
        self.managedObjectContext.undoManager = undoManager;
    }
    return self;
}

#pragma mark - Public methods

- (NSUndoManager *)undoManager
{
    return self.managedObjectContext.undoManager;
}

- (NSFetchedResultsController *)createFetchedResultsController 
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" 
                                              inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:cacheName] autorelease];
	return fetchedResultsController;
}

- (NSArray *)allNotes
{
    NSFetchRequest *fetchRequest = [self fetchRequestForType:@"Note"];
    NSArray *notes = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return notes;
}

- (Note *)createNote
{
    [NSFetchedResultsController deleteCacheWithName:cacheName];

	Note *newNote = [self createObjectOfType:@"Note"];
	
    newNote.timeStamp = [NSDate date];
    newNote.angle = [NSNumber numberWithDouble:randomAngle()];
    newNote.fontFamily = [NSNumber numberWithDouble:randomFont()];
    newNote.color = [NSNumber numberWithInt:randomColorCode()];
    newNote.contents = @"";
    
    float xpos = randomXPosition();
    float ypos = randomYPosition();
    newNote.xcoord = [NSNumber numberWithFloat:xpos];
    newNote.ycoord = [NSNumber numberWithFloat:ypos];
    
    return newNote;
}

- (void)shakeNotes
{
    // We don't want to undo the new angles of the notes!
    [self.managedObjectContext.undoManager disableUndoRegistration];
    NSArray *notes = [self allNotes];
    for (Note *note in notes)
    {
        note.angle = [NSNumber numberWithDouble:randomAngle()];
    }
    [self save];
    
    // Start registering undo events again
    [self.managedObjectContext.undoManager enableUndoRegistration];    
}

- (void)beginUndoGrouping
{
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)endUndoGrouping
{
    [self.managedObjectContext.undoManager endUndoGrouping];
}

#pragma mark - Overridden methods

- (void)save
{
    [super save];
    [NSFetchedResultsController deleteCacheWithName:cacheName];
}

- (void)deleteObject:(NSManagedObject *)object
{
    [super deleteObject:object];
    [NSFetchedResultsController deleteCacheWithName:cacheName];
}

@end
