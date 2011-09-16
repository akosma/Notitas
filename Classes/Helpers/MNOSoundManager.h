//
//  MNOSoundManager.h
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNOSoundManager : NSObject

+ (id)sharedMNOSoundManager;

- (void)playEraseSound;

@end
