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

@property (nonatomic) NSInteger twitterButtonIndex;
@property (nonatomic) NSInteger facebookButtonIndex;
@property (nonatomic) NSInteger locationButtonIndex;
@property (nonatomic, strong) MNOMapController *mapController;

- (void)updateLabel;

@end


@implementation MNONoteEditorController

#pragma mark - UIViewController methods

- (void)viewDidLoad 
{
    self.textView.inputAccessoryView = self.inputAccessoryView;
    self.twitterButtonIndex = -1;
    self.locationButtonIndex = -1;
    self.facebookButtonIndex = -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.timeStampLabel.font = [UIFont fontWithName:fontNameForCode(self.note.fontCode) size:12.0];
    self.textView.text = self.note.contents;
    self.textView.font = [UIFont fontWithName:fontNameForCode(self.note.fontCode) size:24.0];
    [self updateLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

#pragma mark - IBAction methods

- (IBAction)changeFont:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MNOChangeFontNotification
                                                        object:self];
    int value = self.note.fontCode + 1;
    value = value % 4;
    self.note.fontFamily = @(value);
    self.textView.font = [UIFont fontWithName:fontNameForCode(value) size:24.0];
    self.timeStampLabel.font = [UIFont fontWithName:fontNameForCode(value) size:12.0];
}

- (IBAction)changeColor:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MNOChangeColorNotification 
                                                        object:self];
    int value = self.note.colorCode + 1;
    value = value % 4;
    self.note.color = @(value);
}

- (IBAction)done:(id)sender
{
    [self.textView resignFirstResponder];
    
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
    NSString *twitterText = NSLocalizedString(@"SEND_VIA_TWITTER", @"Button to send notes via Twitter");
    NSString *facebookText = NSLocalizedString(@"SEND_VIA_FACEBOOK", @"Button to send notes via Facebook");
    NSString *locationText = NSLocalizedString(@"VIEW_LOCATION", @"Button to view the note location");
    NSString *cancelText = NSLocalizedString(@"CANCEL", @"The 'cancel' word");
    
    [sheet addButtonWithTitle:emailText];
    NSInteger sheetButtonCount = 1;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [sheet addButtonWithTitle:twitterText];
        self.twitterButtonIndex = sheetButtonCount;
        sheetButtonCount += 1;
    }    

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        [sheet addButtonWithTitle:facebookText];
        self.facebookButtonIndex = sheetButtonCount;
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
    
    [sheet showInView:self.parentViewController.view];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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

        [self presentViewController:composer
                           animated:YES
                         completion:nil];
    }
    else
    {
        if (self.twitterButtonIndex == buttonIndex)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [controller setInitialText:self.note.contents];
                [controller setCompletionHandler:^(SLComposeViewControllerResult result){
                    [self.textView becomeFirstResponder];
                }];
                [self presentViewController:controller
                                   animated:YES
                                 completion:nil];
            }
        }
        else if (self.facebookButtonIndex == buttonIndex)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [controller setInitialText:self.note.contents];
                [controller setCompletionHandler:^(SLComposeViewControllerResult result){
                    [self.textView becomeFirstResponder];
                }];
                [self presentViewController:controller
                                   animated:YES
                                 completion:nil];
            }
        }
        else if (self.locationButtonIndex == buttonIndex)
        {
            if ([self.note.hasLocation boolValue])
            {
                if (self.mapController == nil)
                {
                    self.mapController = [[MNOMapController alloc] init];
                    self.mapController.delegate = self;
                }
                self.mapController.note = self.note;
                
                [self.textView resignFirstResponder];
                [self presentViewController:self.mapController
                                   animated:YES
                                 completion:nil];
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
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation 
                                                       reuseIdentifier:identifier];
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
            [self.textView resignFirstResponder];
            
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
    [composer dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)updateLabel
{
    NSString *characters = NSLocalizedString(@"CHARACTERS_WORD", @"The 'characters' word");
    self.timeStampLabel.text = [NSString stringWithFormat:@"%d %@ - %@", [self.textView.text length], 
                                characters, 
                                self.note.timeString];
}
     
@end
