//
//  SoundEffect.m
//  Notitas
//
//  Created by Adrian on 7/22/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "SoundEffect.h"

@implementation SoundEffect

- (id)initWithContentsOfFile:(NSString *)path 
{
    self = [super init];
    
    if (self != nil) 
    {
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
        if (aFileURL != nil)  
        {
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
            
            if (error == kAudioServicesNoError) 
            {
                _soundID = aSoundID;
            } 
            else 
            {
                [self release], self = nil;
            }
        } 
        else 
        {
            [self release], self = nil;
        }
    }
    return self;
}

- (void)dealloc 
{
    AudioServicesDisposeSystemSoundID(_soundID);
    [super dealloc];
}

- (void)play 
{
    AudioServicesPlaySystemSound(_soundID);
}

@end
