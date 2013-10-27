//
//  FeedStorage.m
//  Frenzy
//
//  Created by John Winter on 14/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FeedStorage.h"
#import "FrenzyAppDelegate.h"

BOOL isFirstLoad = YES;

@implementation FeedStorage

@synthesize partialFeedItems, lastFeedItem, feedNames, cachedFeedItems;

- (FeedStorage *)init
{
	self = [super init];
	
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(clearUnreadCount) name:@"ClearUnreadCount" object:nil];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		if ([defaults objectForKey:@"latestItemTimestamp"] == nil)
			[defaults setObject:[NSNumber numberWithInt:0] forKey:@"latestItemTimestamp"];
		
		partialFeedItems = [[NSMutableArray alloc] init];
		feedNames = [[NSMutableDictionary alloc] init];
		
		[self setupFeeds];
	}
	return self;
}

+ (FeedStorage *)sharedFeedStorage
{  
	static FeedStorage *sharedFeedStorage;
	
	if (!sharedFeedStorage) {
		sharedFeedStorage = [[FeedStorage alloc] init];
	}
	return sharedFeedStorage;
}

- (void)reSetupFeeds
{
	[feedWriters release];
	[feedReaders release];
	[self setupFeeds];
}

// Create a FeedWriter for each shared folder and a FeedReader for every unique folder
// ID for ever shared folder
- (void)setupFeeds
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	feedWriters = [[NSMutableDictionary alloc] init];
	feedReaders = [[NSMutableArray alloc] init];
	
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	  
	NSString *uniqueID = [sharedDropbox uniqueID];

	for (NSString *sharedFolder in [sharedDropbox activeSharedFoldersFullPaths]) {
   
		NSString *sharedFolderFrenzyPath = [sharedFolder stringByAppendingPathComponent:@".frenzy"];
        
		NSString *fullFeedPath = [[sharedFolderFrenzyPath stringByAppendingPathComponent:uniqueID]
								   stringByAppendingPathComponent:@"feeds"];
		
		FeedWriter *feedWriter = [[FeedWriter alloc] initWithFeedPath:fullFeedPath];
		[feedWriters setObject:feedWriter forKey:sharedFolder];
		[feedWriter release];
		
		NSString *filename;
		NSString *uniqueFeedPath;
		
		NSError *err = nil;
		NSArray *frenzyUniqueDirs = [fileManager contentsOfDirectoryAtPath:sharedFolderFrenzyPath error:&err];
		
		if (!frenzyUniqueDirs) {
			NSLog(@"ERROR: Failed to get contents of .frenzy directory at %@\n%@", sharedFolderFrenzyPath, [err description]);
			continue;
		}
		
		for (filename in frenzyUniqueDirs) {
			uniqueFeedPath = [[sharedFolderFrenzyPath stringByAppendingPathComponent:filename] 
									   stringByAppendingPathComponent:@"feeds"];
			
			if ([filename characterAtIndex:0] == '.')
				continue;
			
			if ([fileManager fileExistsAtPath:uniqueFeedPath]) {
				// Create FeedReader if the feeds directory exists
				FeedReader *feedReader = (FeedReader *)[[FeedReader alloc] initWithFeedPath:uniqueFeedPath];
				[feedReader setSharedFolder:sharedFolder];
				[feedReader setUniqueID:filename];
				[feedReaders addObject:feedReader];
				[[self feedNames] setObject:[feedReader getFeedName] forKey:[feedReader uniqueID]];
				[feedReader release];
			}
		}
	}
}

- (void)addItem:(FeedItem *)feedItem toSharedFolders:(NSArray *)sharedFolders
{
    for (NSString *sharedFolder in sharedFolders) {
		FeedWriter *feedWriter = [feedWriters objectForKey:sharedFolder];
		[feedWriter addItem:feedItem];
	}
}

- (void)deleteItem:(FeedItem *)feedItem fromSharedFolders:(NSArray *)sharedFolders
{
	if (IsEmpty([feedItem replaces]))
		[[ShareFilesHelper sharedFilesHelper] deleteFilesForFeedItem:feedItem];
	
	for (NSString *sharedFolder in sharedFolders) {
		FeedWriter *feedWriter = [feedWriters objectForKey:sharedFolder];
		[feedWriter deleteItem:feedItem];
	}
}

- (NSArray *)feedItems
{	
	[self setPartialFeedItems:nil];
	partialFeedItems = [[NSMutableArray alloc] init];
	
	for (FeedReader *feedReader in feedReaders)
		[feedReader grabFeedItems];
	   
	[partialFeedItems sortUsingSelector:@selector(compareTimestamps:)];
	
   	FeedItem *lastItem = nil;
    int newItemCount = 0;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int latestItemTimestamp = [[defaults objectForKey:@"latestItemTimestamp"] intValue];
	
	if (!isFirstLoad || latestItemTimestamp != 0) {	
		// Figure out which items are new by getting all items since latestItemTimestamp
		for (FeedItem *item in partialFeedItems) {
			if (![[item feedName] isEqualToString:@"You"]) {
				if ([item itemTimestamp] > latestItemTimestamp) 
					newItemCount++;
				
				lastItem = item;
			}
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UnreadItemsUpdated" object:self 
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSNumber numberWithInt:newItemCount], @"unreadCount", nil]];
    
	NSMutableArray *replacedIDs = [NSMutableArray array];
	NSMutableArray *finalArray = [NSMutableArray array];
    
	for (FeedItem *item in [partialFeedItems reverseObjectEnumerator]) {
		if ([item replaces] != nil) {
			[replacedIDs addObject:[item replaces]];
		}
		
		if (![replacedIDs containsObject:[item itemID]]) {
            for (FeedItem *existingFeedItem in [[[partialFeedItems copy] autorelease] reverseObjectEnumerator]) {
                // See if there is another feed item already added with this originalItemID

                if ([[existingFeedItem originalItemID] isEqualToString:[item originalItemID]] && 
                    [[existingFeedItem sharedFolders] isEqual:[item sharedFolders]]) {
                    
                    NSArray *messages = [self mergeMessages:[item messages] withMessageArray:[existingFeedItem messages]];
                    if (messages != nil) {
                        [finalArray removeObject:existingFeedItem];

                        [item setMessages:messages];
                        [item setItemTimestamp:[[[messages lastObject] objectForKey:@"timestamp"] intValue]];
                    }
                }
            }
            
            [finalArray addObject:item];
        }
	}
    
    [finalArray sortUsingSelector:@selector(compareTimestamps:)];
    finalArray = [NSMutableArray arrayWithArray:[[finalArray reverseObjectEnumerator] allObjects]];
    
	int location = ([finalArray count] < MAX_ITEMS_DISPLAYED ? [finalArray count] : MAX_ITEMS_DISPLAYED);
	NSArray *limitedArray = [finalArray subarrayWithRange:NSMakeRange(0, location)]; 
	
	[self setLastFeedItem:lastItem];
	
	isFirstLoad = NO;
	
	[self setCachedFeedItems:limitedArray];
	return limitedArray;
}

- (NSArray *)mergeMessages:(NSArray *)messageArray withMessageArray:(NSArray *)otherMessageArray
{
    NSMutableArray *messages = [NSMutableArray arrayWithArray:otherMessageArray];
    
    for (NSDictionary *message in messageArray) {
        BOOL foundMessage = NO;
        for (NSDictionary *messageCompare in otherMessageArray) {
            if (IsEmpty([message objectForKey:@"timestamp"]) || IsEmpty([messageCompare objectForKey:@"timestamp"])) 
                return nil;
            
            if ([[message objectForKey:@"sender"] isEqual:[messageCompare objectForKey:@"sender"]] && 
                [[message objectForKey:@"message"] isEqual:[messageCompare objectForKey:@"message"]] &&
                [[message objectForKey:@"timestamp"] isEqual:[messageCompare objectForKey:@"timestamp"]]) {
                foundMessage = YES;
                break;
            }
        }
        if (!foundMessage) {
            [messages addObject:message];
        }
    }
    
    return messages;
}

- (void)clearUnreadCount
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UnreadItemsUpdated" object:self 
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSNumber numberWithInt:0], @"unreadCount", nil]];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	int latestItemTimestamp = ([self lastFeedItem] == nil ? 0 : [[self lastFeedItem] itemTimestamp]);
	
	[defaults setObject:[NSNumber numberWithInt:latestItemTimestamp] forKey:@"latestItemTimestamp"];
	[defaults synchronize];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[partialFeedItems release];
	[cachedFeedItems release];
	[feedNames release];
	[feedWriters release];
	[lastFeedItem release];
	[super dealloc];
}

@end
