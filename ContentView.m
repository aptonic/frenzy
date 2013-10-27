//
//  ContentView.m
//  Frenzy
//
//  Created by John Winter on 21/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "ContentView.h"


@implementation ContentView

@synthesize topImage;

- (void)awakeFromNib 
{
    [self setTopImage:[NSImage imageNamed:@"top.png"]];
}

- (void)drawRect:(NSRect)rect 
{
	[[NSColor lightGrayColor] set];
	
	NSShadow *mainShadow = [[[NSShadow alloc] init] autorelease];
	[mainShadow setShadowColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.8]];
	[mainShadow setShadowOffset:NSMakeSize(0, 2)];
	[mainShadow setShadowBlurRadius:22];    
	[mainShadow set];
	NSRectFill(NSMakeRect(21, 18, [self frame].size.width - 43, [self frame].size.height - 73));

	NSShadow *bottomShadow = [[[NSShadow alloc] init] autorelease];
	[bottomShadow setShadowColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3]];
	[bottomShadow setShadowOffset:NSMakeSize(0, -5)];
	[bottomShadow setShadowBlurRadius:22];    
	[bottomShadow set];
	
	NSRectFill(NSMakeRect(18, 25, [self frame].size.width - 35, 8));
	
	NSShadow *blankShadow = [[[NSShadow alloc] init] autorelease];
	[blankShadow set];
	
	// Left WebView border
	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.35] set];
	NSRect blackRect = NSMakeRect(17, 61, 1, [self frame].size.height-109);
	NSRectFill(blackRect);
	
	// Right WebView border
	[[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.35] set];
	NSRect blackRect2 = NSMakeRect(346, 61, 1, [self frame].size.height-109);
	NSRectFill(blackRect2);
	
	[topImage drawAtPoint:NSMakePoint(5, [self frame].size.height - [topImage size].height - 4) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent { return YES; }

@end
