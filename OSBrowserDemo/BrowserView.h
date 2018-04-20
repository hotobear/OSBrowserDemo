//
//  BrowserView.h
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-22.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class BrowserView;

@protocol BrowserViewDelegate

///> progress
- (void)browserView:(BrowserView *)browserView didChangeProgress:(float)progress;
- (void)browserViewDidStartProgress:(BrowserView *)browserView;
- (void)browserViewDidEndProgress:(BrowserView *)browserView;

///> data source
- (void)browserView:(BrowserView *)browserView didReceiveURL:(NSString *)URLString;
- (void)browserView:(BrowserView *)browserView didReceiveTitle:(NSString *)title;
- (void)browserView:(BrowserView *)browserView didReceiveIcon:(NSImage *)icon;

///> state change
- (void)browserViewDidStartProvisionalLoad:(BrowserView *)browserView;
- (void)browserViewDidCommitLoadForFrame:(BrowserView *)browserView;
- (void)browserViewDidFinishLoadForFrame:(BrowserView *)browserView;
- (void)browserView:(BrowserView *)browserView didFailLoadWithError:(NSError *)error;

///> Policy
- (void)browserView:(BrowserView *)browserView decidePolicyForNewWindowWithRequest:(NSURLRequest *)request;
@end


@interface BrowserView : NSView

@property (nonatomic, assign) id<BrowserViewDelegate> delegate;

///> load
- (void)loadURLString:(NSString *)URLString;
- (void)loadURLRequest:(NSURLRequest *)URLRequest;

///> backForward
- (void)goBack;
- (void)goForward;

///> stop reload
- (void)reload:(id)sender;
- (void)stopLoading:(id)sender;

///> state
- (BOOL)isLoading;
- (BOOL)canGoForward;
- (BOOL)canGoBack;

///> backforward List
- (WKBackForwardList *)backForwardList;
- (WKNavigation *)goToBackForwardItem:(WKBackForwardListItem *)item;

@end
