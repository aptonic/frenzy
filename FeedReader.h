//
//  FeedReader.h
//  Frenzy
//
//  Created by John Winter on 22/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FeedItem.h"
#import "JSON.h"
#import "Dropbox.h"
#import "FeedStorage.h"

@interface FeedReader : NSObject {
	NSMutableArray *userFeed;
	NSString *feedPath;
	NSString *feedName;
	NSString *uniqueID;
	NSString *sharedFolder;
}

@property (retain) NSMutableArray *userFeed;
@property (retain) NSString *feedName;
@property (retain) NSString *uniqueID;
@property (retain) NSString *sharedFolder;

- (FeedReader *)initWithFeedPath:(NSString *)aFeedPath;
- (void)grabFeedItems;
- (void)loadFeed;
- (NSString *)getFeedName;

@end
