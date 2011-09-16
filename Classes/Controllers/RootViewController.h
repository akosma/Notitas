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

@property (nonatomic, retain) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *locationButton;

- (IBAction)shakeNotes:(id)sender;
- (IBAction)insertNewObject:(id)sender;
- (IBAction)removeAllNotes:(id)sender;
- (IBAction)newNoteWithLocation:(id)sender;

- (void)createNewNoteWithContents:(NSString *)contents;
- (IBAction)about:(id)sender;

@end
