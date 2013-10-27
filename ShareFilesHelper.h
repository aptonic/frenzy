//
//  ShareFilesHelper.h
//  Frenzy
//
//  Created by John Winter on 27/02/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Dropbox.h"
#import "FeedItem.h"

@interface ShareFilesHelper : NSObject {

}

+ (ShareFilesHelper *)sharedFilesHelper;
- (void)createSharedFiles:(NSArray *)files inFolders:(NSArray *)folders forItem:(FeedItem *)feedItem;
- (void)deleteFilesForFeedItem:(FeedItem *)feedItem;
- (unsigned long long)fastFolderSizeAtFSRef:(FSRef *)theFileRef;
- (NSNumber *)calculateItemSize:(NSString *)itemPath;
- (NSString *)getFileStatus:(NSArray *)feedItems;
- (BOOL)hasItemTransferred:(NSString *)itemName forFeedItem:(FeedItem *)feedItem checkExistenceOnly:(BOOL)checkExistenceOnly;
- (NSString *)sharingPathForItem:(FeedItem *)feedItem;
- (void)addFileTranfersCompleted:(FeedItem *)feedItem;
- (BOOL)wasFileTransferCompletedForItem:(FeedItem *)feedItem;
- (NSArray *)getLastItemsFromArray:(NSArray *)array numItems:(int)numItems;

@end
