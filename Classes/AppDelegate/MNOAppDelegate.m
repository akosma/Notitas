//
//  MNOAppDelegate.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "MNOAppDelegate.h"
#import "RootViewController.h"
#import "Appirater.h"
#import "MNOHelpers.h"

@interface MNOAppDelegate ()

@property (nonatomic) CFTimeInterval lastTime;

@end


@implementation MNOAppDelegate

@synthesize window = _window;
@synthesize rootController = _rootController;
@synthesize lastTime = _lastTime;

- (void)dealloc 
{
    [_window release];
    [_rootController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [Appirater appLaunched];
    
    self.window.rootViewController = self.rootController;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    if ([[url scheme] isEqualToString:@"notitas"])
    {
        if ([[url path] isEqualToString:@"/new"])
        {
            NSString *parameter = [url query];
            CFStringRef clean = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, 
                                                                           (CFStringRef)parameter, 
                                                                           CFSTR(""));
            
            [self.rootController createNewNoteWithContents:(NSString *)clean];
            CFRelease(clean);
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[MNOCoreDataManager sharedMNOCoreDataManager] save];
}

@end
