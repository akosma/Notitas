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
#import <Social/Social.h>
#import "MNONoteEditorControllerDelegate.h"

@class Note;

@interface MNONoteEditorController : UIViewController <UIAlertViewDelegate, 
                                                       UIActionSheetDelegate,
                                                       MFMailComposeViewControllerDelegate,
                                                       MKMapViewDelegate,
                                                       UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UILabel *timeStampLabel;
@property (strong, nonatomic) IBOutlet UIView *inputAccessoryView;
@property (nonatomic, strong) Note *note;
@property (nonatomic, weak) id<MNONoteEditorControllerDelegate> delegate;

- (IBAction)changeColor:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)trash:(id)sender;
- (IBAction)changeFont:(id)sender;

@end
