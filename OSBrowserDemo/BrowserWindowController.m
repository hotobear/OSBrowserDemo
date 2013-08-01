//
//  BrowserWindowController.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-23.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserWindowController.h"
#import "BrowserWindow.h"

@interface BrowserWindowController ()

@end

@implementation BrowserWindowController

- (id)init
{
    self = [super init];
    if (self)
    {
        NSSize screenSize = [[NSScreen mainScreen] visibleFrame].size;
        self.window = [[[BrowserWindow alloc] initWithContentRect:NSMakeRect(0, 0, screenSize.width, screenSize.height)
                                                        styleMask:NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask | NSTexturedBackgroundWindowMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:YES] autorelease];
    }
    
    return self;
}

@end
