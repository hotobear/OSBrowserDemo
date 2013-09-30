//
//  URLTool.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-9-30.
//
//

#import "URLTool.h"

@implementation URLTool

+ (NSString *)standardizeHTTPURLString:(NSString *)URLString
{
    NSURL *URL = [[[NSURL alloc] initWithString:(0 == URLString.length ? MAIN_PAGE_URL : URLString)] autorelease];
    NSString *fullURLString = nil;
    
    if (0 == URL.resourceSpecifier.length)
    {
        fullURLString = MAIN_PAGE_URL;
    }
    else if (0 == URL.scheme.length)
    {
        fullURLString = [DEFAULT_URL_SCHEME stringByAppendingString:URLString];
    }
    
    return fullURLString;
}


@end
