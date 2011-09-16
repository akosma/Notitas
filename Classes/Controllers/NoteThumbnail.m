//
//  NoteThumbnail.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "NoteThumbnail.h"

static CGFloat kMyViewWidth = 300.0f;
static CGFloat kMyViewHeight = 300.0f;

@interface NoteThumbnail ()

@property (nonatomic, retain) UIColor *lightBlueColor;
@property (nonatomic, retain) UIColor *darkBlueColor;
@property (nonatomic, retain) UIColor *lightGreenColor;
@property (nonatomic, retain) UIColor *darkGreenColor;
@property (nonatomic, retain) UIColor *lightRoseColor;
@property (nonatomic, retain) UIColor *darkRoseColor;
@property (nonatomic, retain) UIColor *lightYellowColor;
@property (nonatomic, retain) UIColor *darkYellowColor;

@end


@implementation NoteThumbnail

@dynamic text;
@dynamic font;
@synthesize color = _color;
@synthesize lightBlueColor = _lightBlueColor;
@synthesize darkBlueColor = _darkBlueColor;
@synthesize lightGreenColor = _lightGreenColor;
@synthesize darkGreenColor = _darkGreenColor;
@synthesize lightRoseColor = _lightRoseColor;
@synthesize darkRoseColor = _darkRoseColor;
@synthesize lightYellowColor = _lightYellowColor;
@synthesize darkYellowColor = _darkYellowColor;

#pragma mark -
#pragma mark Constructor and destructor

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        CGRect rect = CGRectMake(22.0, 32.0, frame.size.width - 42.0, frame.size.height - 42.0);
        _summaryLabel = [[UILabel alloc] initWithFrame:rect];
        _summaryLabel.backgroundColor = [UIColor clearColor];
        _summaryLabel.numberOfLines = 0;
        [self addSubview:_summaryLabel];
        
        self.lightBlueColor = [UIColor colorWithRed:0.847 green:0.902 blue:0.996 alpha:1.000];
        self.darkBlueColor = [UIColor colorWithRed:0.704 green:0.762 blue:1.000 alpha:1.000];
        self.lightGreenColor = [UIColor colorWithRed:0.664 green:1.000 blue:0.493 alpha:1.000];
        self.darkGreenColor = [UIColor colorWithRed:0.599 green:0.841 blue:0.438 alpha:1.000];
        self.lightRoseColor = [UIColor colorWithRed:1.000 green:0.791 blue:0.923 alpha:1.000];
        self.darkRoseColor = [UIColor colorWithRed:0.999 green:0.673 blue:0.798 alpha:1.000];
        self.lightYellowColor = [UIColor colorWithRed:0.966 green:0.931 blue:0.387 alpha:1.000];
        self.darkYellowColor = [UIColor colorWithRed:0.831 green:0.784 blue:0.382 alpha:1.000];
        
        self.backgroundColor = [UIColor clearColor];
        
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
    [_lightBlueColor release];
    [_darkBlueColor release];
    [_lightGreenColor release];
    [_darkGreenColor release];
    [_lightRoseColor release];
    [_darkRoseColor release];
    [_lightYellowColor release];
    [_darkYellowColor release];
    [_summaryLabel release];
    [_backgroundView release];
    [super dealloc];
}

- (void)drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0f, 0.0f, kMyViewWidth, kMyViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *color;
	CGFloat resolution;
	CGFloat alignStroke;
	CGMutablePathRef path;
	CGRect drawRect;
	CGGradientRef gradient;
	NSMutableArray *colors;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point;
	CGPoint point2;
	CGAffineTransform transform;
	CGMutablePathRef tempPath;
	CGRect pathBounds;
	CGFloat locations[2];
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Setup for Shadow Effect
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(7.071f * resolution, 7.071f * resolution), 3.0f * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// Layer 1
	
	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(38.0f, 38.0f, 224.0f, 224.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
    
    // Gradient
    switch (_color) 
    {
        case ColorCodeBlue:
        {
            [colors addObject:(id)[self.lightBlueColor CGColor]];
            [colors addObject:(id)[self.darkBlueColor CGColor]];
            break;
        }
            
        case ColorCodeRed:
        {
            [colors addObject:(id)[self.lightRoseColor CGColor]];
            [colors addObject:(id)[self.darkRoseColor CGColor]];
            break;
        }
        
        case ColorCodeGreen:
        {
            [colors addObject:(id)[self.lightGreenColor CGColor]];
            [colors addObject:(id)[self.darkGreenColor CGColor]];
            break;
        }
            
        case ColorCodeYellow:
        {
            [colors addObject:(id)[self.lightYellowColor CGColor]];
            [colors addObject:(id)[self.darkYellowColor CGColor]];
            break;
        }

        default:
            break;
    }
    
	locations[0] = 0.0f;
	locations[1] = 1.0f;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(-1.047f);
	tempPath = CGPathCreateMutable();
	CGPathAddPath(tempPath, &transform, path);
	pathBounds = CGPathGetPathBoundingBox(tempPath);
	point = pathBounds.origin;
	point2 = CGPointMake(CGRectGetMaxX(pathBounds), CGRectGetMinY(pathBounds));
	transform = CGAffineTransformInvert(transform);
	point = CGPointApplyAffineTransform(point, transform);
	point2 = CGPointApplyAffineTransform(point2, transform);
	CGPathRelease(tempPath);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	CGPathRelease(path);
	
	// Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

#pragma mark - Public properties

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
    [self setNeedsDisplay];
}

@end
