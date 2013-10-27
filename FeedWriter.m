//
//  FeedWriter.m
//  Frenzy
//
//  Created by John Winter on 22/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FeedWriter.h"


@implementation FeedWriter

@synthesize userFeed;

- (FeedWriter *)initWithFeedPath:(NSString *)aFeedPath
{
	self = [super init];
	
	if (self) {
		userFeed = [[NSMutableArray alloc] init];
		feedPath = [[NSString alloc] initWithString:aFeedPath];
	}
	return self;
}

- (void)loadFeed
{
	NSString *userFeedContents = [[NSString stringWithContentsOfFile:[feedPath stringByAppendingPathComponent:@"feed.json"] 
															encoding:NSUTF8StringEncoding error:nil] 
								  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (!IsEmpty(userFeedContents)) [self setUserFeed:[userFeedContents JSONValue]];
}

- (void)addItem:(FeedItem *)feedItem
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[self loadFeed];
	
	[feedItem setItemTimestamp:[[NSDate date] timeIntervalSince1970]];
	
	int clockSkew = 0;
	
	if ([defaults objectForKey:@"clockSkew"] != nil)
		clockSkew = [[defaults objectForKey:@"clockSkew"] intValue];
			
	[feedItem setClockSkew:clockSkew];
	[feedItem setItemID:[[[Dropbox sharedDropbox] uniqueID] stringByAppendingFormat:@"%d",[feedItem itemTimestamp]]];
	
	NSMutableDictionary *feedItemDict = [[NSMutableDictionary alloc] initWithDictionary:[feedItem getItemAsDict]];
	[[self userFeed] addObject:feedItemDict];
	[self saveFeed];
	[feedItemDict release];
}

- (void)deleteItem:(FeedItem *)feedItem
{
	[self loadFeed];
	[[self userFeed] removeObject:[feedItem getItemAsDict]];
	[self saveFeed];
}

- (void)saveFeed
{
	NSError *err;
	BOOL wroteFile;
	
	NSMutableArray *feedItems = [self userFeed];
	
	// Get the last ITEMS_PER_FEED items to save in the main feed	 
	int location = [feedItems count] - ITEMS_PER_FEED;
	location = (location < 0 ? 0 : location);
	
	NSArray *latestItems = [feedItems subarrayWithRange:NSMakeRange(location, [feedItems count] - location)];
	
	
	wroteFile = [[latestItems JSONRepresentation] writeToFile:[feedPath stringByAppendingPathComponent:@"feed.json"]
												   atomically:YES encoding:NSUTF8StringEncoding error:&err];
	
	if (!wroteFile)
		NSLog(@"Failed writing: %@", err);
	
	// Anything before this ITEMS_PER_FEED gets saved to archives
	NSArray *pastItems = [feedItems subarrayWithRange:NSMakeRange(0, location)];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *archivesFolder = [feedPath stringByAppendingPathComponent:@"archives"];
	
	if ([pastItems count] > 0) {
		// Ensure archives folder exists
		if (![fileManager fileExistsAtPath:archivesFolder]) {
			err = nil;
            if (![fileManager createDirectoryAtPath:archivesFolder 
						withIntermediateDirectories:NO attributes:nil error:&err]) {
				NSLog(@"Failed to create feed archive folder");
				return;
			}
			
		}	
	} else {
		// Must have less than ITEMS_PER_FEED in main feed, no archiving required
		return;
	}
	
	int archiveNumber = [self getArchiveNumber];
	NSMutableArray *archiveItems = [NSMutableArray array];
	
	
	NSString *archiveFeedContents = [[NSString stringWithContentsOfFile:[archivesFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"archive%d.json", archiveNumber]] 
															   encoding:NSUTF8StringEncoding error:nil] 
									 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (![archiveFeedContents isEqualToString:@""]) [archiveItems addObjectsFromArray:[archiveFeedContents JSONValue]];
	
	
	for (NSDictionary *item in pastItems) {
		if ([archiveItems count] >= ITEMS_PER_FEED) {
			// Write out items and start a new archive
			
			wroteFile = [[archiveItems JSONRepresentation] writeToFile:[archivesFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"archive%d.json", archiveNumber]]
															atomically:YES encoding:NSUTF8StringEncoding error:&err];
			
			if (!wroteFile)
				NSLog(@"Failed writing archive: %@", err);
			
			archiveNumber += 1;
			[archiveItems removeAllObjects];
		}
		
		[archiveItems addObject:item];
	}
	// Write out items
	wroteFile = [[archiveItems JSONRepresentation] writeToFile:[archivesFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"archive%d.json", archiveNumber]]
													atomically:YES encoding:NSUTF8StringEncoding error:&err];
	
	[self saveArchiveNumber:archiveNumber];
	
	if (!wroteFile)
		NSLog(@"Failed writing archive: %@", err);
	
}

- (int)getArchiveNumber
{
	NSString *infoPath = [[feedPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"info.json"];
	NSString *userInfoContents = [[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil] 
								  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (!IsEmpty(userInfoContents)) {
		NSDictionary *infoDict = [userInfoContents JSONValue];
		return [[infoDict objectForKey:@"archiveNumber"] intValue];
	} else {
		return 1;
	}
}

- (void)saveArchiveNumber:(int)archiveNumber
{
	NSString *infoPath = [[feedPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"info.json"];
	NSString *userInfoContents = [[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil] 
								  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSMutableDictionary *infoDict;
	
	if (!IsEmpty(userInfoContents)) {
		 infoDict = [userInfoContents JSONValue];
		[infoDict setObject:[NSNumber numberWithInt:archiveNumber] forKey:@"archiveNumber"];
	} else {
		NSLog(@"info.json found empty when trying to write archiveNumber!");
		return;
	}
	
	NSError *err;
	BOOL wroteFile;
	
	wroteFile = [[infoDict JSONRepresentation] writeToFile:infoPath
												atomically:YES encoding:NSUTF8StringEncoding error:&err];
	
	if (!wroteFile)
		NSLog(@"Failed writing (archiveNumber) info.json to path %@:\n%@", infoPath, err);
}

- (void)dealloc
{
	[feedPath release];
	[userFeed release];
	[super dealloc];
}

@end
