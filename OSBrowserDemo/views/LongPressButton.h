//
//  LongPressButton.h
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-1.
//
//

#import <Cocoa/Cocoa.h>

@interface LongPressButton : NSButton

- (void)setLongPressTime:(float)time;
- (void)setLongPressAction:(SEL)aSelector;
- (void)mouseDownLongPress:(NSEvent *)theEvent;

@end
