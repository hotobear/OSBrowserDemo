//
//  MultiWindowsController.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-5.
//
//

#import "MultiWindowsController.h"
#import "BrowserWindowController.h"

@interface MultiWindowsController ()

@property (nonatomic, retain) NSMutableArray *windowsArray;

@end

@implementation MultiWindowsController

@synthesize windowsArray;

+ (MultiWindowsController *)defaultController
{
    static MultiWindowsController *_sharedInstance = nil;
    if (!_sharedInstance)
    {
        @synchronized(self)
        {
            _sharedInstance = [[MultiWindowsController alloc] init];
        }
    }

    return  _sharedInstance;
}

+ (void)prepared
{
    [MultiWindowsController defaultController];
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowClosed:) name:NSWindowWillCloseNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_browserWindowAdded:) name:NSWindowAddNewBrowserWindowNotification object:nil];
        
        self.windowsArray = [[[NSMutableArray alloc] init] autorelease];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.windowsArray = nil;
    
    [super dealloc];
}

- (void)_browserWindowAdded:(NSNotification *)note
{
    BrowserWindowController *controller = [[BrowserWindowController alloc] init];
    [self.windowsArray addObject:controller];
    [controller showWindow:self];
    
    NSURLRequest *request = [note.userInfo objectForKey:@"request"];
    if (!request)
    {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:MAIN_PAGE_URL]];
    }
    
    [controller loadRequest:request];
    [controller release];
}

- (void)_windowClosed:(NSNotification *)note
{
    NSWindow *window = [note object];
    for (NSWindowController *winController in self.windowsArray)
    {
        if (winController.window == window)
        {
            [[winController retain] autorelease]; // Keeps the instance alive a little longer so things can unbind from it
            [self.windowsArray removeObject:winController];
            break;
        }
    }
}


@end
