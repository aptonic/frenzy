//
//  FeedItem.h
//  Frenzy
//
//  Created by John Winter on 16/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Dropbox.h"

#define FeedItemURLType @"link"
#define FeedItemMessageType @"message"
#define FeedItemReplyType @"reply"
#define FeedItemFileType @"files"

@interface FeedItem : NSObject {
	int itemTimestamp;
	int clockSkew;
	NSString *type;
	NSString *title;
	NSArray *messages;
	NSArray *files;
	NSString *filesDirectory;
	NSString *originalSender;
	NSString *originalItemID;
	NSString *message;
	NSArray *to;
	NSString *url;
	NSString *avatarPath;
	NSString *feedName;
	NSString *replyTo;
	NSString *replyToID;
	NSString *replaces;
	NSString *uniqueID;
	NSString *itemID;
	NSMutableArray *sharedFolders;
	NSDictionary *itemAsDictionaryCache;
}

@property (nonatomic) int itemTimestamp;
@property int clockSkew;
@property (retain) NSString *type;
@property (retain) NSString *title;
@property (retain) NSString *message;
@property (retain) NSArray *messages;
@property (retain) NSArray *files;
@property (retain) NSArray *to;
@property (retain) NSString *url;
@property (retain) NSString *avatarPath;
@property (retain) NSString *feedName;
@property (retain) NSString *replyTo;
@property (retain) NSString *replyToID;
@property (retain) NSString *replaces;
@property (retain) NSString *uniqueID;
@property (retain) NSString *itemID;
@property (retain) NSString *originalItemID;
@property (retain) NSString *filesDirectory;
@property (retain) NSString *originalSender;
@property (retain) NSMutableArray *sharedFolders;

- (NSDictionary *)getItemAsDict;
- (NSString *)actionText;
- (NSString *)avatarPathForUniqueID:(NSString *)aUniqueID;
- (void)recacheItemDict;

@end
