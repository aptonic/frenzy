//
//  LoginItem.m
//  Frenzy
//
//  Created by John Winter on 8/08/09.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "LoginItem.h"


@implementation LoginItem

// Makes sure that this background app is in the login items, so that it will
// stay running in the future.
+ (void)ensureAutoLaunch:(BOOL)install
{
	NSString* appPath = [[NSBundle mainBundle] bundlePath];
	if (LSSharedFileListCreate != NULL) {
		
		LSSharedFileListRef loginList = LSSharedFileListCreate(NULL,
															   kLSSharedFileListSessionLoginItems,
															   NULL);
		if (!loginList) {
			NSLog(@"Could not get a reference to login items list");
			return;
		}
		
		UInt32 seed;
		NSArray *items = (NSArray *)LSSharedFileListCopySnapshot(loginList, &seed);
		
		// Remove any duplicates - LSSharedFileListInsertItemURL only handles dupes that have the same file URL
		// This doesn't handle a case where the user runs the app initially from one directory and then later runs it from elsewhere
		// as the URL will be different. Therefore we remove *any* items called 'Frenzy' first
		for (id item in items) {
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
			CFStringRef itemName = LSSharedFileListItemCopyDisplayName(itemRef);
			
			if ([(NSString *)itemName isEqualToString:@"Frenzy"]) {
				OSStatus error = LSSharedFileListItemRemove(loginList, itemRef);
				if (error != noErr)
					NSLog(@"Failed to remove App from Session Login Items");
			}
			CFRelease(itemName);
		}
		
		if (install) {
			LSSharedFileListItemRef item =  LSSharedFileListInsertItemURL(loginList, kLSSharedFileListItemLast,
																		  NULL, NULL,
																		  (CFURLRef)[NSURL fileURLWithPath:appPath],
																		  NULL, NULL);
			if (item){
				CFRelease(item);
			}
			
		}
		
		CFRelease(loginList);
		[items release];
	}
}

@end
