//
//  NotitasAppDelegate.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "NotitasAppDelegate.h"
#import "RootViewController.h"
#import "Appirater.h"
#import "MNOHelpers.h"

@interface NotitasAppDelegate ()

@property (nonatomic) CFTimeInterval lastTime;

@end


@implementation NotitasAppDelegate

@synthesize window = _window;
@synthesize rootController = _rootController;
@synthesize toolbar = _toolbar;
@synthesize lastTime = _lastTime;

- (void)dealloc 
{
    [_window release];
    [_rootController release];
    [_toolbar release];
	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [Appirater appLaunched];
    
    self.toolbar.frame = CGRectMake(0.0, 436.0, 320.0, 44.0);
    self.window.rootViewController = self.rootController;
    [self.window addSubview:self.toolbar];
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

@end
