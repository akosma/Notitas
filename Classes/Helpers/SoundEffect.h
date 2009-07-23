//
//  SoundEffect.h
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>

@interface SoundEffect : NSObject 
{
@private
    SystemSoundID _soundID;
}

- (id)initWithContentsOfFile:(NSString *)path;
- (void)play;

@end
