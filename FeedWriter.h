//
//  FeedWriter.h
//  Frenzy
//
//  Created by John Winter on 22/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSON.h"
#import "FeedItem.h"

#define ITEMS_PER_FEED 30

@interface FeedWriter : NSObject {
	NSMutableArray *userFeed;
	NSString *feedPath;
}

@property (retain) NSMutableArray *userFeed;

- (FeedWriter *)initWithFeedPath:(NSString *)aFeedPath;
- (void)addItem:(FeedItem *)feedItem;
- (void)deleteItem:(FeedItem *)feedItem;

- (void)loadFeed;
- (void)saveFeed;

- (int)getArchiveNumber;
- (void)saveArchiveNumber:(int)archiveNumber;

@end
