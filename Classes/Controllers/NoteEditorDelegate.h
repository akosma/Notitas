//
//  NoteEditorDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteEditor;

@protocol NoteEditorDelegate <NSObject>

@required
- (void)noteEditorDidFinishedEditing:(NoteEditor *)editor;
- (void)noteEditorDidSendNoteToTrash:(NoteEditor *)editor;

@end
