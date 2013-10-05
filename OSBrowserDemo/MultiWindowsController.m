//
//  MultiWindowsController.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-5.
//
//

#import "MultiWindowsController.h"

@implementation MultiWindowsController

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

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowClosed:) name:NSWindowWillCloseNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

@end
