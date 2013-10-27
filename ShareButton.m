//
//  ShareButton.m
//  Frenzy
//
//  Created by John Winter on 13/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "ShareButton.h"


@implementation ShareButton

- (void)drawRect:(NSRect)rect 
{
	[super drawRect:rect];
	
	// Clear right button edge
	[[NSColor clearColor] set];
	NSRect blackRect2 = NSMakeRect([self frame].size.width-1, 0, 1, [self frame].size.height);
	NSRectFill(blackRect2);
}

@end
