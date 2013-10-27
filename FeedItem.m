//
//  FeedItem.m
//  Frenzy
//
//  Created by John Winter on 16/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FeedItem.h"
#import "FeedStorage.h"

@implementation FeedItem

@synthesize type, title, messages, files, filesDirectory, originalSender, originalItemID, to, url, avatarPath, itemTimestamp, feedName, replyTo, replyToID, replaces, uniqueID, itemID, clockSkew, sharedFolders, message;

- (FeedItem *)init
{
	self = [super init];
	
	if (self) {
		sharedFolders = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSDictionary *)getItemAsDict
{
	if (itemAsDictionaryCache)
		return itemAsDictionaryCache;
	
	NSMutableArray *dictKeys = [[NSMutableArray alloc] init];
	NSMutableArray *dictObjects = [[NSMutableArray alloc] init];
	
	[dictKeys addObject:@"type"];
	[dictObjects addObject:[self type]];
	
	if ([type isEqualToString:FeedItemURLType]) {
		[dictKeys addObject:@"title"];
		[dictObjects addObject:[self title]];
		[dictKeys addObject:@"url"];
		[dictObjects addObject:[self url]];
	}
	
	if (!IsEmpty([self messages])) {
		[dictKeys addObject:@"messages"];
		[dictObjects addObject:[self messages]];
	}
	
	if (!IsEmpty([self files])) {
		[dictKeys addObject:@"files"];
		[dictObjects addObject:[self files]];
	}
    
    if (!IsEmpty([self to])) {
        [dictKeys addObject:@"to"];
        [dictObjects addObject:[self to]];
    }
	
	if (!IsEmpty([self replyTo])) {
		[dictKeys addObject:@"replyTo"];
		[dictObjects addObject:[self replyTo]];
	}
	
	if (!IsEmpty([self message])) {
		[dictKeys addObject:@"message"];
		[dictObjects addObject:message];
	}
	
	if (!IsEmpty([self replyToID])) {
		[dictKeys addObject:@"replyToID"];
		[dictObjects addObject:[self replyToID]];
	}
	
	if (!IsEmpty([self replaces])) {
		[dictKeys addObject:@"replaces"];
		[dictObjects addObject:[self replaces]];
	}
	
	if (!IsEmpty([self filesDirectory])) {
		[dictKeys addObject:@"filesDirectory"];
		[dictObjects addObject:[self filesDirectory]];
	}
	
	if (!IsEmpty([self originalSender])) {
		[dictKeys addObject:@"originalSender"];
		[dictObjects addObject:[self originalSender]];
	}
	
	if (!IsEmpty([self originalItemID])) {
		[dictKeys addObject:@"originalItemID"];
		[dictObjects addObject:[self originalItemID]];
	}
		
	[dictKeys addObject:@"timestamp"];
	[dictObjects addObject:[NSNumber numberWithInt:itemTimestamp]];
	
	if (!IsEmpty([self itemID])) {
		[dictKeys addObject:@"uid"];
		[dictObjects addObject:itemID];
	}

	[dictKeys addObject:@"clockSkew"];
	[dictObjects addObject:[NSNumber numberWithInt:[self clockSkew]]];
	
	NSDictionary *itemDict = [NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys];
	[dictObjects release];
	[dictKeys release];
	itemAsDictionaryCache = [[NSDictionary alloc] initWithDictionary:itemDict];
	
	return itemDict;
}

- (int)itemTimestamp
{
	return itemTimestamp + clockSkew;
}

- (BOOL)isEqual:(id)other
{
	return [[self getItemAsDict] isEqualToDictionary:[other getItemAsDict]];
}

- (NSUInteger)hash
{
	return [[self getItemAsDict] hash];
}

- (NSComparisonResult)compareTimestamps:(id)other
{
	if ([self itemTimestamp] == [other itemTimestamp]) 
		return NSOrderedSame;
	
	if ([self itemTimestamp] < [other itemTimestamp])
		return NSOrderedAscending;
	else
		return NSOrderedDescending;
}

- (NSString *)actionText
{
	NSString *actionText;
	
	if ([self type] == nil) return @"Unknown action";
	
    NSString *displayedFeedName;
    
    if (!IsEmpty([self messages]))
        displayedFeedName = [[[FeedStorage sharedFeedStorage] feedNames] objectForKey:[self originalSender]];
    else
        displayedFeedName = [self feedName];
    
    if (IsEmpty(displayedFeedName)) displayedFeedName = @"Unknown sender";
    if ([[self originalSender] isEqualToString:@"1JDW1"]) displayedFeedName = @"John";
    
	if ([[self type] isEqualToString:FeedItemURLType] || [[self type] isEqualToString:FeedItemMessageType] || 
        [[self type] isEqualToString:FeedItemFileType]) {
		actionText = [displayedFeedName stringByAppendingString:@" shared"];
	} else {
		actionText = @"Unknown action";
	}
	
	return actionText;
}

- (NSString *)description
{
	NSMutableDictionary *descriptionDictionary = [NSMutableDictionary dictionaryWithDictionary:[self getItemAsDict]];
	NSDictionary *sharedFolderDict = [NSDictionary dictionaryWithObjects:
									  [NSArray arrayWithObjects:[self sharedFolders], nil] 
																 forKeys:[NSArray arrayWithObjects:@"sharedFolders", nil]];
	
	[descriptionDictionary addEntriesFromDictionary:sharedFolderDict];
	return [descriptionDictionary description];
}


- (NSString *)avatarPathForUniqueID:(NSString *)aUniqueID
{
    NSString *userAvatarPath;
    
    if (IsEmpty(aUniqueID)) return [[NSBundle mainBundle] pathForImageResource:@"empty-user"];
    if ([aUniqueID isEqualToString:@"1JDW1"]) return [[NSBundle mainBundle] pathForImageResource:@"creator"];
    
    // Look for avatar in this items shared folders with the given uniqueID
    
	for (NSString *sharedFolder in [self sharedFolders]) {
        
        NSString *sharedFolderFrenzyPath = [sharedFolder stringByAppendingPathComponent:@".frenzy"];
        
        userAvatarPath = [[sharedFolderFrenzyPath stringByAppendingPathComponent:aUniqueID] 
                          stringByAppendingPathComponent:@"avatar.png"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:userAvatarPath])
            return userAvatarPath;
    }
    
    return userAvatarPath;
}

- (void)recacheItemDict
{
    if (itemAsDictionaryCache) {
        [itemAsDictionaryCache release];
        itemAsDictionaryCache = nil;
    }
}

- (void)dealloc
{
	[itemAsDictionaryCache release];
	[replyToID release];
	[replaces release];
	[uniqueID release];
	[itemID release];
	[replyTo release];
	[type release];
	[title release];
	[files release];
	[filesDirectory release];
	[originalSender release];
	[originalItemID release];
	[message release];
	[messages release];
	[to release];
	[url release];
	[avatarPath release];
	[feedName release];
	[sharedFolders release];
	[super dealloc];
}

@end
