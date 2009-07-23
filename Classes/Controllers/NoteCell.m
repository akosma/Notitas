//
//  NoteCell.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "NoteCell.h"
#import "Note.h"
#import "NoteThumbnail.h"
#import "ColorCode.h"

@implementation NoteCell

@dynamic leftNote;
@dynamic rightNote;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Constructor and destructor

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _leftFrame = CGRectMake(20.0, 10.0, 130.0, 130.0);
        _leftView = [[NoteThumbnail alloc] initWithFrame:_leftFrame];
        _leftView.hidden = YES;
        [self.contentView addSubview:_leftView];

        _rightFrame = CGRectMake(170.0, 10.0, 130.0, 130.0);
        _rightView = [[NoteThumbnail alloc] initWithFrame:_rightFrame];
        _rightView.hidden = YES;
        [self.contentView addSubview:_rightView];
    }
    return self;
}

- (void)dealloc 
{
    _delegate = nil;
    [_leftNote release];
    [_rightNote release];
    [_leftView release];
    [_rightView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public properties

- (Note *)leftNote
{
    return _leftNote;
}

- (void)setLeftNote:(Note *)newNote
{
    if (newNote != _leftNote)
    {
        [_leftNote release];
        _leftNote = [newNote retain];
    }
    if (_leftNote == nil)
    {
        _leftView.hidden = YES;
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(_leftNote.angleRadians);
        _leftView.transform = trans;
        _leftView.text = _leftNote.contents;
        _leftView.color = _leftNote.colorCode;
        _leftView.hidden = NO;
    }
}

- (Note *)rightNote
{
    return _rightNote;
}

- (void)setRightNote:(Note *)newNote
{
    if (newNote != _rightNote)
    {
        [_rightNote release];
        _rightNote = [newNote retain];
    }
    if (_rightNote == nil)
    {
        _rightView.hidden = YES;
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(_rightNote.angleRadians);
        _rightView.transform = trans;
        _rightView.text = _rightNote.contents;
        _rightView.color = _rightNote.colorCode;
        _rightView.hidden = NO;
    }
}

#pragma mark -
#pragma mark Touch management

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (location.x > 170)
    {
        // Touch on the right side, only if the view is visible
        if (!_rightView.hidden && [_delegate respondsToSelector:@selector(noteCell:didSelectNote:atFrame:)])
        {
            [_delegate noteCell:self didSelectNote:_rightNote atFrame:_rightFrame];
        }
    }
    else if (location.x < 150)
    {
        // Touch on the left side
        if ([_delegate respondsToSelector:@selector(noteCell:didSelectNote:atFrame:)])
        {
            [_delegate noteCell:self didSelectNote:_leftNote atFrame:_leftFrame];
        }
    }
}

@end
