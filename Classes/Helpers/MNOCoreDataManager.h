//
//  MNOCoreDataManager.h
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AKOLibrary/AKOLibrary.h>
#import <AKOLibrary/SynthesizeSingleton.h>

@class Note;


@interface MNOCoreDataManager : AKOCoreDataManager

@property (nonatomic, readonly) NSUndoManager *undoManager;


+ (id)sharedMNOCoreDataManager;

- (NSFetchedResultsController *)createFetchedResultsController;
- (Note *)createNote;
- (void)shakeNotes;
- (void)beginUndoGrouping;
- (void)endUndoGrouping;
- (NSArray *)allNotes;
- (void)createNoteFromDictionary:(NSDictionary *)dict;

@end
