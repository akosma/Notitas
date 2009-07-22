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
    IBOutlet UIToolbar *_toolbar;
    IBOutlet RootViewController *_rootController;
}

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, readonly) UIToolbar *toolbar;

+ (NotitasAppDelegate *)sharedDelegate;

- (IBAction)saveAction:sender;

@end

