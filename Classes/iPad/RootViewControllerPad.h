//
//  RootViewControllerPad.h
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface RootViewControllerPad : UIViewController <UIAlertViewDelegate,
                                                     CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *locationButton;
@property (nonatomic, retain) IBOutlet UIView *holderView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *locationView;
@property (nonatomic, retain) IBOutlet UIView *flipView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *redoButton;
@property (nonatomic, retain) IBOutlet UIView *modalBlockerView;

- (IBAction)shakeNotes:(id)sender;
- (IBAction)insertNewObject:(id)sender;
- (IBAction)removeAllNotes:(id)sender;
- (IBAction)newNoteWithLocation:(id)sender;

- (void)createNewNoteWithContents:(NSString *)contents;
- (IBAction)about:(id)sender;
- (IBAction)showMapWithAllNotes:(id)sender;

- (IBAction)hideLocationView:(id)sender;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

@end
