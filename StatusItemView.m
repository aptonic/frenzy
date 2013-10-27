//
//  StatusItemView.m
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "StatusItemView.h"
#import "ShareItem.h"
#import "FrenzyAppDelegate.h"
#import "DragHandler.h"

@implementation StatusItemView

@synthesize statusImage, statusItem, mainMenu, unreadCount;

- (StatusItemView *)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		self.statusImage = [NSImage imageNamed:@"menubar"];
		unreadCount = 0;
        
        dragHandler = [DragHandler sharedDragHandler];
        
        NSArray *draggedTypeArray = [dragHandler supportedDraggingTypes];
        [self registerForDraggedTypes:draggedTypeArray];
	}
	return self;
}

- (void)drawRect:(NSRect)rect 
{
	[statusImage drawAtPoint:NSMakePoint(3, 3) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	if (unreadCount > 0) {
		
		if (unreadCount > 99) unreadCount = 99;
		NSString *labelText = [NSString stringWithFormat:@"%d", unreadCount];
		
		NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:9.0];
		NSColor *fontColor = [NSColor colorWithCalibratedRed:1 green:0.0 blue:0.0 alpha:1];
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:font, fontColor, nil] 
														 forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil]];
		
		int labelX = (unreadCount > 9 ? 7 : 10);  
		
		NSAttributedString *str = [[NSAttributedString alloc] initWithString:labelText attributes:dict];
		[labelText drawAtPoint:NSMakePoint(labelX, 6) withAttributes:dict];

		[str release];
	}
}

- (void)mouseDown:(NSEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
    isMouseDown = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	isMouseDown = NO;
	[self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event 
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
    isMouseDown = YES;
    [self setNeedsDisplay:YES];
}

- (void)rightMouseUp:(NSEvent *)event 
{
	isMouseDown = NO;
	[self setNeedsDisplay:YES];
}

- (void)menuWillOpen:(NSMenu *)menu 
{
	isMouseDown = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu 
{
	isMouseDown = NO;
    [menu setDelegate:nil];    
    [self setNeedsDisplay:YES];
}

/* Drag and Drop */

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSImage *menuBarImage = [NSImage imageNamed:@"menubar-d"];
	
	[self setStatusImage:menuBarImage];
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
    
    return [dragHandler draggingEntered:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)theEvent
{
    return [dragHandler draggingUpdated:theEvent];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    NSImage *menuBarImage = [NSImage imageNamed:@"menubar"];
	
	[self setStatusImage:menuBarImage];
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return [dragHandler prepareForDragOperation:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return [dragHandler performDragOperation:sender];
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
    NSImage *menuBarImage = [NSImage imageNamed:@"menubar"];
	[self setStatusImage:menuBarImage];
    [self setNeedsDisplay:YES];
}


@end
