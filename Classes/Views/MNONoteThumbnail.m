//
//  NoteThumbnail.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNONoteThumbnail.h"
#import "Note.h"

CAGradientLayer *gradientWithColors(UIColor *startColor, UIColor *endColor)
{
    // Adapted from 
    // http://stackoverflow.com/questions/422066/gradients-on-uiview-and-uilabels-on-iphone/1931498#1931498
    
    id start = (id)startColor.CGColor;
    id end = (id)endColor.CGColor;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = [NSArray arrayWithObjects:start, end, nil];
    return gradient;
}


@interface NoteThumbnail ()

@property (nonatomic, retain) CALayer *blueLayer;
@property (nonatomic, retain) CALayer *redLayer;
@property (nonatomic, retain) CALayer *greenLayer;
@property (nonatomic, retain) CALayer *yellowLayer;
@property (nonatomic, assign) CALayer *currentLayer;

- (void)setup;

@end


@implementation NoteThumbnail

@synthesize font = _font;
@synthesize color = _color;
@synthesize summaryLabel = _summaryLabel;
@synthesize blueLayer = _blueLayer;
@synthesize redLayer = _redLayer;
@synthesize greenLayer = _greenLayer;
@synthesize yellowLayer = _yellowLayer;
@synthesize currentLayer = _currentLayer;
@synthesize note = _note;
@synthesize originalTransform = _originalTransform;

#pragma mark -
#pragma mark Constructor and destructor

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGRect rect = CGRectInset(self.bounds, 10.0, 10.0);
    _summaryLabel = [[UILabel alloc] initWithFrame:rect];
    _summaryLabel.backgroundColor = [UIColor clearColor];
    _summaryLabel.numberOfLines = 0;
    [self addSubview:_summaryLabel];
    
    UIColor *lightBlueColor = [UIColor colorWithRed:0.847 green:0.902 blue:0.996 alpha:1.000];
    UIColor *darkBlueColor = [UIColor colorWithRed:0.704 green:0.762 blue:1.000 alpha:1.000];
    UIColor *lightGreenColor = [UIColor colorWithRed:0.664 green:1.000 blue:0.493 alpha:1.000];
    UIColor *darkGreenColor = [UIColor colorWithRed:0.599 green:0.841 blue:0.438 alpha:1.000];
    UIColor *lightRoseColor = [UIColor colorWithRed:1.000 green:0.791 blue:0.923 alpha:1.000];
    UIColor *darkRoseColor = [UIColor colorWithRed:0.999 green:0.673 blue:0.798 alpha:1.000];
    UIColor *lightYellowColor = [UIColor colorWithRed:0.966 green:0.931 blue:0.387 alpha:1.000];
    UIColor *darkYellowColor = [UIColor colorWithRed:0.831 green:0.784 blue:0.382 alpha:1.000];
    
    self.blueLayer = gradientWithColors(lightBlueColor, darkBlueColor);
    self.redLayer = gradientWithColors(lightRoseColor, darkRoseColor);
    self.greenLayer = gradientWithColors(lightGreenColor, darkGreenColor);
    self.yellowLayer = gradientWithColors(lightYellowColor, darkYellowColor);
    
    self.blueLayer.frame = self.bounds;
    self.redLayer.frame = self.bounds;
    self.greenLayer.frame = self.bounds;
    self.yellowLayer.frame = self.bounds;
    
    self.currentLayer = self.yellowLayer;
    [self.layer insertSublayer:self.currentLayer atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeColor:) 
                                                 name:MNOChangeColorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeFont:)
                                                 name:MNOChangeFontNotification
                                               object:nil];
}

- (void)dealloc 
{
    _currentLayer = nil;
    [_note release];
    [_blueLayer release];
    [_greenLayer release];
    [_redLayer release];
    [_yellowLayer release];
    [_summaryLabel release];
    [super dealloc];
}

#pragma mark - Public methods

- (void)layoutSubviews 
{
    self.blueLayer.frame = self.bounds;
    self.redLayer.frame = self.bounds;
    self.greenLayer.frame = self.bounds;
    self.yellowLayer.frame = self.bounds;
}

- (void)refreshDisplay
{
//    CGFloat size = [self.note.size floatValue];
//    CGAffineTransform trans = CGAffineTransformMakeScale(size, size);
    CGAffineTransform trans = CGAffineTransformMakeRotation(self.note.angleRadians);
    self.transform = trans;
    self.color = self.note.colorCode;
    self.font = self.note.fontCode;
    
    // This must come last, so that the size calculation
    // of the label inside the thumbnail is done!
    self.summaryLabel.text = self.note.contents;
    self.center = self.note.position;
}

#pragma mark - Public properties

- (ColorCode)color
{
    return _color;
}

- (void)setColor:(ColorCode)color
{
    if (color != _color)
    {
        _color = color;
        
        [self.currentLayer removeFromSuperlayer];
        switch (_color) 
        {
            case ColorCodeBlue:
            {
                self.currentLayer = self.blueLayer;
                break;
            }
                
            case ColorCodeRed:
            {
                self.currentLayer = self.redLayer; 
                break;
            }
                
            case ColorCodeGreen:
            {
                self.currentLayer = self.greenLayer;
                break;
            }
                
            case ColorCodeYellow:
            {
                self.currentLayer = self.yellowLayer;
                break;
            }
                
            default:
                break;
        }
        
        [self.layer insertSublayer:self.currentLayer 
                           atIndex:0];
    }
}

- (NSString *)text
{
    return _summaryLabel.text;
}

- (void)setText:(NSString *)newText
{
    _summaryLabel.text = newText;
}

- (FontCode)font
{
    return _font;
}

- (void)setFont:(FontCode)newCode
{
    _font = newCode;
    CGFloat size = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 20.0 : 12.0;
    _summaryLabel.font = [UIFont fontWithName:fontNameForCode(_font) 
                                         size:size];
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
