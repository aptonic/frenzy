//
//  StatusItem.m
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "StatusItem.h"


@implementation StatusItem

@synthesize mainMenu;

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];

	StatusItemView *statusItemView = [[StatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 26, 16)];
	
	[statusItemView setStatusItem:statusItem];
	[statusItemView setMainMenu:mainMenu];
	[statusItem setView:statusItemView];
	
	[statusItemView release];
}

- (void)setUnreadCount:(int)unreadCount
{
	NSImage *menuBarImage;
	
	if (unreadCount <= 0)
		menuBarImage = [NSImage imageNamed:@"menubar"];
	else
		menuBarImage = [NSImage imageNamed:@"menubar-e"];
	
	[(StatusItemView *)[statusItem view] setUnreadCount:unreadCount];
	[(StatusItemView *)[statusItem view] setStatusImage:menuBarImage];
	[[statusItem view] setNeedsDisplay:YES];
}

- (NSRect)menuItemFrame
{
	return [[[statusItem view] window] frame];
}

@end
