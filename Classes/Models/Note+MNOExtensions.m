//
//  Note+MNOExtensions.m
//  Notitas
//
//  Created by Adrian on 9/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "Note+MNOExtensions.h"

static NSString *ANGLE_KEY = @"angle";
static NSString *COLOR_KEY = @"color";
static NSString *CONTENTS_KEY = @"contents";
static NSString *FONT_FAMILY_KEY = @"fontFamily";
static NSString *FONT_SIZE_KEY = @"fontSize";
static NSString *HAS_LOCATION_KEY = @"hasLocation";
static NSString *LATITUDE_KEY = @"latitude";
static NSString *LONGITUDE_KEY = @"longitude";
static NSString *SIZE_KEY = @"size";
static NSString *X_COORD_KEY = @"xcoord";
static NSString *Y_COORD_KEY = @"ycoord";
static NSInteger FILENAME_LENGTH = 15;

@implementation Note (MNOExtensions)

@dynamic colorCode;
@dynamic location;
@dynamic angleRadians;
@dynamic fontCode;
@dynamic timeString;
@dynamic position;
@dynamic scale;
@dynamic filename;

@dynamic coordinate;

#pragma mark - Properties

- (MNOColorCode)colorCode
{
    return (MNOColorCode)[self.color intValue];
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

- (MNOFontCode)fontCode
{
    return (MNOFontCode)[self.fontFamily intValue];
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

- (NSString *)filename
{
    NSString *filename = [self.contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    filename = [filename stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([filename length] == 0)
    {
        filename = @"Notita";
    }
    else if ([filename length] > FILENAME_LENGTH)
    {
        filename = [filename substringToIndex:FILENAME_LENGTH];
    }
    return [filename stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - MKAnnotation protocol

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
    return self.filename;
}

#pragma mark - Public methods

- (CGRect)frameForWidth:(CGFloat)width
{
    CGPoint position = self.position;
    CGFloat halfWidth = width / 2.0;
    CGRect rect = CGRectMake(position.x - halfWidth, 
                             position.y - halfWidth, width, width);
    return rect;
}

- (NSDictionary *)exportAsDictionary
{
    NSArray *keys = [NSArray arrayWithObjects:ANGLE_KEY, COLOR_KEY, CONTENTS_KEY, 
                     FONT_FAMILY_KEY, FONT_SIZE_KEY, HAS_LOCATION_KEY, LATITUDE_KEY, 
                     LONGITUDE_KEY, SIZE_KEY, X_COORD_KEY, Y_COORD_KEY, nil];
    NSDictionary *export = [self dictionaryWithValuesForKeys:keys];
    return export;
}

- (void)importDataFromDictionary:(NSDictionary *)dict
{
    [self setValuesForKeysWithDictionary:dict];
}

@end
