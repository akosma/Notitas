//
//  MNONoteCell.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNONoteCellDelegate.h"

@class Note;

@interface MNONoteCell : UITableViewCell 

@property (nonatomic, retain) Note *leftNote;
@property (nonatomic, retain) Note *rightNote;
@property (nonatomic, assign) id<MNONoteCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
