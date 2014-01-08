//
//  AppDelegate.h
//  DisableTurboBoost
//
//  Created by Ge on 14-1-7.
//  Copyright (c) 2014年 Ge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    @private
    BOOL canExitWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *btnTest;
@property (weak) IBOutlet NSTextField *UserText;
@property (weak) IBOutlet NSSecureTextField *PassText;
@property (weak) IBOutlet NSButton *bootCheck;

@end
