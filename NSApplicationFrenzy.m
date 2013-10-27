//
//  NSApplicationFrenzy.m
//  Frenzy
//
//  Created by John Winter on 3/02/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "NSApplicationFrenzy.h"


@implementation NSApplicationFrenzy

@synthesize currentModalWindow;

-(NSModalSession)beginModalSessionForWindow:(NSWindow *)window 
{
	NSModalSession session = [super beginModalSessionForWindow:window];	
	[window setLevel:NSStatusWindowLevel+3];
    [[[PrefsController prefsController] window] setLevel:NSNormalWindowLevel];
	[window center];
	[window makeKeyAndOrderFront:self];
    [self setCurrentModalWindow:window];
	return session;
}

- (void)endModalSession:(NSModalSession)session
{
    [self setCurrentModalWindow:nil];
    [[[PrefsController prefsController] window] setLevel:NSStatusWindowLevel+1];
    [super endModalSession:session];
}

- (void)sendEvent:(NSEvent *)anEvent
{	   
	if ([anEvent type] == NSKeyDown && ([anEvent modifierFlags] & NSCommandKeyMask) 
		&& [[anEvent characters] isEqualToString:@","]) {
		[PrefsController showPrefs];
	} else if ([anEvent type] == NSKeyDown && ([anEvent modifierFlags] & NSCommandKeyMask) && [[anEvent characters] isEqualToString:@"h"]) {
        [appDelegate hideWindow];
	} else if ([anEvent type] == NSKeyDown && ([anEvent modifierFlags] & NSCommandKeyMask) && [[anEvent characters] isEqualToString:@"q"]) {
        [NSApp terminate:nil];
    }
    
	[super sendEvent:anEvent];
    

}

@end
