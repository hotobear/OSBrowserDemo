//
//  BrowserWindow.h
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-23.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BrowserWindow : NSWindow

- (void)loadRequest:(NSURLRequest *)request;

@end
