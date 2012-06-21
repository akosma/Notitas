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

@property (nonatomic, strong) Note *leftNote;
@property (nonatomic, strong) Note *rightNote;
@property (nonatomic, weak) id<MNONoteCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
