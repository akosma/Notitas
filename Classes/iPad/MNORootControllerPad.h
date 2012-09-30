//
//  MNORootControllerPad.h
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>

@interface MNORootControllerPad : UIViewController <UIAlertViewDelegate,
                                                    CLLocationManagerDelegate,
                                                    UITextViewDelegate,
                                                    MKMapViewDelegate,
                                                    MFMailComposeViewControllerDelegate,
                                                    UIActionSheetDelegate,
                                                    UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *locationButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *mapButton;
@property (nonatomic, strong) IBOutlet UIView *holderView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *auxiliaryView;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *undoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *redoButton;
@property (nonatomic, strong) IBOutlet UIView *modalBlockerView;
@property (nonatomic, strong) IBOutlet UIView *editorView;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIToolbar *editingToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *mailButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *twitterButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *facebookButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *gridButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stackButton;

- (IBAction)shakeNotes:(id)sender;
- (IBAction)insertNewObject:(id)sender;
- (IBAction)removeAllNotes:(id)sender;
- (IBAction)newNoteWithLocation:(id)sender;
- (IBAction)orderNotes:(id)sender;
- (IBAction)makeStacks:(id)sender;

- (void)createNewNoteWithContents:(NSString *)contents;
- (IBAction)about:(id)sender;
- (IBAction)showMapWithAllNotes:(id)sender;

- (IBAction)dismissBlockerView:(id)sender;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

- (IBAction)changeColor:(id)sender;
- (IBAction)changeFont:(id)sender;
- (IBAction)sendViaEmail:(id)sender;
- (IBAction)sendToTwitter:(id)sender;
- (IBAction)sendToFacebook:(id)sender;

@end
