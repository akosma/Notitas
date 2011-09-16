//
//  NotitasAppDelegate.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright akosma software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface NotitasAppDelegate : NSObject <UIApplicationDelegate,
                                          UIAccelerometerDelegate> 

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootController;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
