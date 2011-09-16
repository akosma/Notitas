//
//  NotitasAppDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKOLibrary/SoundEffect.h>

@class RootViewController;

@interface NotitasAppDelegate : NSObject <UIApplicationDelegate,
                                          UIAccelerometerDelegate> 
{
@private
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;	    
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;

    IBOutlet UIWindow *_window;
    IBOutlet UIToolbar *_toolbar;
    IBOutlet RootViewController *_rootController;

	CFTimeInterval _lastTime;
    SoundEffect *_eraseSound;
    
    BOOL _networkConnectivityAvailable;
}

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, readonly) UIToolbar *toolbar;
@property (nonatomic, readonly) BOOL networkConnectivityAvailable;

+ (NotitasAppDelegate *)sharedDelegate;

- (IBAction)saveAction:sender;
- (void)playEraseSound;

@end

