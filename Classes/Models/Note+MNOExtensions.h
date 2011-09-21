//
//  Note+MNOExtensions.h
//  Notitas
//
//  Created by Adrian on 9/21/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "Note.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MNOColorCode.h"
#import "MNOFontCode.h"

@interface Note (MNOExtensions) <MKAnnotation>

@property (nonatomic, readonly) MNOColorCode colorCode;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic) CGFloat angleRadians;
@property (nonatomic, readonly) MNOFontCode fontCode;
@property (nonatomic, readonly) NSString *timeString;
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat scale;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (NSString *)subtitle;
- (NSString *)title;

- (CGRect)frameForWidth:(CGFloat)width;

@end
