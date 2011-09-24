//
//  Note.h
//  Notitas
//
//  Created by Adrian on 9/24/11.
//  Copyright (c) 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MNOBoard;

@interface Note : NSManagedObject 

@property (nonatomic, retain) NSNumber * angle;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSString * contents;
@property (nonatomic, retain) NSNumber * fontFamily;
@property (nonatomic, retain) NSNumber * fontSize;
@property (nonatomic, retain) NSNumber * hasLocation;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * xcoord;
@property (nonatomic, retain) NSNumber * ycoord;
@property (nonatomic, retain) NSDate * lastModificationTime;
@property (nonatomic, retain) MNOBoard *board;

@end
