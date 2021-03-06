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

static MNOFontCode randomFont()
{
    MNOFontCode code = (MNOFontCode)(arc4random() % 4);
    return code;
}

static MNOColorCode randomColorCode()
{
    MNOColorCode code = (MNOColorCode)(arc4random() % 4);
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
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        [undoManager setLevelsOfUndo:30];
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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" 
                                              inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
	NSArray *sortDescriptors = @[sortDescriptor];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:cacheName];
	return fetchedResultsController;
}

- (NSArray *)allNotes
{
    NSFetchRequest *fetchRequest = [self fetchRequestForType:@"Note"];

    // Order the notes by descending modification time
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"lastModificationTime" 
                                                                     ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" 
                                                                     ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor1, sortDescriptor2];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSArray *notes = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return notes;
}

- (Note *)createNote
{
    [NSFetchedResultsController deleteCacheWithName:cacheName];

	Note *newNote = [self createObjectOfType:@"Note"];
	
    newNote.timeStamp = [NSDate date];
    newNote.lastModificationTime = [NSDate date];
    newNote.angle = @(randomAngle());
    newNote.fontFamily = [NSNumber numberWithDouble:randomFont()];
    newNote.color = [NSNumber numberWithInt:randomColorCode()];
    newNote.contents = @"";
    
    float xpos = randomXPosition();
    float ypos = randomYPosition();
    newNote.xcoord = @(xpos);
    newNote.ycoord = @(ypos);
    
    return newNote;
}

- (void)shakeNotes
{
    // We don't want to undo the new angles of the notes!
    [self.managedObjectContext.undoManager disableUndoRegistration];
    NSArray *notes = [self allNotes];
    for (Note *note in notes)
    {
        note.angle = @(randomAngle());
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

- (void)createNoteFromDictionary:(NSDictionary *)dict
{
    Note *note = [self createObjectOfType:@"Note"];
    [note importDataFromDictionary:dict];
    note.xcoord = @(randomXPosition());
    note.ycoord = @(randomYPosition());
    note.angle = @(randomAngle());
    note.lastModificationTime = [NSDate date];
    note.timeStamp = [NSDate date];
    [self save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MNOCoreDataManagerNoteImportedNotification 
                                                        object:self];
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
