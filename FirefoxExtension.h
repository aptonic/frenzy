//
//  FirefoxExtension.h
//  Frenzy
//
//  Created by John Winter on 30/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProcessRunning.h"

#define EXTENSION_NAME = @"frenzy@frenzyapp.com"
extern NSString *const ExtensionName;


@interface FirefoxExtension : NSObject {
	NSString *firefoxDir;
}

- (BOOL)isFirefoxInstalled;
- (void)installExtension;
- (void)showError:(NSError *)error withDescription:(NSString *)aDescription;

@end
