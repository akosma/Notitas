//
//  MNOBoard.h
//  Notitas
//
//  Created by Adrian on 9/24/11.
//  Copyright (c) 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface MNOBoard : NSManagedObject 

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSDate * lastModificationTime;
@property (nonatomic, retain) NSSet *notes;

@end

@interface MNOBoard (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;
@end
