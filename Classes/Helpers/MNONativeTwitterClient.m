//
//  MNONativeTwitterClient.m
//  Notitas
//
//  Created by Adrian Kosmaczewski on 10/17/11.
//  Copyright (c) 2011 akosma software. All rights reserved.
//

#import "MNONativeTwitterClient.h"
#import "MNONotifications.h"

@implementation MNONativeTwitterClient

- (id)init
{
    self = [super init];
    if (self)
    {
        self.name = @"Notitas";
    }
    return self;
}

- (BOOL)isAvailable
{
    Class klass = NSClassFromString(@"TWTweetComposeViewController");
    return (klass != nil);
}

- (BOOL)canSendMessage
{
    return [TWTweetComposeViewController canSendTweet];
}

- (void)send:(NSString *)text
{
    if (self.canSendMessage)
    {
        TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
        __weak TWTweetComposeViewController *weakController = controller;
        [controller setInitialText:text];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            // When running on an iPhone or iPod touch, 
            // the editor should regain its focus
            // when the tweet is finally sent
            [controller setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
                [weakController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:MNOTwitterMessageSent object:nil];
            }];
        }
        
        // This is a hack. Awful. But it works :)
        id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
        UIViewController *rootController = [appDelegate performSelector:@selector(rootController)];
        [rootController presentViewController:controller animated:YES completion:nil];
    }
}

@end
