//
//  MultiWindowsController.h
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-5.
//
//

#import <Foundation/Foundation.h>

@class BrowserWindowController;

@interface MultiWindowsController : NSObject

+ (MultiWindowsController *)defaultController;

+ (void)prepared;
 
@end
