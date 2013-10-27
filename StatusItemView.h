//
//  StatusItemView.h
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPasteboard+iTunes.h"

@class DragHandler;

@interface StatusItemView : NSView <NSMenuDelegate> {
	NSImage *statusImage;
	NSStatusItem *statusItem;
	NSMenu *mainMenu;
    DragHandler *dragHandler;
	BOOL isMouseDown;
	BOOL isMenuVisible;
	int unreadCount;
}

@property (retain) NSImage *statusImage;
@property (retain) NSStatusItem *statusItem;
@property (retain) NSMenu *mainMenu;
@property int unreadCount;

@end
