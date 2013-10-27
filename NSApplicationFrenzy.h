//
//  NSApplicationFrenzy.h
//  Frenzy
//
//  Created by John Winter on 3/02/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrefsController.h"
#import "FrenzyAppDelegate.h"

@interface NSApplicationFrenzy : NSApplication {
	IBOutlet FrenzyAppDelegate *appDelegate;
    NSWindow *currentModalWindow;
}

@property (retain) NSWindow *currentModalWindow;

@end
