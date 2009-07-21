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

#pragma mark -
#pragma mark Constructor and destructor

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        CGRect rect = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        _backgroundView = [[UIImageView alloc] initWithFrame:rect];
        _backgroundView.image = [UIImage imageNamed:@"thumbnail.png"];
        
        [self addSubview:_backgroundView];
        
        rect = CGRectMake(15.0, 20.0, frame.size.width - 25.0, frame.size.height - 35.0);
        _summaryLabel = [[UILabel alloc] initWithFrame:rect];
        _summaryLabel.backgroundColor = [UIColor clearColor];
        _summaryLabel.numberOfLines = 0;
        _summaryLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        
        [self addSubview:_summaryLabel];
    }
    return self;
}

- (void)dealloc 
{
    [_summaryLabel release];
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
    CGSize constraints = CGSizeMake(width, self.frame.size.height - 45.0);
    CGSize size = [newText sizeWithFont:_summaryLabel.font constrainedToSize:constraints];
    _summaryLabel.frame = CGRectMake(15.0, 20.0, width, size.height);
    _summaryLabel.text = newText;
}

@end
