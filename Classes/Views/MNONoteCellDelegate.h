//
//  MNONoteCellDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNONoteCell;
@class Note;

@protocol MNONoteCellDelegate <NSObject>

@required
- (void)noteCell:(MNONoteCell *)cell didSelectNote:(Note *)note atFrame:(CGRect)frame;

@end
