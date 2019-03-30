//
//  AppDelegate.h
//  HitTool
//
//  Created by dillon on 2019/3/29.
//  Copyright © 2019 dillon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    NSStatusItem *statusItem;
    
}

@property (weak) IBOutlet NSMenuItem *triggerDisktopIconsMenuItem;
@property (weak) IBOutlet NSMenuItem *preventFromSleepingMenuItem;

@end

