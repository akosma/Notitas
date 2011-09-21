//
//  MNONoteEditorControllerDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNONoteEditorController;

@protocol MNONoteEditorControllerDelegate <NSObject>

@required
- (void)noteEditorDidFinishedEditing:(MNONoteEditorController *)editor;
- (void)noteEditorDidSendNoteToTrash:(MNONoteEditorController *)editor;

@end
