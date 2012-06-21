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

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSDate * creationTime;
@property (nonatomic, strong) NSDate * lastModificationTime;
@property (nonatomic, strong) NSSet *notes;

@end

@interface MNOBoard (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;
@end
