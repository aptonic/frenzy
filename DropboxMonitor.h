//
//  DropboxMonitor.h
//  Frenzy
//
//  Created by John Winter on 28/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKKQueue.h"
#import "Dropbox.h"
#import "PrefsController.h"

#define MAX_WATCHER_PATHS 8000

@interface DropboxMonitor : NSObject {
	NSMutableArray *monitorPaths;
	NSMutableArray *modDateCheckPaths;
	NSArray *existingDropboxFolders;
    NSMutableDictionary *pathModificationDates;
	NSMutableDictionary *pathModificationSizes;
	NSFileManager *fm;
	NSTimer *fileModDatePollTimer;
}

@property (retain) NSMutableArray *monitorPaths;
@property (retain) NSMutableArray *modDateCheckPaths;
@property (retain) NSMutableDictionary *pathModificationDates;
@property (retain) NSMutableDictionary *pathModificationSizes;
@property (retain) NSArray *existingDropboxFolders;

- (void)handleMainDropboxFolderChanged;
- (void)applyForFileChangeNotifications;
- (void)stopEventBasedMonitoring;
- (void)reApplyPaths;
- (void)newSharedFolderActivated:(NSString *)name wasInvited:(BOOL)wasInvited;
- (void)updateLastModificationDateForPaths;
- (void)stopFileModDateCheckTimer;
- (void)reloadFeed;
- (void)reloadEverything;
- (NSNumber *)lastModificationSizeForPath: (NSString *)path;

@end
