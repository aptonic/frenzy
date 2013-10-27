//
//  PopupMaskView.m
//  Frenzy
//
//  Created by John Winter on 6/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "PopupMaskView.h"


@implementation PopupMaskView


- (void)viewDidMoveToWindow 
{
    trackingRect = [self addTrackingRect:[self bounds] owner:self userData:NULL assumeInside:NO];
	
	if ([self hitTest:[[self window] mouseLocationOutsideOfEventStream]])
		[self mouseEntered:nil];
	else
		[self mouseExited:nil];
}

- (void)mouseEntered:(NSEvent *)theEvent 
{
	[[NSCursor arrowCursor] set];
	[[self window] disableCursorRects];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
	[[self window] enableCursorRects];
	[[self window] resetCursorRects];
}

- (void)mouseDown:(NSEvent *)theEvent
{   
	NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:theEvent, @"event", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseEvent" object:self userInfo:eventDict];
}

- (void)mouseDragged:(NSEvent *)theEvent
{   
	NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:theEvent, @"event", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseEvent" object:self userInfo:eventDict];
}

- (void)mouseUp:(NSEvent *)theEvent
{   
	NSDictionary *eventDict = [NSDictionary dictionaryWithObjectsAndKeys:theEvent, @"event", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MouseEvent" object:self userInfo:eventDict];
}

//- (void)drawRect:(NSRect)rect 
//{
//	// Draw top image edges
//	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.2] set];
//	NSRectFill(rect);
//}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent { return YES; }

- (void)dealloc
{
	[super dealloc];
}

@end
