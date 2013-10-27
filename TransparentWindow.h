//
//  TransparentWindow.h
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "StatusItem.h"
#import <WebKit/WebKit.h>

#define SCROLLVIEW_OFFSET 18
#define MESSAGE_BOX_HEIGHT 61

@class FrenzyAppDelegate;

@interface TransparentWindow : NSPanel {
	IBOutlet WebView *webView;
}

- (void)positionUnderStatusItem:(StatusItem *)statusItem arrow:(BOOL)arrow;
- (NSArray *)otherVisibleWindows:(BOOL)shouldCheckKey;

@end
