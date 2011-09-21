//
//  MNOTwitterClient.m
//  TwitThis
//
//  Created by Adrian on 9/11/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNOTwitterClient.h"

@implementation MNOTwitterClient

@synthesize urlTemplate = _urlTemplate;
@synthesize name = _name;

- (id)init
{
    if (self = [super init])
    {
        _urlTemplate = nil;
        _name = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [self init])
    {
        _urlTemplate = [[dict objectForKey:@"template"] copy];
        _name = [[dict objectForKey:@"name"] copy];
    }
    return self;
}

- (void)dealloc
{
    [_urlTemplate release];
    [_name release];
    [super dealloc];
}

#pragma mark - Public methods

- (BOOL)isAvailable
{
    if (self.name == nil)
    {
        return NO;
    }
    NSString *stringURL = [NSString stringWithFormat:self.urlTemplate, @"test"];
    NSURL *url = [NSURL URLWithString:stringURL];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

- (BOOL)canSendMessage
{
    return (self.name != nil);
}

- (void)send:(NSString *)text
{
    if (self.name != nil)
    {
        NSString *message = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                (CFStringRef)text,
                                                                                NULL, 
                                                                                (CFStringRef)@";/?:@&=+$,", 
                                                                                kCFStringEncodingUTF8);
        
        NSString *stringURL = [NSString stringWithFormat:self.urlTemplate, message];
        [message release];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];    
    }
}

@end
