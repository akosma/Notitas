//
//  MNORootController.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MNONoteEditorControllerDelegate.h"

@interface MNORootController : UIViewController <NSFetchedResultsControllerDelegate,
                                                 MNONoteEditorControllerDelegate,
                                                 CLLocationManagerDelegate,
                                                 UIAlertViewDelegate,
                                                 UICollectionViewDataSource,
                                                 UICollectionViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *locationButton;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

- (IBAction)shakeNotes:(id)sender;
- (IBAction)insertNewObject:(id)sender;
- (IBAction)removeAllNotes:(id)sender;
- (IBAction)newNoteWithLocation:(id)sender;

- (void)createNewNoteWithContents:(NSString *)contents;
- (IBAction)about:(id)sender;

@end
