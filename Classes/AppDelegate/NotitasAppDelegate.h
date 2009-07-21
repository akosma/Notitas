//
//  NotitasAppDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

@class RootViewController;

@interface NotitasAppDelegate : NSObject <UIApplicationDelegate> 
{
@private
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;	    
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;

    IBOutlet UIWindow *_window;

    RootViewController *_rootController;
    UINavigationController *_navController;
}

+ (NotitasAppDelegate *)sharedDelegate;

- (IBAction)saveAction:sender;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end

