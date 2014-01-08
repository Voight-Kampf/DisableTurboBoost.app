//
//  Settings.h
//  DisableTurboBoost
//
//  Created by Ge on 14-1-7.
//  Copyright (c) 2014年 Ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings *)sharedInstance;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
