//
//  RootViewController.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NoteCellDelegate.h"
#import "NoteEditorDelegate.h"

@class NoteEditor;
@class Note;
@class NoteThumbnail;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate,
                                                       NoteCellDelegate,
                                                       NoteEditorDelegate,
                                                       CLLocationManagerDelegate,
                                                       UIAlertViewDelegate> 
{
@private
	NSFetchedResultsController *_fetchedResultsController;
	NSManagedObjectContext *_managedObjectContext;
    
    NoteEditor *_editor;
    Note *_currentNote;
    NoteThumbnail *_thumbnail;
    
    IBOutlet UIBarButtonItem *_locationButton;
    CLLocationManager *_locationManager;
    BOOL _locationInformationAvailable;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)shakeNotes:(id)sender;
- (IBAction)insertNewObject:(id)sender;
- (IBAction)about:(id)sender;
- (IBAction)removeAllNotes:(id)sender;
- (IBAction)newNoteWithLocation:(id)sender;

@end
