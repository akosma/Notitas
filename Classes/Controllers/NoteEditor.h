//
//  NoteEditor.h
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
#import "NoteEditorDelegate.h"

@class Note;
@class Map;
@class TwitterClientManager;

@interface NoteEditor : UIViewController <UIAlertViewDelegate, 
                                          UIActionSheetDelegate,
                                          MFMailComposeViewControllerDelegate,
                                          MKMapViewDelegate,
                                          UITextViewDelegate>
{
@private
    IBOutlet UITextView *_textView;
    IBOutlet UIToolbar *_toolbar;
    IBOutlet UILabel *_timeStampLabel;
    UIActionSheet *_twitterChoiceSheet;
    
    Note *_note;
    NSInteger _twitterrifficButtonIndex;
    NSInteger _locationButtonIndex;
    
    CGAffineTransform _hidingTransformation;
    
    id<NoteEditorDelegate> _delegate;
    
    Map *_map;
    TwitterClientManager *_clientManager;
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, assign) id<NoteEditorDelegate> delegate;

- (IBAction)changeColor:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)trash:(id)sender;
- (IBAction)changeFont:(id)sender;

@end
