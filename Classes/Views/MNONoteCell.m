//
//  MNONoteCell.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNONoteCell.h"
#import "MNOModels.h"
#import "MNONoteThumbnail.h"
#import "MNOHelpers.h"

@interface MNONoteCell ()
{
    @private
    Note *_note;
    MNONoteThumbnail *_thumbnail;
}

@property (nonatomic, strong) MNONoteThumbnail *thumbnail;

@end


@implementation MNONoteCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.thumbnail = [[MNONoteThumbnail alloc] initWithFrame:self.bounds];
        [self.thumbnail mno_addShadow];
        [self.contentView addSubview:self.thumbnail];

        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Public properties

- (Note *)note
{
    return _note;
}

- (void)setNote:(Note *)newNote
{
    if (newNote != _note)
    {
        _note = newNote;
    }
    if (_note == nil)
    {
        self.thumbnail.hidden = YES;
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(_note.angleRadians);
        self.thumbnail.transform = trans;
        self.thumbnail.color = _note.colorCode;
        self.thumbnail.font = _note.fontCode;
        
        // This must come last, so that the size calculation
        // of the label inside the thumbnail is done!
        self.thumbnail.summaryLabel.text = _note.contents;
        self.thumbnail.hidden = NO;
    }
}

@end
