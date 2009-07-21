//
//  NoteEditor.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "NoteEditor.h"
#import "Note.h"

@implementation NoteEditor

@synthesize note = _note;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Constructor and destructor

- (id)init
{
    if (self = [super initWithNibName:@"NoteEditor" bundle:nil]) 
    {
    }
    return self;
}

- (void)dealloc 
{
    _delegate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)done:(id)sender
{
    [_textView resignFirstResponder];
    _note.contents = _textView.text;
    if ([_delegate respondsToSelector:@selector(noteEditorDidFinishedEditing:)])
    {
        [_delegate noteEditorDidFinishedEditing:self];
    }
}

- (IBAction)trash:(id)sender
{
    [_textView resignFirstResponder];
    if ([_delegate respondsToSelector:@selector(noteEditorDidSendNoteToTrash:)])
    {
        [_delegate noteEditorDidSendNoteToTrash:self];
    }
}

#pragma mark -
#pragma mark UIViewController methods

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated 
{
    _textView.text = _note.contents;
    [_textView becomeFirstResponder];
}

@end
