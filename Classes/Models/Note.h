//
//  Note.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Note :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber *angle;
@property (nonatomic, retain) NSDate *timeStamp;
@property (nonatomic, retain) NSString *contents;
@property (nonatomic, retain) NSString *fontFamily;
@property (nonatomic, retain) NSNumber *fontSize;

@end
