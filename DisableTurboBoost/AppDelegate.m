//
//  AppDelegate.m
//  DisableTurboBoost
//
//  Created by Ge on 14-1-7.
//  Copyright (c) 2014年 Ge. All rights reserved.
//

#import "AppDelegate.h"
#import "SystemCommand.h"
#import "StartupHelper.h"
#import "Settings.h"

@interface AppDelegate (Private)

- (void)autoLoad;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    self.window.delegate = self;
    Settings *settings = [Settings sharedInstance];
    BOOL isStartUp = [StartupHelper isOpenAtLogin];
    
    if(settings.password.length != 0 && isStartUp)
    {
        canExitWindow = NO;
        [self.window close];
        [self performSelector:@selector(autoLoad) withObject:nil afterDelay:0.1];
    }
    else
    {
        [self btnState];
        canExitWindow = YES;
        self.bootCheck.intValue = isStartUp;
        self.UserText.stringValue = settings.username;
        self.PassText.stringValue = settings.password;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (void)btnState
{
    if([SystemCommands isModuleLoaded])
    {
        self.btnTest.title = NSLocalizedString(@"BUTTON_ENABLE", nil);
    }
    else
    {
        self.btnTest.title = NSLocalizedString(@"BUTTON_DISABLE", nil);
    }
}

- (void)autoLoad
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"ALERT_HINT", nil)];
    if([SystemCommands isModuleLoaded])
    {
        if([SystemCommands unLoadModule])
        {
            [alert setAlertStyle:NSInformationalAlertStyle];
            if(canExitWindow)
                [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_WIN_EANBLE_SUCCEED", nil)];
            else
            {
                [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_EANBLE_SUCCEED_PROMPT", nil)];
                [alert addButtonWithTitle:NSLocalizedString(@"ALERT_BTN_NO", nil)];
                [alert addButtonWithTitle:NSLocalizedString(@"ALERT_BTN_YES", nil)];
            }
        }
        else
        {
            [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_ENABLE_FAILED", nil)];
            [alert setAlertStyle:NSWarningAlertStyle];
            [Settings sharedInstance].password = @"";
            [alert addButtonWithTitle:NSLocalizedString(@"ALERT_BTN_OK", nil)];
            [StartupHelper setOpenAtLogin:NO];
        }
    }
    else
    {
        if([SystemCommands loadModule])
        {
            if(canExitWindow)
            {
                [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_DISABLE_SUCCEED", nil)];
                [alert setAlertStyle:NSInformationalAlertStyle];
            }
            else
            {
                exit(0);
                return;
            }
        }
        else
        {
            [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_DISABLE_FAILED", nil)];
            [alert setAlertStyle:NSWarningAlertStyle];
            [StartupHelper setOpenAtLogin:NO];
            [Settings sharedInstance].password = @"";
        }
        [alert addButtonWithTitle:NSLocalizedString(@"ALERT_BTN_OK", nil)];
    }
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow modalDelegate:self didEndSelector:@selector(OnExit:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)OnReset:(id)sender
{
    self.UserText.stringValue = @"";
    self.PassText.stringValue = @"";
    self.bootCheck.intValue = 0;
}

- (IBAction)OnSave:(id)sender
{
    if(self.PassText.stringValue.length == 0 && sender != nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"ALERT_BTN_OK", nil)];
        [alert setMessageText:NSLocalizedString(@"ALERT_HINT", nil)];
        [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_INPUT_PASS", nil)];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
        [self.PassText selectText:self.PassText];
        return;
    }
    
    Settings *settings = [Settings sharedInstance];
    settings.username = self.UserText.stringValue;
    settings.password = self.PassText.stringValue;
    
    [StartupHelper setOpenAtLogin:self.bootCheck.intValue];
    
    if(sender != nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"ALERT_BTN_OK", nil)];
        [alert setMessageText:NSLocalizedString(@"ALERT_HINT", nil)];
        [alert setInformativeText:NSLocalizedString(@"ALERT_MESSAGE_SAVED", nil)];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
}

- (IBAction)OnTest:(id)sender
{
    [self OnSave:nil];
    [self autoLoad];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if(canExitWindow)
        exit(0);
}

- (void)OnExit:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void*)info
{
    if(returnCode == 1001)
    {
        [Settings sharedInstance].password = @"";
        [StartupHelper setOpenAtLogin:NO];
    }
    if(!canExitWindow)
        exit(0);
    else
        [self btnState];
}

@end
