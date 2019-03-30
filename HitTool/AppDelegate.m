//
//  AppDelegate.m
//  HitTool
//
//  Created by dillon on 2019/3/29.
//  Copyright © 2019 dillon. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () {
    BOOL isDesktopIconsShow;
}

@property (weak) IBOutlet NSMenu *contentMenu;
@property (nonatomic, copy) NSString *hideDesktopPath;
@property (nonatomic, copy) NSString *darkmodePath;
//@property (nonatomic, strong) NSBlockOperation *caffeinateOperation;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage *statusImage = [NSImage imageNamed:@"menuicon"];
    statusImage.size = NSMakeSize(18.0, 18.0);
    statusItem.button.image = statusImage;
    statusItem.menu = self.contentMenu;
    
    self.hideDesktopPath = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"sh"];
    self.darkmodePath = [[NSBundle mainBundle] pathForResource:@"darkmode" ofType:@"scpt"];
    
    [self readDesktopConfig];
    self.preventFromSleepingMenuItem.state = [self detectCaffeineRunning];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - IBAction
- (IBAction)buttonTouched:(id)sender {
    NSInteger tag = [(NSMenuItem *)sender tag];
    if (tag == 0) {
        [self triggerDesktopIconsHide:!isDesktopIconsShow];
    }
    else if (tag == 1) {
        [self switchSystemTheme];
    }
    else if (tag == 2) {
        NSMenuItem *item = (NSMenuItem *)sender;
        [self toggleSleep:!item.state];
        item.state = 1 - item.state;
    }
    else if (tag == 3) {
        [self launchScreenSaver];
    }
    else if (tag == 4) {
        [self toggleSleep:NO];
        [NSApp terminate:self];
    }
}

#pragma mark - Trigger desktop icons
- (void)readDesktopConfig {
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/defaults";
    task.arguments = @[@"read", @"com.apple.finder", @"CreateDesktop"];
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *grepOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    isDesktopIconsShow = [grepOutput boolValue];
    if (isDesktopIconsShow) {
        [self.triggerDisktopIconsMenuItem setTitle:@"Hide Desktop Icons"];
    }
    else {
        [self.triggerDisktopIconsMenuItem setTitle:@"Show Desktop Icons"];
    }
}

- (void)triggerDesktopIconsHide:(BOOL)show {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/bin/bash";
        task.arguments = @[self.hideDesktopPath, show ? @"show" : @"hide"];
        
        [task launch];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self readDesktopConfig];
    });
}

#pragma mark - Dark Mode
- (void)switchSystemTheme {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/osascript"];
    [task setArguments:@[self.darkmodePath]];
    task.currentDirectoryPath = @"/";
    
    [task launch];
}
         
#pragma mark - Caffeinate
- (void)toggleSleep:(BOOL)sleep {
    if (sleep) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/usr/bin/caffeinate"];
            [task launch];
        });
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/usr/bin/killall"];
            [task setArguments:@[@"caffeinate"]];
            [task launch];
        });
    }
}

- (BOOL)detectCaffeineRunning {
    return system("ps -Ac | grep 'caffeinate' > /dev/null") == 0;
}

#pragma mark - Screen Saver
- (void)launchScreenSaver {
    system("/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine");
}

@end
