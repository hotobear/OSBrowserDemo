//
//  BrowserView.h
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-22.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BrowserView : NSView

///> load
- (void)loadURLString:(NSString *)URLString;
- (void)loadURLRequest:(NSURLRequest *)URLRequest;

///> backForward
- (void)goBack;
- (void)goForward;

///> stop reload
- (void)reload:(id)sender;
- (void)stop:(id)sender;

@end
