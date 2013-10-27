//
//  FeedReader.m
//  Frenzy
//
//  Created by John Winter on 22/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FeedReader.h"


@implementation FeedReader

@synthesize userFeed, feedName, uniqueID, sharedFolder;

- (FeedReader *)initWithFeedPath:(NSString *)aFeedPath
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
	[self setFeedName:[self getFeedName]];
}

- (NSString *)getFeedName
{
	if ([[self uniqueID] isEqualToString:[[Dropbox sharedDropbox] uniqueID]]) return @"You";
	
	NSString *infoPath = [[feedPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"info.json"];
	NSString *userInfoContents = [[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil] 
								  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (!IsEmpty(userInfoContents)) {
		NSDictionary *infoDict = [userInfoContents JSONValue];
		return [infoDict objectForKey:@"name"];
	} else {
		return @"Unknown";
	}
}

- (void)grabFeedItems
{
	[self loadFeed];
	
	for (NSDictionary *item in [self userFeed]) {
		FeedItem *feedItem = [[FeedItem alloc] init];
		if ([[item allKeys] containsObject:@"type"]) [feedItem setType:[item objectForKey:@"type"]];
		if ([[item allKeys] containsObject:@"title"]) [feedItem setTitle:[item objectForKey:@"title"]];
		if ([[item allKeys] containsObject:@"message"]) [feedItem setMessage:[item objectForKey:@"message"]];
		if ([[item allKeys] containsObject:@"messages"]) [feedItem setMessages:[item objectForKey:@"messages"]];
		if ([[item allKeys] containsObject:@"files"]) [feedItem setFiles:[item objectForKey:@"files"]];
		if ([[item allKeys] containsObject:@"filesDirectory"]) [feedItem setFilesDirectory:[item objectForKey:@"filesDirectory"]];
		if ([[item allKeys] containsObject:@"originalSender"]) [feedItem setOriginalSender:[item objectForKey:@"originalSender"]];
		if ([[item allKeys] containsObject:@"originalItemID"]) [feedItem setOriginalItemID:[item objectForKey:@"originalItemID"]];
		if ([[item allKeys] containsObject:@"to"]) [feedItem setTo:[item objectForKey:@"to"]];
		if ([[item allKeys] containsObject:@"replyTo"]) [feedItem setReplyTo:[item objectForKey:@"replyTo"]];
		if ([[item allKeys] containsObject:@"replyToID"]) [feedItem setReplyToID:[item objectForKey:@"replyToID"]];
		if ([[item allKeys] containsObject:@"replaces"]) [feedItem setReplaces:[item objectForKey:@"replaces"]];
		if ([[item allKeys] containsObject:@"url"]) [feedItem setUrl:[item objectForKey:@"url"]];
		
		int clockSkew = 0;
		
		if ([[item allKeys] containsObject:@"clockSkew"]) {
			clockSkew = [[item objectForKey:@"clockSkew"] intValue];
			[feedItem setClockSkew:clockSkew];
		}
			
		if ([[item allKeys] containsObject:@"timestamp"]) [feedItem setItemTimestamp:[[item objectForKey:@"timestamp"] intValue]];
		if ([[item allKeys] containsObject:@"uid"]) [feedItem setItemID:[item objectForKey:@"uid"]];
		[feedItem setAvatarPath:[[feedPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"avatar.png"]];
		[feedItem setFeedName:[self feedName]];
		[feedItem setUniqueID:[self uniqueID]];
		
		[[feedItem sharedFolders] addObject:[self sharedFolder]];
		
		NSMutableArray *feedItems = [[FeedStorage sharedFeedStorage] partialFeedItems];
		
		BOOL foundDuplicate = NO;
		
		for (FeedItem *existingFeedItem in feedItems) {
			if ([existingFeedItem isEqual:feedItem]) {
				[[existingFeedItem sharedFolders] addObject:[self sharedFolder]];
				foundDuplicate = YES;
				break;
			}
		}
		
		if (!foundDuplicate) [feedItems addObject:feedItem];
        
		[feedItem release];
	}
}

- (void)dealloc
{
	[uniqueID release];
	[feedName release];
	[feedPath release];
	[userFeed release];
	[super dealloc];
}

@end
