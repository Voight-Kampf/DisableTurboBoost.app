//
//  Settings.m
//  DisableTurboBoost
//
//  Created by Ge on 14-1-7.
//  Copyright (c) 2014年 Ge. All rights reserved.
//

#import "Settings.h"
#import "InfoCrypt.h"

#define user_key @"JF3892jf*!@F@f42f23"
#define pass_key @"JF@38F#@(8fsf3#Ff)("

static NSUserDefaults *_defaults = nil;
static Settings *_settings = nil;

@implementation Settings

- (NSUserDefaults *)sharedDefaults
{
    if(nil == _defaults)
        _defaults = [NSUserDefaults standardUserDefaults];
    return _defaults;
}

+ (Settings *)sharedInstance;
{
    if(nil == _settings)
        _settings = [[Settings alloc] init];
    return _settings;
}

- (void)setUsername:(NSString *)username
{
    NSUserDefaults *defaults = [self sharedDefaults];
    if(defaults)
    {
        NSData *data = [username dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSData *encrypt = [InfoCrypt AES128OperationWithKey:kCCEncrypt input:data key:user_key];
        [defaults setValue:encrypt forKey:@"data1"];
        [defaults synchronize];
    }
}

- (void)setPassword:(NSString *)password
{
    NSUserDefaults *defaults = [self sharedDefaults];
    if(defaults)
    {
        NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSData *encrypt = [InfoCrypt AES128OperationWithKey:kCCEncrypt input:data key:pass_key];
        [defaults setValue:encrypt forKey:@"data2"];
        [defaults synchronize];
    }
}

- (NSString *)username
{
    NSUserDefaults *defaults = [self sharedDefaults];
    if(defaults)
    {
        @try {
            NSData *data = [defaults valueForKey:@"data1"];
            NSData *decrypt = [InfoCrypt AES128OperationWithKey:kCCDecrypt input:data key:pass_key];
            return [[NSString alloc] initWithData:decrypt encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            self.username = @"";
        }
    }
    return nil;
}

- (NSString *)password
{
    NSUserDefaults *defaults = [self sharedDefaults];
    if(defaults)
    {
        @try {
            NSData *data = [defaults valueForKey:@"data2"];
            NSData *decrypt = [InfoCrypt AES128OperationWithKey:kCCDecrypt input:data key:pass_key];
            return [[NSString alloc] initWithData:decrypt encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            self.password = @"";
        }
    }
    return nil;
}

@end
