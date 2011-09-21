//
//  MNONoteEditorController.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MNONoteEditorControllerDelegate.h"

@class Note;

@interface MNONoteEditorController : UIViewController <UIAlertViewDelegate, 
                                                       UIActionSheetDelegate,
                                                       MFMailComposeViewControllerDelegate,
                                                       MKMapViewDelegate,
                                                       UITextViewDelegate>

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *timeStampLabel;
@property (nonatomic, retain) Note *note;
@property (nonatomic, assign) id<MNONoteEditorControllerDelegate> delegate;

- (IBAction)changeColor:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)trash:(id)sender;
- (IBAction)changeFont:(id)sender;

@end
