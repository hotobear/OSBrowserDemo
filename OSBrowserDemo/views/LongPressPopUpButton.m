//
//  LongPressPopUpButton.m
//  OSBrowserDemo
//
//  Created by huang haotao on 13-10-1.
//
//

#import "LongPressPopUpButton.h"

@interface LongPressPopUpButton ()

@property (nonatomic, retain) NSPopUpButtonCell *popUpCell;


@end

@implementation LongPressPopUpButton

@synthesize dataSource;
@synthesize popUpCell;

- (void)mouseDownLongPress:(NSEvent *)theEvent
{
    [super mouseDownLongPress:theEvent];

    if (!self.popUpCell)
    {
        self.popUpCell = [[NSPopUpButtonCell alloc] initTextCell:@""];
        [self.popUpCell setPullsDown:YES];
        [self.popUpCell setPreferredEdge:NSMaxYEdge];
    }
    
    [self runPopUp:theEvent];
}

- (void)runPopUp:(NSEvent *)theEvent
{
    self.menu = [self.dataSource popupMenuForLongPressAction:self];
    if (self.menu)
    {
        [self.menu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:0];	// blank item at top
        [self.popUpCell setMenu:self.menu];
        [self.popUpCell performClickWithFrame:[self bounds] inView:self];
        [self setNeedsDisplay: YES];
        
        [self mouseUp:[NSEvent new]];         ///< fake event
    }
}

- (void)dealloc
{
    self.popUpCell = nil;
    self.dataSource = nil;
    [super dealloc];
}

@end
