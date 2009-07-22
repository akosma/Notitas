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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:@"Send via e-mail", @"Post using Twitterriffic", nil];
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 0:
        {
            // E-mail
            MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
            composer.mailComposeDelegate = self;
            
            NSMutableString *message = [[NSMutableString alloc] init];
            [message appendString:_note.contents];
            [message appendString:@"\n\nSent from Notitas by akosma - http://akosma.com/"];
            NSString *subject = @"Note sent from Notitas by akosma";
            [composer setSubject:subject];
            [composer setMessageBody:message isHTML:NO];
            [self presentModalViewController:composer animated:YES];
            [composer release];
            [message release];
            break;
        }

        case 1:
        {
            // Twitterriffic
            NSString *message = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                          (CFStringRef)_note.contents,
                                                                          NULL, 
                                                                          (CFStringRef)@";/?:@&=+$,", 
                                                                          kCFStringEncodingUTF8);
            NSString *stringURL = [NSString stringWithFormat:@"twitterrific:///post?message=%@", message];
            [message release];
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
            break;
        }

//        case 2:
//        {
//            // TwitterFon
//            // Delayed until the handling of URLs by TwitterFon includes removing %20 escapes...
//            NSString *message = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
//                                                                                    (CFStringRef)_note.contents,
//                                                                                    NULL, 
//                                                                                    (CFStringRef)@";/?:@&=+$,", 
//                                                                                    kCFStringEncodingUTF8);
//            NSString *stringURL = [NSString stringWithFormat:@"twitterfon:///post?%@", message];
//            [message release];
//            NSURL *url = [NSURL URLWithString:stringURL];
//            [[UIApplication sharedApplication] openURL:url];
//            break;
//        }
            
        default:
            break;
    }
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
#pragma mark MFMailComposeViewControllerDelegate methods
             
- (void)mailComposeController:(MFMailComposeViewController *)composer 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error
{
    [composer dismissModalViewControllerAnimated:YES];
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
