//
//  MNOTwitterClient.h
//  Notitas
//
//  Created by Adrian on 9/11/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNOTwitterClient : NSObject 

@property (nonatomic, readonly) NSString *urlTemplate;
@property (nonatomic, copy) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)isAvailable;
- (BOOL)canSendMessage;
- (void)send:(NSString *)text;

@end
