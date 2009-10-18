//
//  NoteThumbnail.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "NoteThumbnail.h"

@implementation NoteThumbnail

@dynamic text;
@dynamic color;
@dynamic font;

#pragma mark -
#pragma mark Constructor and destructor

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        CGRect rect = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        _backgroundView = [[UIImageView alloc] initWithFrame:rect];
        _backgroundView.image = [UIImage imageNamed:@"thumbnail0.png"];
        
        [self addSubview:_backgroundView];
        
        rect = CGRectMake(22.0, 32.0, frame.size.width - 42.0, frame.size.height - 42.0);
        _summaryLabel = [[UILabel alloc] initWithFrame:rect];
        _summaryLabel.backgroundColor = [UIColor clearColor];
        _summaryLabel.numberOfLines = 0;
        
        [self addSubview:_summaryLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeColor:) 
                                                     name:@"ChangeColorNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeFont:)
                                                     name:@"ChangeFontNotification"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc 
{
    [_summaryLabel release];
    [_backgroundView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public properties

- (NSString *)text
{
    return _summaryLabel.text;
}

- (void)setText:(NSString *)newText
{
    CGFloat width = _summaryLabel.frame.size.width;
    CGSize constraints = CGSizeMake(width, 90.0);
    CGSize size = [newText sizeWithFont:_summaryLabel.font constrainedToSize:constraints];
    _summaryLabel.frame = CGRectMake(22.0, 32.0, width, size.height);
    _summaryLabel.text = newText;
}

- (ColorCode)color
{
    return _color;
}

- (void)setColor:(ColorCode)newColor
{
    _color = newColor;
    NSString *imageName = [NSString stringWithFormat:@"thumbnail%d.png", (int)_color];
    _backgroundView.image = [UIImage imageNamed:imageName];
}

- (FontCode)font
{
    return _font;
}

- (void)setFont:(FontCode)newCode
{
    _font = newCode;
    _summaryLabel.font = [UIFont fontWithName:fontNameForCode(_font) size:12.0];
}

#pragma mark -
#pragma mark NSNotification handler

- (void)changeFont:(NSNotification *)notification
{
    int value = (int)_font + 1;
    FontCode newColor = (FontCode)(value % 4);
    [self setFont:newColor];
}

- (void)changeColor:(NSNotification *)notification
{
    int value = (int)_color + 1;
    ColorCode newColor = (ColorCode)(value % 4);
    [self setColor:newColor];
}

@end
