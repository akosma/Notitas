//
//  MNOTwitterClient.m
//  Notitas
//
//  Created by Adrian on 9/11/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "MNOTwitterClient.h"

@implementation MNOTwitterClient

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
        _urlTemplate = [dict[@"template"] copy];
        _name = [dict[@"name"] copy];
    }
    return self;
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
        NSString *message = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                (CFStringRef)text,
                                                                                NULL, 
                                                                                (CFStringRef)@";/?:@&=+$,", 
                                                                                kCFStringEncodingUTF8);
        
        NSString *stringURL = [NSString stringWithFormat:self.urlTemplate, message];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];    
    }
}

@end
