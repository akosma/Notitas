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

@property (nonatomic, strong) NSNumber * angle;
@property (nonatomic, strong) NSNumber * color;
@property (nonatomic, strong) NSString * contents;
@property (nonatomic, strong) NSNumber * fontFamily;
@property (nonatomic, strong) NSNumber * fontSize;
@property (nonatomic, strong) NSNumber * hasLocation;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * size;
@property (nonatomic, strong) NSDate * timeStamp;
@property (nonatomic, strong) NSNumber * xcoord;
@property (nonatomic, strong) NSNumber * ycoord;
@property (nonatomic, strong) NSDate * lastModificationTime;
@property (nonatomic, strong) MNOBoard *board;

@end
