// 
//  Note.m
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "Note.h"

@implementation Note 

@dynamic angle;
@dynamic fontSize;
@dynamic longitude;
@dynamic color;
@dynamic timeStamp;
@dynamic latitude;
@dynamic contents;
@dynamic fontFamily;
@dynamic hasLocation;

@dynamic colorCode;
@dynamic location;
@dynamic angleRadians;
@dynamic fontCode;
@dynamic timeString;

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

- (double)angleRadians
{
    return [self.angle doubleValue];
}

- (FontCode)fontCode
{
    return (FontCode)[self.fontFamily intValue];
}

- (NSString *)timeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSString *result = [dateFormatter stringFromDate:self.timeStamp];
    [dateFormatter release];
    return result;
}

@end
