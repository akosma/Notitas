//
//  Note+MNOExtensions.m
//  Notitas
//
//  Created by Adrian on 9/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "Note+MNOExtensions.h"

@implementation Note (MNOExtensions)

@dynamic colorCode;
@dynamic location;
@dynamic angleRadians;
@dynamic fontCode;
@dynamic timeString;
@dynamic position;
@dynamic scale;

@dynamic coordinate;

- (ColorCode)colorCode
{
    return (ColorCode)[self.color intValue];
}

- (CLLocation *)location
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue]
                                                      longitude:[self.longitude doubleValue]];
    return [location autorelease];
}

- (CGFloat)angleRadians
{
    return [self.angle doubleValue];
}

- (void)setAngleRadians:(CGFloat)angleRadians
{
    self.angle = [NSNumber numberWithFloat:angleRadians];
}

- (FontCode)fontCode
{
    return (FontCode)[self.fontFamily intValue];
}

- (NSString *)timeString
{
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
    }
    
    NSString *result = [dateFormatter stringFromDate:self.timeStamp];
    return result;
}

- (CGPoint)position
{
    CGFloat x = [self.xcoord floatValue];
    CGFloat y = [self.ycoord floatValue];
    CGPoint point = CGPointMake(x, y);
    return point;
}

- (void)setPosition:(CGPoint)position
{
    NSNumber *x = [NSNumber numberWithFloat:position.x];
    NSNumber *y = [NSNumber numberWithFloat:position.y];
    self.xcoord = x;
    self.ycoord = y;
}

- (CGFloat)scale
{
    return [self.size floatValue];
}

- (void)setScale:(CGFloat)scale
{
    self.size = [NSNumber numberWithFloat:scale];
}

- (CGRect)frameForWidth:(CGFloat)width
{
    CGPoint position = self.position;
    CGFloat halfWidth = width / 2.0;
    CGRect rect = CGRectMake(position.x - halfWidth, 
                             position.y - halfWidth, width, width);
    return rect;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.latitude doubleValue], 
                                                                   [self.longitude doubleValue]);
    return coordinate;
}

- (NSString *)subtitle
{
    return self.timeString;
}

- (NSString *)title
{
    return self.contents;
}

@end
