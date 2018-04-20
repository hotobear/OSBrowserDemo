//
//  BrowserView.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-22.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserView.h"
#import "URLTool.h"

@interface BrowserView () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, retain) WKWebView *webView;

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
        [self addObserverForWKWebView];
    } 
    
    return self;
}

- (void)dealloc
{
    [self removeObserverForWKWebView];
    self.webView = nil;
    
    [super dealloc];
}

- (void)createWebView
{
    self.webView = [[[WKWebView alloc] initWithFrame:self.bounds] autorelease];
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:self.webView];

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}

- (void)addObserverForWKWebView {
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverForWKWebView {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.webView) {
        if ([keyPath isEqualToString:@"estimatedProgress"])
        {
            double estimatedProgress = self.webView.estimatedProgress;
            if (estimatedProgress <= 0.1)
            {
                [self webViewProgressStarted:self.webView];
            }
            else if (estimatedProgress >= 1)
            {
                [self webViewProgressFinished:self.webView];
            }
            else
            {
                [self webViewProgressChanged:self.webView];
            }
        }
        else if ([keyPath isEqualToString:@"title"])
        {
            if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didReceiveTitle:)])
            {
                [self.delegate browserView:self didReceiveTitle:webView.title];
            }
        }
    }
}

#pragma mark - WebView Methods
- (void)loadURLString:(NSString *)URLString
{
    [self loadURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
}

- (void)loadURLRequest:(NSURLRequest *)URLRequest
{
    [self.webView loadRequest:URLRequest];
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

- (WKBackForwardList *)backForwardList;
{
    return self.webView.backForwardList;
}

- (WKNavigation *)goToBackForwardItem:(WKBackForwardListItem *)item;
{
    return [self.webView goToBackForwardListItem:item];
}

#pragma mark - progress
- (void)webViewProgressChanged:(WKWebView *)webView
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didChangeProgress:)])
    {
        [self.delegate browserView:self didChangeProgress:self.webView.estimatedProgress];
    }
}

- (void)webViewProgressStarted:(WKWebView *)webView
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidStartProgress:)])
    {
        [self.delegate browserViewDidStartProgress:self];
    }
}

- (void)webViewProgressFinished:(WKWebView *)webView
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidEndProgress:)])
    {
        [self.delegate browserViewDidEndProgress:self];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidStartProvisionalLoad:)])
    {
        [self.delegate browserViewDidStartProvisionalLoad:self];
    }
    
    NSString *url = webView.URL.absoluteString;
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didReceiveURL:)])
    {
        [self.delegate browserView:self didReceiveURL:url];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSError *err = nil;
    NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Error" ofType:@"html"] encoding:NSUTF8StringEncoding error:&err];
    assert(!err);
    html = [NSString stringWithFormat:html, [error localizedDescription]];
    [webView loadHTMLString:html baseURL:webView.URL];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidCommitLoadForFrame:)])
    {
        [self.delegate browserViewDidCommitLoadForFrame:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserViewDidFinishLoadForFrame:)])
    {
        [self.delegate browserViewDidFinishLoadForFrame:self];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:didFailLoadWithError:)])
    {
        [self.delegate browserView:self didFailLoadWithError:error];
    }
}

#pragma mark - WKUIDelegte
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(browserView:decidePolicyForNewWindowWithRequest:)])
    {
        if (navigationAction.request.URL.absoluteString.length != 0)
        {
            [self.delegate browserView:self decidePolicyForNewWindowWithRequest:navigationAction.request];
        }
    }
    
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView
{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:frame.securityOrigin.host];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        completionHandler();
    }];
}

- (void) webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:frame.securityOrigin.host];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn)
        {
            completionHandler(YES);
        }
        else if (returnCode == NSAlertSecondButtonReturn)
        {
            completionHandler(NO);
        }
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:frame.securityOrigin.host];
    [alert setInformativeText:prompt];
    [alert setAlertStyle:NSWarningAlertStyle];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultText];
    [input autorelease];
    [alert setAccessoryView:input];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn)
        {
            completionHandler(input.stringValue);
        }
        else if (returnCode == NSAlertSecondButtonReturn)
        {
            completionHandler(nil);
        }
    }];
}

@end
