//
//  BrowserWindow.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-23.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserWindow.h"
#import "BrowserView.h"
#import "URLTool.h"

#define BROWSER_TOOLBAR_IDENTIFIER                      @"BrowserToolbarIdentifier"
#define BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER         @"BrowserToolbarForwardItemIdentifier"
#define BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER            @"BrowserToolbarBackItemIdentifier"
#define BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER         @"BrowserToolbarRefreshItemIdentifier"
#define BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER          @"BrowserToolbarInputFieldIdentifier"

#define PROGRESS_INDICATOR_HEIGHT                       5.0


@interface BrowserWindow () <NSToolbarDelegate, NSTextFieldDelegate>

@property (nonatomic, retain) BrowserView *browserView;
@property (nonatomic, retain) NSTextField *URLTextField;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;

- (void)loadViews;
- (void)layoutWebView;
- (void)layoutToolbar;
- (void)createToolbarElements;

@end


@implementation BrowserWindow

@synthesize browserView;
@synthesize URLTextField;
@synthesize progressIndicator;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self)
    {
        [self loadViews];
    }
    
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
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
    
    [super dealloc];
}

#pragma mark - View Config

- (void)loadViews
{
    [self layoutToolbar];
    [self layoutProgress];
    [self layoutWebView];
    
    [self.browserView loadURLString:MAIN_PAGE_URL];
}

- (void)layoutWebView
{
    NSRect rect = [self.contentView bounds];
    rect.size.height -= PROGRESS_INDICATOR_HEIGHT;
    self.browserView = [[[BrowserView alloc] initWithFrame:rect] autorelease];
    [self.contentView addSubview:self.browserView];
}

- (void)layoutToolbar
{
    [self createToolbarElements];
    
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
    NSRect progressRect = NSMakeRect(0, [self.contentView bounds].size.height - PROGRESS_INDICATOR_HEIGHT, [self.contentView bounds].size.width, PROGRESS_INDICATOR_HEIGHT);
    self.progressIndicator = [[[NSProgressIndicator alloc] initWithFrame:progressRect] autorelease];
    [self.progressIndicator setMinValue:0];
    [self.progressIndicator setMaxValue:1];
    [self.progressIndicator setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
    [self.progressIndicator setDoubleValue:1];
    [self.progressIndicator setStyle:NSProgressIndicatorBarStyle];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator setDisplayedWhenStopped:YES];
    [self.contentView addSubview:self.progressIndicator];
}

- (void)createToolbarElements
{
    self.URLTextField = [[[NSTextField alloc] initWithFrame:NSZeroRect] autorelease];
    self.URLTextField.delegate = self;
}


#pragma mark - NSToolbarDelegate

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return @[
             BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER,
             ];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return @[
             BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER,
             ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER])
    {        
        [toolbarItem setImage:[NSImage imageNamed:@"NSGoLeftTemplate"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(backItemDidClicked:)];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER])
    {
        [toolbarItem setImage:[NSImage imageNamed:@"NSGoRightTemplate"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(forwardItemDidClicked:)];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_REFRESH_ITEM_IDENTIFIER])
    {
        [toolbarItem setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(refreshItemDidClicked:)];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_INPUT_FIELD_IDENTIFIER])
    {
        [toolbarItem setView:self.URLTextField];
        [toolbarItem setMinSize:NSMakeSize(200, 24)];
        [toolbarItem setMaxSize:NSMakeSize(2000, 24)];
    }
    
    return toolbarItem;
}

#pragma mark - NSTextFieldDelegate
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    BOOL ret = YES;
    
    if (self.URLTextField == control)
    {
        NSString *URLString = [URLTool standardizeHTTPURLString:fieldEditor.string];
        [self.URLTextField setStringValue:URLString];
        [self.browserView loadURLString:URLString];
    }
    
    return ret;
}

#pragma mark - Button Action

- (void)backItemDidClicked:(NSToolbarItem *)item
{
    [self.browserView goBack];
}

- (void)forwardItemDidClicked:(NSToolbarItem *)item
{
    [self.browserView goForward];
}

- (void)refreshItemDidClicked:(NSToolbarItem *)item
{
    [self.browserView reload:item];
}

@end
