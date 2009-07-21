//
//  NoteCellDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteCell;
@class Note;

@protocol NoteCellDelegate <NSObject>

@required
- (void)noteCell:(NoteCell *)cell didSelectNote:(Note *)note atFrame:(CGRect)frame;

@end
