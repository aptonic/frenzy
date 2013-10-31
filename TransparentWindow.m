//
//  TransparentWindow.m
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "TransparentWindow.h"
#import "FrenzyAppDelegate.h"

@implementation TransparentWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag 
{
    self = [super initWithContentRect:contentRect styleMask:NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
		[self setAlphaValue:1.0];
		[self setOpaque:NO];
		[self setLevel:NSStatusWindowLevel];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setHasShadow:NO];
		[self setIgnoresMouseEvents:NO];
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary];
    }
    return self;
}

- (void)resignKeyWindow
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoHide"] && [[self otherVisibleWindows:NO] count] <= 0) 
        [[NSApp delegate] hideWindow];
    
    [super resignKeyWindow];
}

- (NSArray *)otherVisibleWindows:(BOOL)shouldCheckKey
{
	NSArray *visibleWindows = [[NSApp windows] filteredArrayUsingPredicate:
							   [NSPredicate predicateWithFormat:@"isVisible == YES && title != 'Frenzy' && className != 'NSStatusBarWindow'"]];
	
	if (shouldCheckKey) {
		for (id aWindow in visibleWindows) {
			if ([aWindow isKeyWindow])
				return nil;
		}		
	}
	
	return visibleWindows;
}

- (BOOL)canBecomeKeyWindow 
{
    return YES;
}

- (BOOL)isKeyWindow
{
	return [super isKeyWindow];
}

- (BOOL)canBecomeMainWindow 
{
    return YES;
}

-(void)sendEvent:(NSEvent*)event
{
	NSRect webFrameMinusScrollBar = [[[[webView mainFrame] frameView] documentView] frame];
	
	if (NSLeftMouseDown == [event type]
		&& ![self isMainWindow]
		
		&& [webView mouse:[webView convertPoint:[event locationInWindow] fromView:nil] inRect:webFrameMinusScrollBar]) {
			[super sendEvent:event];
        }
	
	NSUInteger modifiers = [event modifierFlags];
	if ([event type] == NSFlagsChanged) {
		BOOL optionHeld = NO;
		if (modifiers & NSAlternateKeyMask)
			optionHeld = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteToggle" object:self 
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	[NSNumber numberWithBool:optionHeld], @"modifiers", nil]];	
	}
	
	[super sendEvent:event];
}

- (void)positionUnderStatusItem:(StatusItem *)statusItem arrow:(BOOL)arrow
{
	NSRect menuItemFrame = [statusItem menuItemFrame];
	
	int xOffset = (arrow ? -18 : 13);
	int yOffset = (arrow ? 0 : 5);
	
	menuItemFrame.origin.x = menuItemFrame.origin.x - [self frame].size.width / 2 + xOffset;
	menuItemFrame.origin.y = menuItemFrame.origin.y - [self frame].size.height + yOffset;

	[self setFrameOrigin:menuItemFrame.origin];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent { return YES; }

@end
