//
//  main.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-8-1.
//
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[NSApplication sharedApplication] setDelegate:[[[AppDelegate alloc] init] autorelease]];
	[NSApp run];
	[pool release];
}
