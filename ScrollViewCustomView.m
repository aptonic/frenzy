//
//  ScrollViewCustomView.m
//  Frenzy
//
//  Created by John Winter on 22/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "ScrollViewCustomView.h"


@implementation ScrollViewCustomView

- (void)drawRect:(NSRect)rect 
{
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(1, 1, [self frame].size.width-2, [self frame].size.height-3));
}

@end
