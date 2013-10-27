//
//  FeedStorage.h
//  Frenzy
//
//  Created by John Winter on 14/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Dropbox.h"
#import "FeedItem.h"
#import "FeedWriter.h"
#import "FeedReader.h"
#import "ShareFilesHelper.h"

#define MAX_ITEMS_DISPLAYED 25

@interface FeedStorage : NSObject {
	NSMutableDictionary *feedWriters;
	NSMutableDictionary *feedNames;
	NSMutableArray *feedReaders;
	NSMutableArray *partialFeedItems;
	NSArray *cachedFeedItems;
	FeedItem *lastFeedItem;
}

@property (retain) NSMutableArray *partialFeedItems;
@property (retain) NSArray *cachedFeedItems;
@property (retain) NSMutableDictionary *feedNames;
@property (retain) FeedItem *lastFeedItem;

- (void)addItem:(FeedItem *)feedItem toSharedFolders:(NSArray *)sharedFolders;
- (void)deleteItem:(FeedItem *)feedItem fromSharedFolders:(NSArray *)sharedFolders;
- (void)setupFeeds;
- (void)reSetupFeeds;
+ (FeedStorage *)sharedFeedStorage;
- (NSArray *)feedItems;
- (NSArray *)mergeMessages:(NSArray *)messageArray withMessageArray:(NSArray *)otherMessageArray;

@end
