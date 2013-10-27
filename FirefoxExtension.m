//
//  FirefoxExtension.m
//  Frenzy
//
//  Created by John Winter on 30/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FirefoxExtension.h"

NSString *const ExtensionName = @"frenzy@frenzyapp.com";

@implementation FirefoxExtension

- (FirefoxExtension *)init
{
	self = [super init];
	
	if (self) {
		firefoxDir = [[NSString alloc] initWithString:[@"~/Library/Application Support/Firefox/Profiles" stringByExpandingTildeInPath]];
	}
	return self;
}

- (BOOL)isFirefoxInstalled
{
	// If there is a ~/Library/Application Support/Firefox/Profiles folder then it is, otherwise not
	if ([[NSFileManager defaultManager] fileExistsAtPath:firefoxDir])
        return YES;
	else
		return NO;
}

- (void)installExtension
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *err = nil;
	
	// Check Firefox is closed and if not prompt the user to close it
	ProcessRunning *procRunning = [[ProcessRunning alloc] init];
	
	[procRunning obtainFreshProcessList];
	BOOL isRunning = [procRunning findProcessWithName:@"firefox-bin"];
	
	int result;
	
	if (isRunning) {
		result = NSRunAlertPanel(@"Firefox is Running", 
									 @"You have to quit the Firefox browser to continue.", 
									 @"Ask Firefox to quit",  @"Cancel update",@"Continue", nil);
		
		if (result == NSAlertDefaultReturn) {
			NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Firefox\" to quit"];
			[script executeAndReturnError:nil];
			[script release];
		} else if (result == NSAlertOtherReturn) {
			[self installExtension];
			return;
		} else if (result == NSAlertAlternateReturn) {
			return;
		}
	}
		
	// Copy Frenzy.app/Contents/Extensions/ to ~/Library/Application Support/Frenzy/
	NSArray *searchpaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *destinationExtensionsFolder;
    if ([searchpaths count] > 0) {
        // Look for the library folder (and create if not there)
        NSString *path = [[searchpaths objectAtIndex:0] stringByAppendingPathComponent:@"Frenzy"];

        if (![fileManager fileExistsAtPath:path]) {
			err = nil;
            if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&err]) {
				[self showError:err withDescription:@"Failed to create Frenzy folder in Application Support"];
				return;
			}
			
		}	
		
		NSString *extensionsPath = [[[NSBundle mainBundle] bundlePath] 
									stringByAppendingPathComponent:@"Contents/Extensions"];
		
		destinationExtensionsFolder = [path stringByAppendingPathComponent:@"Extensions"];
		
		// Remove the Extensions folder
		if ([fileManager fileExistsAtPath:destinationExtensionsFolder]) {
			err = nil;
			if (![fileManager removeItemAtPath:destinationExtensionsFolder error:&err])
				NSLog(@"WARNING: Failed to remove old Extensions folder at path %@\n%@", destinationExtensionsFolder, [err description]);
		}
		
		if ([fileManager fileExistsAtPath:extensionsPath]) {
			err = nil;
			if (![fileManager copyItemAtPath:extensionsPath toPath:destinationExtensionsFolder error:&err]) {
				[self showError:err withDescription:@"Failed to copy Extensions folder from application bundle to Application Support folder"];
				return;
			}
		} else {
			[self showError:nil withDescription:[@"Could not find extension to install in " stringByAppendingString:extensionsPath]];
			return;
		}
	}
	
	// Find the users Firefox profile directory by getting the first directory in
	// ~/Library/Application Support/Firefox/Profiles/ that has a suffix of default
	// and contains an extensions folder
	NSString *filename;
	NSString *profileDirExtensionPath;
	
	err = nil;
	NSArray *profileDirs = [fileManager contentsOfDirectoryAtPath:firefoxDir error:&err];
	if (!profileDirs) {
		[self showError:err withDescription:[@"Failed to get contents of Firefox profile directory at\n" 
											 stringByAppendingPathComponent:firefoxDir]];
		return;
	}
	
	BOOL profileDirFound = NO;
	
	for (filename in profileDirs) {
		profileDirExtensionPath = [[firefoxDir stringByAppendingPathComponent:filename] 
								   stringByAppendingPathComponent:@"extensions"];
		
		if ([filename characterAtIndex:0] == '.')
			continue;
		
		if ([filename hasSuffix:@"default"] && [fileManager fileExistsAtPath:profileDirExtensionPath]) {
			profileDirFound = YES;
			break;
		}
	}
	
	NSString *extensionPath = [destinationExtensionsFolder stringByAppendingPathComponent:ExtensionName];
	
	if (!profileDirFound) {
		[self showError:nil withDescription:@"Firefox profile directory not found"];
		return;
	}
	
	NSString *extensionFileToWrite = [profileDirExtensionPath stringByAppendingPathComponent:ExtensionName];
	
	err = nil;
	BOOL writeResult = [extensionPath writeToFile:extensionFileToWrite
									   atomically:YES encoding:NSUTF8StringEncoding error:&err];
	
	if (!writeResult) {
		[self showError:err withDescription:[@"Failed to write extension file to\n" 
											 stringByAppendingPathComponent:extensionFileToWrite]];
		return;
	}
	
	[procRunning release];
}

- (void)showError:(NSError *)error withDescription:(NSString *)aDescription
{
	NSString *finalErrorString;
	NSString *errorString = [NSString stringWithFormat:@"\n\n%@", aDescription];
	
	// Tack on NSError description if provided
	if (error != nil) 
		finalErrorString = [NSString stringWithFormat:@"%@\n\n%@", errorString, [error description]];
	else
		finalErrorString = errorString;
	
	NSRunCriticalAlertPanel(@"Extension Installation Failed", 
							[@"The Firefox extension failed to install." stringByAppendingString:finalErrorString], 
							@"OK", nil, nil);
}

- (void)dealloc
{
	[firefoxDir release];
	[super dealloc];
}

@end
