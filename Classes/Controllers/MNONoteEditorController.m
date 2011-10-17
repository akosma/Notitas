//
//  MNONoteEditorController.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNONoteEditorController.h"
#import "MNOModels.h"
#import "MNOMapController.h"
#import "MNOHelpers.h"

@interface MNONoteEditorController ()

@property (nonatomic, retain) UIActionSheet *twitterChoiceSheet;
@property (nonatomic) NSInteger twitterrifficButtonIndex;
@property (nonatomic) NSInteger locationButtonIndex;
@property (nonatomic) CGAffineTransform hidingTransformation;
@property (nonatomic, retain) MNOMapController *mapController;
@property (nonatomic, assign) MNOTwitterClientManager *clientManager;

- (void)disappear;
- (void)updateLabel;

@end


@implementation MNONoteEditorController

@synthesize textView = _textView;
@synthesize toolbar = _toolbar;
@synthesize timeStampLabel = _timeStampLabel;
@synthesize note = _note;
@synthesize delegate = _delegate;
@synthesize twitterChoiceSheet = _twitterChoiceSheet;
@synthesize twitterrifficButtonIndex = _twitterrifficButtonIndex;
@synthesize locationButtonIndex = _locationButtonIndex;
@synthesize hidingTransformation = _hidingTransformation;
@synthesize mapController = _mapController;
@synthesize clientManager = _clientManager;

- (void)dealloc 
{
    [_textView release];
    [_toolbar release];
    [_timeStampLabel release];
    [_note release];
    _delegate = nil;
    [_twitterChoiceSheet release];
    _mapController.delegate = nil;
    [_mapController release];
    _clientManager = nil;
    [super dealloc];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    // This line is required; otherwise, after calling dismissModalViewControllerAnimated:
    // the whole editor appears 20 pixels down... weird!
    self.view.frame = CGRectMake(0.0, 20.0, 320.0, 460.0);
    self.hidingTransformation = CGAffineTransformMakeTranslation(0.0, 260.0);    
    self.toolbar.transform = self.hidingTransformation;
    self.twitterrifficButtonIndex = -1;
    self.locationButtonIndex = -1;
    self.clientManager = [MNOTwitterClientManager sharedMNOTwitterClientManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tweetSent:) 
                                                 name:MNOTwitterMessageSent 
                                               object:nil];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
    self.mapController.delegate = nil;
    self.mapController = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    self.timeStampLabel.font = [UIFont fontWithName:fontNameForCode(self.note.fontCode) size:12.0];
    self.textView.text = self.note.contents;
    self.textView.font = [UIFont fontWithName:fontNameForCode(self.note.fontCode) size:24.0];
    [self.textView becomeFirstResponder];
    [self updateLabel];
    
    [UIView animateWithDuration:0.3 
                     animations:^{
                         self.toolbar.transform = CGAffineTransformIdentity;
                     }];
}

#pragma mark - IBAction methods

- (IBAction)changeFont:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MNOChangeFontNotification
                                                        object:self];
    int value = self.note.fontCode + 1;
    value = value % 4;
    self.note.fontFamily = [NSNumber numberWithInt:value];
    self.textView.font = [UIFont fontWithName:fontNameForCode(value) size:24.0];
    self.timeStampLabel.font = [UIFont fontWithName:fontNameForCode(value) size:12.0];
}

- (IBAction)changeColor:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MNOChangeColorNotification 
                                                        object:self];
    int value = self.note.colorCode + 1;
    value = value % 4;
    self.note.color = [NSNumber numberWithInt:value];
}

- (IBAction)done:(id)sender
{
    [self disappear];
    
    self.note.contents = self.textView.text;
    if ([self.delegate respondsToSelector:@selector(noteEditorDidFinishedEditing:)])
    {
        [self.delegate noteEditorDidFinishedEditing:self];
    }
}

- (IBAction)trash:(id)sender
{
    NSString *title = NSLocalizedString(@"ARE_YOU_SURE", @"Title of the 'trash' dialog of the editor controller");
    NSString *message = NSLocalizedString(@"UNDO_POSSIBLE", @"Explanation of the 'trash' dialog of the editor controller");
    NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
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
    self.note.contents = self.textView.text;

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:nil];

    NSString *emailText = NSLocalizedString(@"SEND_VIA_EMAIL", @"Button to send notes via e-mail");
    NSString *twitterrifficText = NSLocalizedString(@"SEND_VIA_TWITTER", @"Button to send notes via Twitter");
    NSString *locationText = NSLocalizedString(@"VIEW_LOCATION", @"Button to view the note location");
    NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
    
    [sheet addButtonWithTitle:emailText];
    NSInteger sheetButtonCount = 1;
    
    if ([self.clientManager isAnyClientAvailable])
    {
        [sheet addButtonWithTitle:twitterrifficText];
        self.twitterrifficButtonIndex = sheetButtonCount;
        sheetButtonCount += 1;
    }    
    
    BOOL locationAvailable = [self.note.hasLocation boolValue];
    if (locationAvailable)
    {
        [sheet addButtonWithTitle:locationText];
        self.locationButtonIndex = sheetButtonCount;
        sheetButtonCount += 1;
    }
    [sheet addButtonWithTitle:cancelText];
    sheet.cancelButtonIndex = sheetButtonCount;
    
    [sheet showInView:self.view];
    [sheet release];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.twitterChoiceSheet)
    {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.clientManager setSelectedClientName:buttonTitle];
        [self.clientManager send:self.note.contents];

        self.twitterChoiceSheet = nil;
    }
    else 
    {
        if (buttonIndex == 0)
        {
            // E-mail
            NSDictionary *dict = [self.note exportAsDictionary];
            NSError *error = nil;
            NSData *data = [NSPropertyListSerialization dataWithPropertyList:dict 
                                                                      format:NSPropertyListXMLFormat_v1_0 
                                                                     options:0
                                                                       error:&error];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.notita", self.note.filename];

            MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
            composer.mailComposeDelegate = self;
            [composer addAttachmentData:data mimeType:@"application/octet-stream" fileName:fileName];

            NSMutableString *message = [[NSMutableString alloc] init];
            if (self.note.contents == nil || [self.note.contents length] == 0)
            {
                NSString *emptyNoteText = NSLocalizedString(@"EMPTY_NOTE", @"To be used when en empty note is sent via e-mail");
                [message appendString:emptyNoteText];
            }
            else
            {
                [message appendString:self.note.contents];
            }
            NSString *sentFromText = NSLocalizedString(@"SENT_BY_NOTITAS", @"Some marketing here");
            [message appendString:sentFromText];
            NSString *subject = NSLocalizedString(@"EMAIL_SUBJECT", @"Title of the e-mail sent by the application");
            [composer setSubject:subject];
            [composer setMessageBody:message isHTML:NO];

            [self disappear];

            [self presentModalViewController:composer animated:YES];
            [composer release];
            [message release];
        }
        else
        {
            if (self.twitterrifficButtonIndex == buttonIndex)
            {
                if ([self.clientManager canSendMessage])
                {
                    // A client is installed and ready to be used!
                    // Let's send a message using it. We don't care which client this is!
                    [self.clientManager send:self.note.contents];
                }
                else 
                {
                    // This path means that a client has been installed in the device,
                    // but the current value in the preferences is "None" or other device not installed.
                    NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
                    self.twitterChoiceSheet = [[[UIActionSheet alloc] initWithTitle:@"Choose a Twitter Client"
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                             destructiveButtonTitle:nil
                                                                  otherButtonTitles:nil] autorelease];
                    NSArray *availableClients = [self.clientManager availableClients];
                    for (NSString *client in availableClients)
                    {
                        [self.twitterChoiceSheet addButtonWithTitle:client];
                    }
                    [self.twitterChoiceSheet addButtonWithTitle:cancelText];
                    self.twitterChoiceSheet.cancelButtonIndex = [availableClients count];
                    [self.twitterChoiceSheet showInView:self.view];
                }
            }
            else if (self.locationButtonIndex == buttonIndex)
            {
                if ([self.note.hasLocation boolValue])
                {
                    if (self.mapController == nil)
                    {
                        self.mapController = [[[MNOMapController alloc] init] autorelease];
                        self.mapController.delegate = self;
                    }
                    self.mapController.note = self.note;
                    
                    [self disappear];
                    [self presentModalViewController:self.mapController animated:YES];
                }
            }
        }
    }
}

#pragma mark - MKMapViewDelegate methods

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
    
    MNOColorCode code = self.note.colorCode;
    NSString *imageName = [NSString stringWithFormat:@"small_thumbnail%d", code];
    annotationView.image = [UIImage imageNamed:imageName];
    annotationView.transform = CGAffineTransformMakeRotation(self.note.angleRadians);
    return annotationView;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateLabel];
}

#pragma mark - UIAlertViewDelegate methods

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
            
            if ([self.delegate respondsToSelector:@selector(noteEditorDidSendNoteToTrash:)])
            {
                [self.delegate noteEditorDidSendNoteToTrash:self];
            }
            break;
        }

        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods
             
- (void)mailComposeController:(MFMailComposeViewController *)composer 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error
{
    [composer dismissModalViewControllerAnimated:YES];
}

#pragma mark - Notification handlers

- (void)tweetSent:(NSNotification *)notification
{
    [self.textView becomeFirstResponder];
}
             
#pragma mark - Private methods

- (void)disappear
{
    [self.textView resignFirstResponder];
    
    [UIView animateWithDuration:0.3 
                     animations:^{
                         self.toolbar.transform = self.hidingTransformation;
                     }];
}

- (void)updateLabel
{
    NSString *characters = NSLocalizedString(@"CHARACTERS_WORD", @"The 'characters' word");
    self.timeStampLabel.text = [NSString stringWithFormat:@"%d %@ - %@", [self.textView.text length], 
                                characters, 
                                self.note.timeString];
}
     
@end
