//
//  DropboxMonitor.m
//  Frenzy
//
//  Created by John Winter on 28/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "DropboxMonitor.h"


@implementation DropboxMonitor

@synthesize monitorPaths, existingDropboxFolders, modDateCheckPaths, pathModificationDates, pathModificationSizes;

- (DropboxMonitor *)init
{
	self = [super init];
	fm = [NSFileManager defaultManager];
	
	if (self) {
		[self reApplyPaths];
	}
	return self;
}

- (void)reApplyPaths
{
	// Need to watch every .frenzy folder and every feed.json
	
	[self setModDateCheckPaths:nil];
	[self setPathModificationDates:nil];
	[self setPathModificationSizes:nil];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *tmpMonitorPaths = [[NSMutableArray alloc] init];
	modDateCheckPaths = [[NSMutableArray alloc] init];
	pathModificationDates = [[NSMutableDictionary alloc] init];
	pathModificationSizes = [[NSMutableDictionary alloc] init];
	
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	
	[self setExistingDropboxFolders:[NSArray arrayWithArray:[sharedDropbox sharedFolders]]];
	
	//NSLog(@"in reApplyPaths and setExistingDropboxFolders with %@", [self existingDropboxFolders]);
	
	NSString *dropboxPath = [sharedDropbox userDropboxPath];
	
	for (NSString *sharedFolder in [sharedDropbox activeSharedFoldersFullPaths]) {
		NSString *sharedFolderFrenzyPath = [sharedFolder stringByAppendingPathComponent:@".frenzy"];
		
		[tmpMonitorPaths addObject:sharedFolderFrenzyPath];
		
		NSString *filename;
		NSString *uniqueFeedPath;
		
		NSError *err = nil;
		NSArray *frenzyUniqueDirs = [fileManager contentsOfDirectoryAtPath:sharedFolderFrenzyPath error:&err];
		
		if (!frenzyUniqueDirs) {
			NSLog(@"ERROR: Failed to get contents of .frenzy directory at %@\n%@", sharedFolderFrenzyPath, [err description]);
			return;
		}
		
		for (filename in frenzyUniqueDirs) {
			uniqueFeedPath = [[sharedFolderFrenzyPath stringByAppendingPathComponent:filename] 
							  stringByAppendingPathComponent:@"feeds"];
			
			if ([filename characterAtIndex:0] == '.')
				continue;
            
            // Monitor root of unique directory for changes to avatar or info.json
            [tmpMonitorPaths addObject:[sharedFolderFrenzyPath stringByAppendingPathComponent:filename]];
            
			if ([fileManager fileExistsAtPath:uniqueFeedPath]) {
				[tmpMonitorPaths addObject:uniqueFeedPath];
				
				NSString *feed = [uniqueFeedPath stringByAppendingPathComponent:@"feed.json"];
				
				if ([fileManager fileExistsAtPath:feed]) {
					[[self modDateCheckPaths] addObject:feed];
					[self updateLastModificationDateForPaths];
					[self stopFileModDateCheckTimer];
					fileModDatePollTimer = [NSTimer scheduledTimerWithTimeInterval:15
																			  target:self
																			selector:@selector(checkForFileModDateChanges)
																			userInfo:nil
																			 repeats:YES];
				}
			}
		}
	}

	// Add monitor to root Dropbox folder and inside every Dropbox folder
	// (so we can see if a standard Dropbox folder becomes shared)
	[tmpMonitorPaths addObject:dropboxPath];
	
	NSArray *allDropboxFolders = [sharedDropbox allDropboxFolders];
	int totalNumberOfPaths = [tmpMonitorPaths count] + [allDropboxFolders count];
	
	if (totalNumberOfPaths > MAX_WATCHER_PATHS) {
		NSLog(@"Total number of watched paths will exceed %d, disabling watching of folders in Dropbox root", MAX_WATCHER_PATHS);
		NSLog(@"Watching %ld files/folders", (long)[tmpMonitorPaths count]);
	} else {
		[tmpMonitorPaths addObjectsFromArray:allDropboxFolders];
		NSLog(@"Watching %d files/folders", totalNumberOfPaths);
	}
	
	//NSLog(@"tmpMonitorPaths: %@", tmpMonitorPaths);
	
	[self setMonitorPaths:tmpMonitorPaths];
	[tmpMonitorPaths release];
	//NSLog(@"Now monitoring paths: %@", [self monitorPaths]);
	
	[self stopEventBasedMonitoring];
	[self applyForFileChangeNotifications];
}

- (void)applyForFileChangeNotifications
{
	for (NSString *path in [self monitorPaths])
		[[UKKQueue sharedFileWatcher] addPath:path];
	
	[[UKKQueue sharedFileWatcher] setDelegate:self];
}

- (void)stopEventBasedMonitoring
{
	for (NSString *path in [self monitorPaths]) {
		[[UKKQueue sharedFileWatcher] removePathFromQueue:path];
	}
}

- (void)watcher:(id<UKFileWatcher>)watcher receivedNotification:(NSString *)notification forPath:(NSString *)path
{	
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	
	NSString *uniqueID = [[path stringByDeletingLastPathComponent] lastPathComponent];

	if ([path isEqualToString:[sharedDropbox userDropboxPath]]) {
		NSLog(@"Change in main Dropbox folder detected");
		//[self listFolders:[sharedDropbox userDropboxPath]];
		[self performSelector:@selector(handleMainDropboxFolderChanged) withObject:nil afterDelay:2];
		[self performSelector:@selector(reApplyPaths) withObject:nil afterDelay:3];
	}
	
	if ([uniqueID isEqualToString:[[sharedDropbox userDropboxPath] lastPathComponent]]) {		
		// There was a change inside a folder in the Dropbox root (shared or unshared)
		if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@".dropbox"]] && 
			![[self existingDropboxFolders] containsObject:path]) {
			// This happens if the user creates a new folder and then shares it
			NSLog(@"New shared folder activated: %@", [path lastPathComponent]);
			[self newSharedFolderActivated:[path lastPathComponent] wasInvited:NO];
			[self setExistingDropboxFolders:[NSArray arrayWithArray:[sharedDropbox sharedFolders]]];	
		}
	}
	
	if ([[path lastPathComponent] isEqualToString:@"feeds"] && ![uniqueID isEqualToString:[[Dropbox sharedDropbox] uniqueID]]) {
		[self performSelector:@selector(reloadFeed) withObject:nil afterDelay:0.2];
	}
	
	if ([[path lastPathComponent] isEqualToString:@".frenzy"])
		[self performSelector:@selector(reloadEverything) withObject:nil afterDelay:0.2];
	
    // Avatar or info.json change
    if ([[[path stringByDeletingLastPathComponent] lastPathComponent] isEqualToString:@".frenzy"] && ![uniqueID isEqualToString:[[Dropbox sharedDropbox] uniqueID]])
		[self performSelector:@selector(reloadEverything) withObject:nil afterDelay:0.2];
	
	[self stopEventBasedMonitoring];
	[self applyForFileChangeNotifications];
}

- (void)reloadFeed
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeed" object:self userInfo:nil];
	[self updateLastModificationDateForPaths];
}

- (void)reloadEverything
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadEverything" object:self userInfo:nil];
}

- (void)handleMainDropboxFolderChanged
{
	NSMutableArray *newFolders = [NSMutableArray array];
	NSMutableArray *removedFolders = [NSMutableArray array];
	
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	NSArray *sharedFolders = [sharedDropbox sharedFolders];
	NSString *userDropboxPath = [sharedDropbox userDropboxPath];
	
	// See if there is a new shared folder 
	for (NSString *currentSharedFolder in sharedFolders) {
		if (![existingDropboxFolders containsObject:currentSharedFolder]) {
			[newFolders addObject:currentSharedFolder];
		}
	}
	
	if ([newFolders count] == 1) {
		NSLog(@"New shared folder activated (in handleMainDropboxFolderChanged): %@", [[newFolders objectAtIndex:0] lastPathComponent]);
		[self newSharedFolderActivated:[[newFolders objectAtIndex:0] lastPathComponent] wasInvited:YES];	
	}
	
	// Check if any active shared folders disappeared and if so stop monitoring them
	for (NSString *currentActiveFolder in [sharedDropbox activeSharedFolders]) {
		if (![sharedFolders containsObject:[userDropboxPath stringByAppendingPathComponent:currentActiveFolder]]) {
			[removedFolders addObject:currentActiveFolder];
		}
	}
		
	if ([removedFolders count] > 0) {
		[sharedDropbox deactivateSharedFolders:removedFolders];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadEverything" object:self userInfo:nil];
		NSLog(@"Stopped monitoring folders: %@", removedFolders);
	}
	
	[[PrefsController prefsController] updateFoldersTable:NO];
}

- (void)listFolders:(NSString *)atPath
{
	NSString *filename;
	NSMutableArray *folders = [NSMutableArray array];
	
    NSError *err = nil;
    NSArray *contentsOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:atPath error:&err];
    if (!contentsOfFolder) {
        NSLog(@"Failed to get directory contents in DropboxMonitor listFolders for path: %@", atPath);
        NSLog(@"%@", [err description]);
    }
    
	NSEnumerator *enumerator = [contentsOfFolder objectEnumerator];
	while ((filename = [enumerator nextObject])) {
		if ([filename length] > 0) {
			// Don't add any hidden folders
			if ([filename characterAtIndex:0] == '.')
				continue;
			
			NSString *fullPath = [atPath stringByAppendingPathComponent:filename];

            NSError *err = nil;
            NSDictionary *fattrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&err];
            if (!fattrs) {
                NSLog(@"Failed to get attributes of item in listFolders: at path: %@", fullPath);
                NSLog(@"%@", [err description]);
                continue;
            }
            
			NSString *fileType = [fattrs objectForKey:NSFileType];
			
			if (fileType == NSFileTypeDirectory) {
				[folders addObject:fullPath];
			}
		}
	}
	
	//NSLog(@"folders in %@: %@", atPath, folders);
}

- (void)newSharedFolderActivated:(NSString *)name wasInvited:(BOOL)wasInvited
{
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	
	[NSApp activateIgnoringOtherApps:YES];
	
	NSString *action = (wasInvited ? @"joined" : @"created");
	NSString *inviteMsg = [NSString stringWithFormat:@"You've %@ the Dropbox shared folder '%@'\nDo you want to use this folder with Frenzy?", action, name];
	
	int result = NSRunAlertPanel([@"New Dropbox shared folder available - " stringByAppendingString:name], inviteMsg, 
								 @"Use with Frenzy", @"Do not use with Frenzy", nil);
	
	if (result == 1) {
		NSLog(@"Using %@ to communicate with Frenzy", name);
		[sharedDropbox activateSharedFolders:[NSArray arrayWithObjects:name, nil]];
		[sharedDropbox createFrenzyFolders];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadEverything" object:self userInfo:nil];
        [self performSelector:@selector(reloadEverything) withObject:nil afterDelay:5];
	} else if (result == 0) {
		NSLog(@"NOT using %@ to communicate with Frenzy", name);
		[self reApplyPaths];
	}
}

- (void)updateLastModificationDateForPaths
{
	for (NSString *path in [self modDateCheckPaths]) {
		if (![fm fileExistsAtPath:path]) continue;
		NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:NULL];
		NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
		NSNumber *fileSize = [NSNumber numberWithLongLong:[[fileAttributes objectForKey:NSFileSize] longLongValue]];
		[[self pathModificationDates] setObject:fileModDate forKey:path];
		[[self pathModificationSizes] setObject:fileSize forKey:path];
	}
}

- (NSDate *)lastModificationDateForPath:(NSString *)path
{
	if ([[self pathModificationDates] valueForKey:path] != nil) {
		return [[self pathModificationDates] valueForKey:path];
	}
	return nil;
}

- (NSNumber *)lastModificationSizeForPath:(NSString *)path
{
	if ([[self pathModificationSizes] valueForKey:path] != nil) {
		return [[self pathModificationSizes] valueForKey:path];
	}
	return nil;
}

- (void)checkForFileModDateChanges
{	
	for (NSString *path in [self modDateCheckPaths]) {
		if (![fm fileExistsAtPath:path]) continue;
		
		NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:NULL];
		NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
		long long fileSize = [[fileAttributes objectForKey:NSFileSize] longLongValue]; 
		
		if([fileModDate compare:[self lastModificationDateForPath:path]] == NSOrderedDescending || fileSize != [[self lastModificationSizeForPath:path] longLongValue]) {
			NSString *uniqueID = [[[path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] lastPathComponent];
			
			if (![uniqueID isEqualToString:[[Dropbox sharedDropbox] uniqueID]]) {
				NSLog(@"NSFileModificationDate/Size change detected for path %@", path);
				[self performSelector:@selector(reloadFeed) withObject:nil afterDelay:0.2]; 
			}
			
			[self updateLastModificationDateForPaths];
		}
	}
}

- (void)stopFileModDateCheckTimer
{
    if (fileModDatePollTimer)
    {
        [fileModDatePollTimer invalidate];
        fileModDatePollTimer = nil;
    }
}

- (void)dealloc
{
	[self stopEventBasedMonitoring];
	[self stopFileModDateCheckTimer];
	[monitorPaths release];
	[modDateCheckPaths release];
	[pathModificationDates release];
	[existingDropboxFolders release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
