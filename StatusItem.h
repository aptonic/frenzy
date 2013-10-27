//
//  StatusItem.h
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StatusItemView.h"

@interface StatusItem : NSObject {
	NSStatusItem *statusItem;
	NSImage *statusImage;
	IBOutlet NSMenu *mainMenu;
}

@property (retain) NSMenu *mainMenu;

- (NSRect)menuItemFrame;
- (void)setUnreadCount:(int)unreadCount;

@end
