//
//  MNOSoundManager.m
//  Notitas
//
//  Created by Adrian on 9/16/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "MNOSoundManager.h"
#import <AKOLibrary/SynthesizeSingleton.h>
#import <AKOLibrary/SoundEffect.h>

@interface MNOSoundManager ()

@property (nonatomic, strong) SoundEffect *eraseSound;

@end


@implementation MNOSoundManager

SYNTHESIZE_SINGLETON_FOR_CLASS(MNOSoundManager)

@synthesize eraseSound = _eraseSound;

- (id)init
{
    self = [super init];
    if (self) 
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *path = [mainBundle pathForResource:@"Erase" ofType:@"caf"];
        self.eraseSound = [[SoundEffect alloc] initWithContentsOfFile:path];
    }
    return self;
}


#pragma mark - Public methods

- (void)playEraseSound
{
    [self.eraseSound play];
}

@end
