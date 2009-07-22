//
//  NotitasAppDelegate.m
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import "NotitasAppDelegate.h"
#import "RootViewController.h"
#import "SoundEffect.h"

#define kAccelerometerFrequency			25 //Hz
#define kFilteringFactor				0.1
#define kMinEraseInterval				0.5
#define kEraseAccelerationThreshold		2.0

@interface NotitasAppDelegate (Private)
- (NSManagedObjectContext *)managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
@end

@implementation NotitasAppDelegate

@synthesize toolbar = _toolbar;

+ (NotitasAppDelegate *)sharedDelegate
{
    return (NotitasAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)dealloc 
{
    [_toolbar release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_rootController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	_rootController.managedObjectContext = [self managedObjectContext];
    _toolbar.frame = CGRectMake(0.0, 436.0, 320.0, 44.0);

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    NSBundle *mainBundle = [NSBundle mainBundle];	
    _eraseSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
    
	[_window addSubview:_rootController.view];
    [_window addSubview:_toolbar];
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    NSError *error;
    if (_managedObjectContext != nil) 
    {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) 
        {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

#pragma mark -
#pragma mark Public methods

- (IBAction)saveAction:(id)sender 
{
    NSError *error;
    if (![[self managedObjectContext] save:&error]) 
    {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}

- (void)playEraseSound
{
    [_eraseSound play];
}

#pragma mark -
#pragma mark UIAccelerometerDelegate method

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	UIAccelerationValue length, x, y, z;

    UIAccelerationValue	myAccelerometer[3];

	//Use a basic high-pass filter to remove the influence of the gravity
	myAccelerometer[0] = acceleration.x * kFilteringFactor + myAccelerometer[0] * (1.0 - kFilteringFactor);
	myAccelerometer[1] = acceleration.y * kFilteringFactor + myAccelerometer[1] * (1.0 - kFilteringFactor);
	myAccelerometer[2] = acceleration.z * kFilteringFactor + myAccelerometer[2] * (1.0 - kFilteringFactor);

	// Compute values for the three axes of the acceleromater
	x = acceleration.x - myAccelerometer[0];
	y = acceleration.y - myAccelerometer[0];
	z = acceleration.z - myAccelerometer[0];

	//Compute the intensity of the current acceleration 
	length = sqrt(x * x + y * y + z * z);

    // If above a given threshold, change the angles of the items on the cardboard
	if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > _lastTime + kMinEraseInterval)) 
    {
		_lastTime = CFAbsoluteTimeGetCurrent();
        [_rootController shakeNotes:self];
	}
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) 
    {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) 
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setUndoManager:nil];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) 
    {
        return _managedObjectModel;
    }
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) 
    {
        return _persistentStoreCoordinator;
    }
	
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Notitas.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	
	NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                   configuration:nil 
                                                             URL:storeUrl 
                                                         options:nil 
                                                           error:&error]) 
    {
        // Handle error
    }    
	
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory

- (NSString *)applicationDocumentsDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
