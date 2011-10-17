//
//  MNOTwitterClientManager.h
//  Notitas
//
//  Created by Adrian on 9/11/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MNOTwitterClient;

@interface MNOTwitterClientManager : NSObject

@property (nonatomic, readonly) MNOTwitterClient *currentClient;

+ (MNOTwitterClientManager *)sharedMNOTwitterClientManager;
- (void)send:(NSString *)text;
- (NSArray *)availableClients;
- (BOOL)isAnyClientAvailable;
- (BOOL)canSendMessage;
- (void)setSelectedClientName:(NSString *)name;

@end
