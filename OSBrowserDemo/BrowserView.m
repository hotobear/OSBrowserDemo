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
    [self addSubview:self.webView];

    self.webView.policyDelegate = self;
    self.webView.frameLoadDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.downloadDelegate = self;
    self.webView.resourceLoadDelegate = self;
    self.webView.editingDelegate = self;
}

#pragma mark - WebView Methods
- (void)loadURLString:(NSString *)URLString
{
    [self loadURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
}

- (void)loadURLRequest:(NSURLRequest *)URLRequest
{
    [[self.webView mainFrame] loadRequest:URLRequest];
}

- (void)goBack
{
    [self.webView goBack];
}

- (void)goForward
{
    [self.webView goForward];
}

- (void)reload:(id)sender
{
    [self.webView reload:sender];
}

- (void)stop:(id)sender
{
    [self.webView stopLoading:sender];
}

#pragma mark - WebPolicyDelegate Methods
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    [self loadURLRequest:request];
}
@end
