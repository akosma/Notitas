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

@property (nonatomic, retain) MNONoteThumbnail *leftView;
@property (nonatomic, retain) MNONoteThumbnail *rightView;
@property (nonatomic) CGRect leftFrame;
@property (nonatomic) CGRect rightFrame;

@end


@implementation MNONoteCell

@synthesize leftNote = _leftNote;
@synthesize rightNote = _rightNote;
@synthesize delegate = _delegate;
@synthesize leftView = _leftView;
@synthesize rightView = _rightView;
@synthesize leftFrame = _leftFrame;
@synthesize rightFrame = _rightFrame;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _leftFrame = CGRectMake(20.0, 20.0, 130.0, 130.0);
        _leftView = [[MNONoteThumbnail alloc] initWithFrame:_leftFrame];
        _leftView.hidden = YES;
        [_leftView mno_addShadow];
        [self.contentView addSubview:_leftView];

        _rightFrame = CGRectMake(170.0, 20.0, 130.0, 130.0);
        _rightView = [[MNONoteThumbnail alloc] initWithFrame:_rightFrame];
        _rightView.hidden = YES;
        [_rightView mno_addShadow];
        [self.contentView addSubview:_rightView];
        
        self.contentView.backgroundColor = [UIColor clearColor];
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

#pragma mark - Public properties

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
        self.leftView.hidden = YES;
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(_leftNote.angleRadians);
        self.leftView.transform = trans;
        self.leftView.color = _leftNote.colorCode;
        self.leftView.font = _leftNote.fontCode;
        
        // This must come last, so that the size calculation
        // of the label inside the thumbnail is done!
        self.leftView.summaryLabel.text = _leftNote.contents;
        self.leftView.hidden = NO;
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
        self.rightView.hidden = YES;
    }
    else
    {
        CGAffineTransform trans = CGAffineTransformMakeRotation(_rightNote.angleRadians);
        self.rightView.transform = trans;
        self.rightView.color = _rightNote.colorCode;
        self.rightView.font = _rightNote.fontCode;

        // This must come last, so that the size calculation
        // of the label inside the thumbnail is done!
        self.rightView.summaryLabel.text = _rightNote.contents;
        self.rightView.hidden = NO;
    }
}

#pragma mark - Touch management

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (location.x > 170)
    {
        // Touch on the right side, only if the view is visible
        if (!self.rightView.hidden && [self.delegate respondsToSelector:@selector(noteCell:didSelectNote:atFrame:)])
        {
            [self.delegate noteCell:self didSelectNote:self.rightNote atFrame:self.rightFrame];
        }
    }
    else if (location.x < 150)
    {
        // Touch on the left side
        if ([self.delegate respondsToSelector:@selector(noteCell:didSelectNote:atFrame:)])
        {
            [self.delegate noteCell:self didSelectNote:self.leftNote atFrame:self.leftFrame];
        }
    }
}

@end
