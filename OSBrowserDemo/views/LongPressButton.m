//
//  LongPressButton.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-1.
//
//

#import "LongPressButton.h"

@interface LongPressButton ()
{
    SEL m_longPressAction;
}

@property (nonatomic, assign) BOOL isMouseDown;
@property (nonatomic, assign) BOOL isLongPress;

@end

@implementation LongPressButton

@synthesize isMouseDown;
@synthesize isLongPress;

- (void)mouseDownLongPress:(NSEvent *)theEvent
{
    self.isLongPress = YES;
    [self sendAction:m_longPressAction to:[self target]];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (!self.isEnabled)
    {
        return;
    }
    
    [self highlight:YES];
    
    self.isMouseDown=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (isMouseDown)
        {
            [self mouseDownLongPress:theEvent];
        }
    });
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (!self.isEnabled)
    {
        return;
    }
    
    if (!self.isLongPress)
    {
        [self sendAction:[self action] to:[self target]];
    }
    
    self.isMouseDown = NO;
    self.isLongPress = NO;
    [self highlight:NO];
}

- (void)setLongPressAction:(SEL)aSelector
{
    m_longPressAction = aSelector;
}

@end
