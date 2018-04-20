//
//  BrowserWindow.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-23.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserWindow.h"
#import "BrowserView.h"
#import "LongPressPopUpButton.h"
#import "LBProgressBar.h"
#import "URLTool.h"

#define BROWSER_TOOLBAR_IDENTIFIER                      @"BrowserToolbarIdentifier"
#define BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER         @"BrowserToolbarForwardItemIdentifier"
#define BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER            @"BrowserToolbarBackItemIdentifier"
#define BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER         @"BrowserToolbarRefreshItemIdentifier"
#define BROWSER_TOOLBAR_ICON_ITEM_IDENTIFIER            @"BrowserToolbarIconItemIdentifier"
#define BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER          @"BrowserToolbarInputFieldIdentifier"

#define PROGRESS_INDICATOR_HEIGHT                       5.0
#define DEFAULT_TOOLBAR_HEIGHT                          16.0
#define FAV_ICON_HEIGHT                                 16.0

#define BACKFORWARD_LIST_LIMIT                          10

@interface BrowserWindow () <NSToolbarDelegate, NSTextFieldDelegate, BrowserViewDelegate, LongPressPopUpButtonDataSource>

@property (nonatomic, retain) BrowserView *browserView;
@property (nonatomic, retain) NSTextField *URLTextField;
@property (nonatomic, retain) LBProgressBar *progressIndicator;
@property (nonatomic, retain) LongPressPopUpButton *backButton;
@property (nonatomic, retain) LongPressPopUpButton *forwardButton;
@property (nonatomic, retain) NSButton *refreshButton;
@property (nonatomic, retain) NSButton *icon;

- (void)loadViews;
- (void)layoutWebView;
- (void)layoutToolbar;
- (void)createToolbarElements;

@end


@implementation BrowserWindow

@synthesize browserView;
@synthesize URLTextField;
@synthesize progressIndicator;
@synthesize backButton;
@synthesize forwardButton;
@synthesize refreshButton;
@synthesize icon;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self loadViews];
    }
    
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    if (self)
    {
        [self loadViews];
    }
    
    return self;
}

- (void)dealloc
{
    self.browserView = nil;
    
    self.URLTextField.delegate = nil;
    self.URLTextField = nil;
    
    self.backButton.dataSource = nil;
    self.backButton = nil;
    self.forwardButton.dataSource = nil;
    self.forwardButton = nil;
    self.refreshButton = nil;
    self.icon = nil;
    
    [super dealloc];
}

#pragma mark - Browser
- (void)loadRequest:(NSURLRequest *)request
{
    [self.browserView loadURLRequest:request];
}

#pragma mark - View Config

- (void)loadViews
{
    [self layoutToolbar];
    [self layoutProgress];
    [self layoutWebView];
}

- (void)layoutWebView
{
    NSRect rect = [self.contentView bounds];
    rect.size.height -= PROGRESS_INDICATOR_HEIGHT;
    self.browserView = [[[BrowserView alloc] initWithFrame:rect] autorelease];
    self.browserView.delegate = self;
    [self.contentView addSubview:self.browserView];
}

- (void)layoutToolbar
{
    [self createToolbarElements];
    [self refreshButtonOnLoadingStateChange:NO];
    [self iconOnLoadingStateChangeToLoading];
    
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:@"BrowserToolbar"] autorelease];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [toolbar setSizeMode:NSToolbarSizeModeSmall];
    [toolbar setDelegate:self];
    [self setToolbar:toolbar];
}

- (void)layoutProgress
{
    NSRect progressRect = NSMakeRect(0, NSHeight([self.contentView bounds]) - PROGRESS_INDICATOR_HEIGHT, [self.contentView bounds].size.width, PROGRESS_INDICATOR_HEIGHT);
    self.progressIndicator = [[[LBProgressBar alloc] initWithFrame:progressRect] autorelease];
    [self.progressIndicator setMinValue:0];
    [self.progressIndicator setMaxValue:1];
    [self.progressIndicator setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
    [self.progressIndicator setDoubleValue:1];
    [self.progressIndicator setStyle:NSProgressIndicatorBarStyle];
    [self.progressIndicator setIndeterminate:NO];
    [self.contentView addSubview:self.progressIndicator];
}

- (void)createToolbarElements
{
    self.URLTextField = [[[NSTextField alloc] initWithFrame:NSZeroRect] autorelease];
    self.URLTextField.delegate = self;
    
    NSRect frame = NSMakeRect(0, 0, DEFAULT_TOOLBAR_HEIGHT, DEFAULT_TOOLBAR_HEIGHT);
    NSSize size = NSMakeSize(DEFAULT_TOOLBAR_HEIGHT, DEFAULT_TOOLBAR_HEIGHT);
    self.backButton = [[[LongPressPopUpButton alloc] initWithFrame:frame] autorelease];
    NSImage *backImage = [NSImage imageNamed:@"NSGoLeftTemplate"];
    [backImage setSize:size];
    [self.backButton setImage:backImage];
    [self.backButton.cell setBordered:NO];
    [self.backButton setTarget:self];
    [self.backButton setAction:@selector(backItemDidClicked:)];
    [self.backButton setEnabled:NO];
    [self.backButton setDataSource:self];
    
    self.forwardButton = [[[LongPressPopUpButton alloc] initWithFrame:frame] autorelease];
    NSImage *forwardImage = [NSImage imageNamed:@"NSGoRightTemplate"];
    [forwardImage setSize:size];
    [self.forwardButton setImage:forwardImage];
    [self.forwardButton.cell setBordered:NO];
    [self.forwardButton setTarget:self];
    [self.forwardButton setAction:@selector(forwardItemDidClicked:)];
    [self.forwardButton setEnabled:NO];
    [self.forwardButton setDataSource:self];
    
    self.refreshButton = [[[NSButton alloc] initWithFrame:frame] autorelease];
    [self.refreshButton.cell setBordered:NO];
    [self.refreshButton setTarget:self];
    [self.refreshButton setAction:@selector(refreshItemDidClicked:)];
    
    self.icon = [[[NSButton alloc] initWithFrame:frame] autorelease];
    [self.icon.cell setHighlightsBy:NSNoCellMask];
    [self.icon.cell setBordered:NO];
    [self.icon setTarget:self];
    [self.icon setAction:@selector(iconDidClicked:)];
}

- (void)refreshButtonOnLoadingStateChange:(BOOL)isLoading
{
    if (isLoading)
    {
        NSImage *stopImage = [NSImage imageNamed:@"NSStopProgressTemplate"];
        [stopImage setSize:NSMakeSize(DEFAULT_TOOLBAR_HEIGHT, DEFAULT_TOOLBAR_HEIGHT)];
        [self.refreshButton setImage:stopImage];
    }
    else
    {
        NSImage *refreshImage = [NSImage imageNamed:@"NSRefreshTemplate"];
        [refreshImage setSize:NSMakeSize(DEFAULT_TOOLBAR_HEIGHT, DEFAULT_TOOLBAR_HEIGHT)];
        [self.refreshButton setImage:refreshImage];
    }
}

- (void)iconOnLoadingStateChangeToLoading
{
    NSImage *iconImage = [NSImage imageNamed:@"NSNetworkTemplate"];
    [iconImage setSize:NSMakeSize(FAV_ICON_HEIGHT, FAV_ICON_HEIGHT)];
    [self.icon setImage:iconImage];
}


#pragma mark - NSToolbarDelegate

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return @[
             BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER,
             NSToolbarSpaceItemIdentifier,
             BROWSER_TOOLBAR_ICON_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER,
             ];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return @[
             BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER,
             NSToolbarSpaceItemIdentifier,
             BROWSER_TOOLBAR_ICON_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER,
             ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER])
    {
        [toolbarItem setView:self.backButton];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER])
    {
        [toolbarItem setView:self.forwardButton];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER])
    {
        [toolbarItem setView:self.refreshButton];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_ICON_ITEM_IDENTIFIER])
    {
        [toolbarItem setView:self.icon];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER])
    {
        [toolbarItem setView:self.URLTextField];
        [toolbarItem setMinSize:NSMakeSize(200, 24)];
        [toolbarItem setMaxSize:NSMakeSize(2000, 24)];
    }
    
    return toolbarItem;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    return YES;
}

#pragma mark - NSTextFieldDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    BOOL ret = YES;
    
    if (self.URLTextField == control)
    {
        NSString *URLString = [URLTool standardizeHTTPURLString:fieldEditor.string];
        if (URLString.length != 0)
        {
            [self.URLTextField setStringValue:URLString];
            [self.browserView loadURLString:URLString];
        }
    }
    
    return ret;
}

#pragma mark - LongPressPopUpButtonDataSource
- (NSMenu *)popupMenuForLongPressAction:(LongPressPopUpButton *)button
{
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    WKBackForwardList *list = [self.browserView backForwardList];
    
    id<NSFastEnumeration> orderedList = nil;
    
    if (button == self.backButton)
    {
        NSArray *backlist = [list backList];
        orderedList = backlist;
    }
    else if (button == self.forwardButton)
    {
        NSArray *forwardlist = [list forwardList];
        NSEnumerator *reverseList = [forwardlist reverseObjectEnumerator];
        orderedList = reverseList;
    }
    
    if (orderedList)
    {
        for (WKBackForwardListItem *item in orderedList)
        {
            NSString *title = [item title].length != 0 ? [item title] : [[item URL] absoluteString];
            assert(title);
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(backForwardMenuDidClicked:) keyEquivalent:@""];
            menuItem.representedObject = item;
//            [menuItem setImage:[item icon]];
            [menu insertItem:menuItem atIndex:0];
            [menuItem release];
        }
    }
    
    return menu;
}

#pragma mark - Button Action
- (void)backItemDidClicked:(NSButton *)item
{
    [self.browserView goBack];
}

- (void)forwardItemDidClicked:(NSButton *)item
{
    [self.browserView goForward];
}

- (void)backForwardMenuDidClicked:(NSMenuItem *)item
{
    WKBackForwardListItem* historyItem = item.representedObject;
    [self.browserView goToBackForwardItem:historyItem];
}

- (void)refreshItemDidClicked:(NSButton *)item
{
    if (!self.browserView.isLoading)
    {
        [self.browserView reload:item];
    }
    else
    {
        [self.browserView stopLoading:item];
    }
}

- (void)iconDidClicked:(NSButton *)item
{
    
}

#pragma mark - BrowserViewDelegate
- (void)browserView:(BrowserView *)browserView didChangeProgress:(float)progress
{
    [self.progressIndicator setDoubleValue:progress];
}

- (void)browserViewDidStartProgress:(BrowserView *)browserView
{
    [self.progressIndicator startAnimation:nil];
    [self.progressIndicator setDoubleValue:0];
}

- (void)browserViewDidEndProgress:(BrowserView *)browserView
{
    [self.progressIndicator setDoubleValue:1];
    [self.progressIndicator stopAnimation:nil];
}


- (void)browserView:(BrowserView *)browserView didReceiveURL:(NSString *)URLString
{
    [self.URLTextField setStringValue:URLString];
}

- (void)browserView:(BrowserView *)browserView didReceiveTitle:(NSString *)title
{
    [self setTitle:title];
}

- (void)browserView:(BrowserView *)browserView didReceiveIcon:(NSImage *)image
{
    [self.icon setImage:image];
}


- (void)browserViewDidStartProvisionalLoad:(BrowserView *)browserView
{
    [self refreshButtonOnLoadingStateChange:YES];
    [self iconOnLoadingStateChangeToLoading];
}

- (void)browserViewDidCommitLoadForFrame:(BrowserView *)browserView
{
    [self.backButton setEnabled:[self.browserView canGoBack]];
    [self.forwardButton setEnabled:[self.browserView canGoForward]];
//    [self.icon setImage:[[[self.browserView backForwardList] currentItem] icon]];
}

- (void)browserViewDidFinishLoadForFrame:(BrowserView *)browserView
{
    [self refreshButtonOnLoadingStateChange:NO];
}

- (void)browserView:(BrowserView *)browserView didFailLoadWithError:(NSError *)error
{
    [self refreshButtonOnLoadingStateChange:NO];
}

- (void)browserView:(BrowserView *)browserView decidePolicyForNewWindowWithRequest:(NSURLRequest *)request
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:request, @"request", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSWindowAddNewBrowserWindowNotification object:nil userInfo:userInfo];
    [userInfo release];
}

@end
