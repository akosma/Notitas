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
#import "NoteEditorDelegate.h"

@class Note;

@interface NoteEditor : UIViewController <UIAlertViewDelegate, 
                                          UIActionSheetDelegate,
                                          MFMailComposeViewControllerDelegate>
{
@private
    IBOutlet UITextView *_textView;
    IBOutlet UIToolbar *_toolbar;
    
    Note *_note;
    
    CGAffineTransform _hidingTransformation;
    
    id<NoteEditorDelegate> _delegate;
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, assign) id<NoteEditorDelegate> delegate;

- (IBAction)changeColor:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)trash:(id)sender;

@end
