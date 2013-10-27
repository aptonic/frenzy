//
//  TextViewContainerBox.m
//  Frenzy
//
//  Created by John Winter on 13/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "TextViewContainerBox.h"


@implementation TextViewContainerBox

- (void)drawRect:(NSRect)rect 
{
	[super drawRect:rect];
	
	// Draw left TextView border
	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.4] set];
	NSRect blackRect = NSMakeRect(0, 0, 1, [self frame].size.height);
	NSRectFill(blackRect);
	
	// Draw right TextView border
	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.4] set];
	NSRect blackRect2 = NSMakeRect([self frame].size.width-1, 0, 1, [self frame].size.height);
	NSRectFill(blackRect2);
	
	[[NSColor clearColor] set];
	NSRect clearRect = NSMakeRect(0, 0, [self frame].size.width, 1);
	NSRectFill(clearRect);
	
	
	[[NSColor colorWithDeviceRed:0.65 green:0.65 blue:0.65 alpha:1] set];
	NSRect blackRect3 = NSMakeRect(1, 43, [self frame].size.width-2, 1);
	NSRectFill(blackRect3);
	
	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.4] set];
	NSRect blackRect4 = NSMakeRect(0, 0, [self frame].size.width, 1);
	NSRectFill(blackRect4);
}

@end
