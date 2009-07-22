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
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _toolbar.transform = _hidingTransformation;
	[UIView commitAnimations];    
    
    _note.contents = _textView.text;
    if ([_delegate respondsToSelector:@selector(noteEditorDidFinishedEditing:)])
    {
        [_delegate noteEditorDidFinishedEditing:self];
    }
}

- (IBAction)trash:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:@"This action cannot be undone."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (IBAction)action:(id)sender
{
    
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 0:
            // Cancel
            break;

        case 1:
        {
            // OK
            [_textView resignFirstResponder];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            _toolbar.transform = _hidingTransformation;
            [UIView commitAnimations];    
            
            if ([_delegate respondsToSelector:@selector(noteEditorDidSendNoteToTrash:)])
            {
                [_delegate noteEditorDidSendNoteToTrash:self];
            }
            break;
        }

        default:
            break;
    }
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    _hidingTransformation = CGAffineTransformMakeTranslation(0.0, 260.0);    
    _toolbar.transform = _hidingTransformation;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated 
{
    _textView.text = _note.contents;
    [_textView becomeFirstResponder];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _toolbar.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

@end
