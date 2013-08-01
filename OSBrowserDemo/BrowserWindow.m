//
//  BrowserWindow.m
//  BrowserDemoForMac
//
//  Created by huang haotao on 13-6-23.
//  Copyright (c) 2013年 黄 灏涛. All rights reserved.
//

#import "BrowserWindow.h"
#import "BrowserView.h"

#define BROWSER_TOOLBAR_IDENTIFIER                      @"BrowserToolbarIdentifier"
#define BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER         @"BrowserToolbarForwardItemIdentifier"
#define BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER            @"BrowserToolbarBackItemIdentifier"


@interface BrowserWindow () <NSToolbarDelegate>

@property (nonatomic, retain) BrowserView *browserView;

- (void)loadViews;
- (void)layoutWebView;
- (void)layoutToolbar;

@end


@implementation BrowserWindow

@synthesize browserView;

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
    
    [super dealloc];
}

#pragma mark - View Config

- (void)loadViews
{
    [self layoutToolbar];
    [self layoutWebView];
}

- (void)layoutWebView
{
    self.browserView = [[[BrowserView alloc] initWithFrame:[(NSView *)self.contentView bounds]] autorelease];
    [self.contentView addSubview:self.browserView];
}

- (void)layoutToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"BrowserToolbar"];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [toolbar setSizeMode:NSToolbarSizeModeSmall];
    [toolbar setDelegate:self];
    [self setToolbar:toolbar];
    [toolbar release], toolbar = nil;
}

#pragma mark - NSToolbarDelegate

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return @[
             BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER
             ];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return @[
             BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER,
             BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER
             ];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_BACK_ITEM_IDENTIFIER])
    {
        [toolbarItem setImage:[NSImage imageNamed:@"NSGoLeftTemplate"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(simpleToolbarItemDidClick:)];
    }
    else if ([itemIdentifier isEqualToString:BROWSER_TOOLBAR_FORWARD_ITEM_IDENTIFIER])
    {
        [toolbarItem setImage:[NSImage imageNamed:@"NSGoRightTemplate"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(simpleToolbarItemDidClick:)];
    }
    
    return toolbarItem;
}

- (void)simpleToolbarItemDidClick:(NSToolbarItem *)item
{
    
}

@end
