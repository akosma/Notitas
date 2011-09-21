//
//  MNOTwitterClientManager.m
//  TwitThis
//
//  Created by Adrian on 9/11/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNOTwitterClientManager.h"
#import "MNOTwitterClient.h"
#import "Definitions.h"
#import <AKOLibrary/SynthesizeSingleton.h>

@interface MNOTwitterClientManager ()

@property (nonatomic, retain) NSMutableDictionary *clients;

- (void)initializeClients;

@end


@implementation MNOTwitterClientManager

@synthesize currentClient = _currentClient;
@synthesize clients = _clients;

SYNTHESIZE_SINGLETON_FOR_CLASS(MNOTwitterClientManager)

- (id)init
{
    if (self = [super init])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *value = [defaults stringForKey:TWITTER_CLIENT_KEY];
        NSString *currentClientOption = TWITTER_CLIENT_CODE_NONE;
        if (value == nil)
        {
            [defaults setObject:TWITTER_CLIENT_CODE_NONE forKey:TWITTER_CLIENT_KEY];
        }
        else
        {
            currentClientOption = value;
        }

        [self initializeClients];
        _currentClient = [_clients objectForKey:currentClientOption];
    }
    return self;
}

- (void)dealloc
{
    [_clients release];
    [super dealloc];
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
    [descriptors release];
    [descriptor release];
    return [returnArray autorelease];
}

- (NSArray *)availableClients
{
    NSMutableArray *availableClients = [[NSMutableArray alloc] init];
    for (NSString *clientName in self.clients)
    {
        MNOTwitterClient *client = [self.clients objectForKey:clientName];
        if ([client isAvailable])
        {
            [availableClients addObject:client.name];
        }
    }
    return [availableClients autorelease];
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
    self.currentClient = [self.clients objectForKey:name];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:TWITTER_CLIENT_KEY];
    [defaults synchronize];
}

#pragma mark - Private methods

- (void)initializeClients
{
    // Load Twitter clients from the TwitterClients.plist file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TwitterClients" ofType:@"plist"];
    NSArray *clients = [NSArray arrayWithContentsOfFile:path];

    // Populate the array with the clients
    MNOTwitterClient *none = [[MNOTwitterClient alloc] init];
    self.clients = [NSMutableDictionary dictionary];
    [self.clients setObject:none forKey:TWITTER_CLIENT_CODE_NONE];
    [none release];
    
    for (NSDictionary *dict in clients)
    {
        NSString *name = [dict objectForKey:@"name"];
        MNOTwitterClient *client = [[MNOTwitterClient alloc] initWithDictionary:dict];
        [self.clients setObject:client forKey:name];
        [client release];
    }
}

@end
