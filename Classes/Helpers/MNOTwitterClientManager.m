//
//  MNOTwitterClientManager.m
//  Notitas
//
//  Created by Adrian on 9/11/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNOTwitterClientManager.h"
#import "MNOTwitterClient.h"
#import "MNONativeTwitterClient.h"
#import <AKOLibrary/SynthesizeSingleton.h>

static NSString *TWITTER_CLIENT_KEY = @"TwitterClient";
static NSString *TWITTER_CLIENT_CODE_NONE = @"None";
static NSString *TWITTER_CLIENT_CODE_NATIVE = @"Notitas";

@interface MNOTwitterClientManager ()

@property (nonatomic, strong) NSMutableDictionary *clients;
@property (nonatomic, readonly) BOOL canSendTweet;

- (void)initializeClients;

@end


@implementation MNOTwitterClientManager

@dynamic currentClient;
@dynamic canSendTweet;

SYNTHESIZE_SINGLETON_FOR_CLASS(MNOTwitterClientManager)

- (id)init
{
    if (self = [super init])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *value = [defaults stringForKey:TWITTER_CLIENT_KEY];
        if (value == nil)
        {
            [defaults setObject:TWITTER_CLIENT_CODE_NONE forKey:TWITTER_CLIENT_KEY];
        }

        [self initializeClients];
    }
    return self;
}


#pragma mark - Public methods

- (NSArray *)supportedClients
{
    NSArray *clients = [self.clients allValues];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (MNOTwitterClient *client in clients)
    {
        if (client.name != nil)
        {
            [returnArray addObject:client];
        }
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *descriptors = [[NSArray alloc] initWithObjects:descriptor, nil];
    [returnArray sortUsingDescriptors:descriptors];
    return returnArray;
}

- (NSArray *)availableClients
{
    NSMutableArray *availableClients = [[NSMutableArray alloc] init];
    for (NSString *clientName in self.clients)
    {
        MNOTwitterClient *client = (self.clients)[clientName];
        if ([client isAvailable])
        {
            [availableClients addObject:client.name];
        }
    }
    return availableClients;
}

- (BOOL)isAnyClientAvailable
{
    NSArray *clients = [self availableClients];
    return [clients count] > 0;
}

- (BOOL)canSendMessage
{
    return [self.currentClient isAvailable] && [self.currentClient canSendMessage];
}

- (void)send:(NSString *)text
{
    [self.currentClient send:text];
}

- (void)setSelectedClientName:(NSString *)name
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:TWITTER_CLIENT_KEY];
    [defaults synchronize];
}

- (MNOTwitterClient *)currentClient
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [defaults objectForKey:TWITTER_CLIENT_KEY];
    return (self.clients)[name];
}

#pragma mark - Private methods

- (void)initializeClients
{
    // Load Twitter clients from the TwitterClients.plist file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TwitterClients" ofType:@"plist"];
    NSArray *clients = [NSArray arrayWithContentsOfFile:path];

    // Populate the array with the clients
    self.clients = [NSMutableDictionary dictionary];
    MNOTwitterClient *none = [[MNOTwitterClient alloc] init];
    (self.clients)[TWITTER_CLIENT_CODE_NONE] = none;
    
    for (NSDictionary *dict in clients)
    {
        NSString *name = dict[@"name"];
        MNOTwitterClient *client = [[MNOTwitterClient alloc] initWithDictionary:dict];
        (self.clients)[name] = client;
    }
    
    // If possible, we should be able to send tweets natively
    if (self.canSendTweet)
    {
        MNONativeTwitterClient *native = [[MNONativeTwitterClient alloc] init];
        (self.clients)[TWITTER_CLIENT_CODE_NATIVE] = native;
    }
}

- (BOOL)canSendTweet
{
    Class klass = NSClassFromString(@"TWTweetComposeViewController");
    if (nil != klass)
    {
        return [TWTweetComposeViewController canSendTweet];
    }
    return NO;
}

@end
