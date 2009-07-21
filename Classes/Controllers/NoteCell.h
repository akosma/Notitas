//
//  NoteCell.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteCellDelegate.h"

@class Note;
@class NoteThumbnail;

@interface NoteCell : UITableViewCell 
{
@private
    Note *_leftNote;
    Note *_rightNote;
    
    NoteThumbnail *_leftView;
    NoteThumbnail *_rightView;
    
    id<NoteCellDelegate> _delegate;
    
    CGRect _leftFrame;
    CGRect _rightFrame;
}

@property (nonatomic, retain) Note *leftNote;
@property (nonatomic, retain) Note *rightNote;
@property (nonatomic, assign) id<NoteCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
