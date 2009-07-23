//
//  NoteEditor.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "NoteEditor.h"
#import "Note.h"
#import "Map.h"
#import "ColorCode.h"

@interface NoteEditor (Private)
- (void)disappear;
@end


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
    _map.delegate = nil;
    [_map release];
    [_note release];
    _delegate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)changeFont:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFontNotification" 
                                                        object:self];
    int value = _note.fontCode + 1;
    value = value % 4;
    _note.fontFamily = [NSNumber numberWithInt:value];
    _textView.font = [UIFont fontWithName:fontNameForCode(value) size:24.0];
    _timeStampLabel.font = [UIFont fontWithName:fontNameForCode(value) size:12.0];
}

- (IBAction)changeColor:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeColorNotification" 
                                                        object:self];
    int value = _note.colorCode + 1;
    value = value % 4;
    _note.color = [NSNumber numberWithInt:value];
}

- (IBAction)done:(id)sender
{
    [self disappear];
    
    _note.contents = _textView.text;
    if ([_delegate respondsToSelector:@selector(noteEditorDidFinishedEditing:)])
    {
        [_delegate noteEditorDidFinishedEditing:self];
    }
}

- (IBAction)trash:(id)sender
{
    NSString *title = NSLocalizedString(@"Are you sure?", @"Title of the 'trash' dialog of the editor controller");
    NSString *message = NSLocalizedString(@"This action cannot be undone.", @"Explanation of the 'trash' dialog of the editor controller");
    NSString *cancelText = NSLocalizedString(@"Cancel", @"The 'cancel' word");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelText
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (IBAction)action:(id)sender
{
    // Make sure that the latest contents are available for the actions
    _note.contents = _textView.text;

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:nil];

    NSString *emailText = NSLocalizedString(@"Send via e-mail", @"Button to send notes via e-mail");
    NSString *twitterrifficText = NSLocalizedString(@"Post using Twitterriffic", @"Button to send notes via Twitter");
    NSString *locationText = NSLocalizedString(@"View location", @"Button to view the note location");
    NSString *cancelText = NSLocalizedString(@"Cancel", @"The 'cancel' word");
    
    [sheet addButtonWithTitle:emailText];
    NSInteger sheetButtonCount = 1;
    
    NSString *stringURL = @"twitterrific:///post?message=test";
    NSURL *url = [NSURL URLWithString:stringURL];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [sheet addButtonWithTitle:twitterrifficText];
        _twitterrifficButtonIndex = sheetButtonCount;
        sheetButtonCount += 1;
    }    
    
    BOOL locationAvailable = [_note.hasLocation boolValue];
    if (locationAvailable)
    {
        [sheet addButtonWithTitle:locationText];
        _locationButtonIndex = sheetButtonCount;
        sheetButtonCount += 1;
    }
    [sheet addButtonWithTitle:cancelText];
    sheet.cancelButtonIndex = sheetButtonCount;
    sheetButtonCount += 1;
    
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // E-mail
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        composer.mailComposeDelegate = self;

        NSMutableString *message = [[NSMutableString alloc] init];
        if (_note.contents == nil || [_note.contents length] == 0)
        {
            NSString *emptyNoteText = NSLocalizedString(@"(empty note)", @"To be used when en empty note is sent via e-mail");
            [message appendString:emptyNoteText];
        }
        else
        {
            [message appendString:_note.contents];
        }
        NSString *sentFromText = NSLocalizedString(@"\n\nSent from Notitas by akosma - http://akosma.com/", @"Some marketing here");
        [message appendString:sentFromText];
        NSString *subject = NSLocalizedString(@"Note sent from Notitas by akosma", @"Title of the e-mail sent by the application");
        [composer setSubject:subject];
        [composer setMessageBody:message isHTML:NO];

        [self disappear];

        [self presentModalViewController:composer animated:YES];
        [composer release];
        [message release];
    }
    else
    {
        if (_twitterrifficButtonIndex == buttonIndex)
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
        }
        else if (_locationButtonIndex == buttonIndex)
        {
            if ([_note.hasLocation boolValue])
            {
                if (_map == nil)
                {
                    _map = [[Map alloc] init];
                    _map.delegate = self;
                }
                _map.note = _note;
                
                [self disappear];
                [self presentModalViewController:_map animated:YES];
            }
        }
    }

// TwitterFon
// Delayed until the handling of URLs by TwitterFon includes removing %20 escapes...
// NSString *message = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
//                                                                         (CFStringRef)_note.contents,
//                                                                         NULL, 
//                                                                         (CFStringRef)@";/?:@&=+$,", 
//                                                                         kCFStringEncodingUTF8);
// NSString *stringURL = [NSString stringWithFormat:@"twitterfon:///post?%@", message];
// [message release];
// NSURL *url = [NSURL URLWithString:stringURL];
// [[UIApplication sharedApplication] openURL:url];
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    static NSString *identifier = @"Annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil)
    {
        annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation 
                                                       reuseIdentifier:identifier] autorelease];
    }
    
    ColorCode code = _note.colorCode;
    NSString *imageName = [NSString stringWithFormat:@"small_thumbnail%d.png", code];
    annotationView.image = [UIImage imageNamed:imageName];
    annotationView.transform = CGAffineTransformMakeRotation(_note.angleRadians);
    return annotationView;
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
            [self disappear];
            
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
    // This line is required; otherwise, after calling dismissModalViewControllerAnimated:
    // the whole editor appears 20 pixels down... weird!
    self.view.frame = CGRectMake(0.0, 20.0, 320.0, 460.0);
    _hidingTransformation = CGAffineTransformMakeTranslation(0.0, 260.0);    
    _toolbar.transform = _hidingTransformation;
    _twitterrifficButtonIndex = -1;
    _locationButtonIndex = -1;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
    _map.delegate = nil;
    [_map release];
    _map = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    _timeStampLabel.text = _note.timeString; 
    _timeStampLabel.font = [UIFont fontWithName:fontNameForCode(_note.fontCode) size:12.0];
    _textView.text = _note.contents;
    _textView.font = [UIFont fontWithName:fontNameForCode(_note.fontCode) size:24.0];
    [_textView becomeFirstResponder];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _toolbar.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Private methods

- (void)disappear
{
    [_textView resignFirstResponder];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    _toolbar.transform = _hidingTransformation;
	[UIView commitAnimations];    
}

@end
