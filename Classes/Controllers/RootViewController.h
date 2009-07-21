//
//  RootViewController.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "NoteCellDelegate.h"
#import "NoteEditorDelegate.h"

@class NoteEditor;
@class Note;
@class NoteThumbnail;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,
                                                       NoteCellDelegate,
                                                       NoteEditorDelegate> 
{
@private
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *_managedObjectContext;
    NoteEditor *_editor;
    Note *_currentNote;
    NoteThumbnail *_thumbnail;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
