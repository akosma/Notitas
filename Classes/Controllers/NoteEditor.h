//
//  NoteEditor.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteEditorDelegate.h"

@class Note;

@interface NoteEditor : UIViewController <UITextViewDelegate>
{
@private
    IBOutlet UITextView *_textView;
    
    Note *_note;
    
    id<NoteEditorDelegate> _delegate;
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, assign) id<NoteEditorDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)trash:(id)sender;

@end
