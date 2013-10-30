//
//  LongPressButton.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-1.
//
//

#import "LongPressButton.h"

#define DEFAULT_LONG_PRESS_TIME         0.5

@interface LongPressButton ()
{
    SEL m_longPressAction;
    float m_longPressTime;
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
    
    self.isMouseDown = YES;
    
    if (m_longPressTime <= 0)
    {
        [self setLongPressTime:DEFAULT_LONG_PRESS_TIME];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, m_longPressTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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

- (void)setLongPressTime:(float)time
{
    assert(time > 0);
    m_longPressTime = time;
}


@end
