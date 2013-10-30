//
//  BrowserView.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-22.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserView.h"
#import "URLTool.h"

@interface BrowserView ()

@property (nonatomic, retain) WebView *webView;

- (void)createWebView;

@end


@implementation BrowserView

@synthesize webView;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        [self createWebView];
        [self addNotificationObserver];
    } 
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    [self removeNotificationObserver];
    
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

- (void)addNotificationObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewProgressChanged:) name:WebViewProgressEstimateChangedNotification object:self.webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewProgressStarted:) name:WebViewProgressStartedNotification object:self.webView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewProgressFinished:) name:WebViewProgressFinishedNotification object:self.webView];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)stopLoading:(id)sender
{
    [self.webView stopLoading:sender];
}

- (BOOL)isLoading
{
    return [self.webView isLoading];
}

- (BOOL)canGoForward
{
    return [self.webView canGoForward];
}

- (BOOL)canGoBack
{
    return [self.webView canGoBack];
}

- (WebBackForwardList *)backForwardList;
{
    return self.webView.backForwardList;
}

- (BOOL)goToBackForwardItem:(WebHistoryItem *)item;
{
    return [self.webView goToBackForwardItem:item];
}

#pragma mark - progress
- (void)webViewProgressChanged:(WebView *)webView
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didChangeProgress:)])
    {
        [self.delegate browserView:self didChangeProgress:self.webView.estimatedProgress];
    }
}

- (void)webViewProgressStarted:(WebView *)webView
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidStartProgress:)])
    {
        [self.delegate browserViewDidStartProgress:self];
    }
}

- (void)webViewProgressFinished:(WebView *)webView
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidEndProgress:)])
    {
        [self.delegate browserViewDidEndProgress:self];
    }
}

#pragma mark - WebPolicyDelegate 
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:decidePolicyForNewWindowWithRequest:)])
    {
        [self.delegate browserView:self decidePolicyForNewWindowWithRequest:request];
    }
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    [listener use];
}

#pragma mark - WebFrameLoadDelegate
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
{
    if (frame == [sender mainFrame])
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidStartProvisionalLoad:)])
        {
            [self.delegate browserViewDidStartProvisionalLoad:self];
        }
        
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didReceiveURL:)])
        {
            [self.delegate browserView:self didReceiveURL:url];
        }
    }
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        NSError *err = nil;
        NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Error" ofType:@"html"] encoding:NSUTF8StringEncoding error:&err];
        assert(!err);
        html = [NSString stringWithFormat:html, [error localizedDescription]];
        [self.webView.mainFrame loadAlternateHTMLString:html baseURL:[NSURL URLWithString:self.webView.mainFrameURL] forUnreachableURL:[NSURL URLWithString:self.webView.mainFrameURL]];
    }
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidCommitLoadForFrame:)])
        {
            [self.delegate browserViewDidCommitLoadForFrame:self];
        }
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidFinishLoadForFrame:)])
        {
            [self.delegate browserViewDidFinishLoadForFrame:self];
        }
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didFailLoadWithError:)])
        {
            [self.delegate browserView:self didFailLoadWithError:error];
        }
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didReceiveTitle:)])
        {
            [self.delegate browserView:self didReceiveTitle:title];
        }
    }
}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame])
    {
        if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didReceiveIcon:)])
        {
            [self.delegate browserView:self didReceiveIcon:image];
        }
    }
}

@end
