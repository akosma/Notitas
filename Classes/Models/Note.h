//
//  Note.h
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "ColorCode.h"
#import "FontCode.h"

@interface Note :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * angle;
@property (nonatomic, retain) NSNumber * fontSize;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * contents;
@property (nonatomic, retain) NSNumber * fontFamily;
@property (nonatomic, retain) NSNumber * hasLocation;

@property (nonatomic, readonly) ColorCode colorCode;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) double angleRadians;
@property (nonatomic, readonly) FontCode fontCode;

@end
