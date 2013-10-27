//
//  ApplicationConnectors.m
//  Frenzy
//
//  Created by John Winter on 1/10/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "ApplicationConnectors.h"


@implementation ApplicationConnectors

- (ApplicationConnectors *)init
{
	self = [super init];
	
	if (self) {
		NSString *connectorsPath = [[NSBundle mainBundle] 
									pathForResource:@"ApplicationConnectors" ofType:@"plist"];
		
		connectorsDict = [[NSMutableDictionary alloc] initWithContentsOfFile:connectorsPath];
	}
	return self;
}

- (NSAppleScript *)appleScriptForActiveApplication
{
	NSString *appID = [[[[NSWorkspace sharedWorkspace] activeApplication] objectForKey:@"NSApplicationBundleIdentifier"] lowercaseString];
	NSString *source = [[connectorsDict objectForKey:appID] objectForKey:@"AppleScript"];
	
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:source];
	return [appleScript autorelease];
}

- (NSArray *)parseConnectorOutput:(NSString *)output
{
	NSArray *components = [output componentsSeparatedByString:@"\r"];
	NSMutableArray *items = [NSMutableArray array];
	
	for (NSString *line in components) {
		NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
		
		NSArray *lineComponents = [[line stringByTrimmingCharactersInSet:
									[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\"]"];
		
		NSString *urlPart = [lineComponents objectAtIndex:0];
		NSMutableString *lastPartCombined = [NSMutableString string];
		
		int i;
		
		for (i=1; i < [lineComponents count]; i++) {
			[lastPartCombined appendString:[lineComponents objectAtIndex:i]];
			if (i != [lineComponents count] - 1) [lastPartCombined appendString:@"\"]"];
		}
		
		// Check if filepath or url
		NSArray *urlPartSplit = [urlPart componentsSeparatedByString:@"=\""];
		NSString *itemType = [[urlPartSplit objectAtIndex:0] 
							  substringWithRange:NSMakeRange(1, [[urlPartSplit objectAtIndex:0] length]-1)];
		
		NSString *title;
		NSString *path;
		
		if ([itemType isEqualToString:@"url"]) {
			title = [lastPartCombined substringWithRange:NSMakeRange(0, [lastPartCombined length] - 6)];
			path = [urlPart substringWithRange:NSMakeRange(6, [urlPart length] - 6)];
		} else if ([itemType isEqualToString:@"filepath"]) {
			title = [lastPartCombined substringWithRange:NSMakeRange(0, [lastPartCombined length] - 11)];
			path = [urlPart substringWithRange:NSMakeRange(11, [urlPart length] - 11)];
		} else {
			NSLog(@"ERROR: Invalid item type: %@", itemType);
		}
		
		[infoDict setValue:itemType forKey:@"type"];
		[infoDict setValue:title forKey:@"title"];
		[infoDict setValue:path forKey:@"path"];
		[items addObject:infoDict];
	}
	
	return items;
}

- (void)dealloc
{
	[connectorsDict release];
	[super dealloc];
}

@end
