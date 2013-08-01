//
//  BrowserView.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-22.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserView.h"
#import <WebKit/WebKit.h>

@interface BrowserView ()

@property (nonatomic, retain) WebView *webView;

- (void)createWebView;

@end


@implementation BrowserView

@synthesize webView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        [self createWebView];
    } 
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    
    [super dealloc];
}

- (void)createWebView
{
    self.webView = [[[WebView alloc] initWithFrame:self.bounds] autorelease];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MAIN_PAGE_URL]]];
    [self addSubview:self.webView];
}

@end
