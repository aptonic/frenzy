//
//  Dropbox.h
//  Frenzy
//
//  Created by John Winter on 11/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSON.h"
#import "AddressBook/AddressBook.h"

#import <sys/mount.h> // is where the statfs struct is defined
#import <sys/attr.h>
#import <sys/vnode.h>
#import <sys/stat.h>

@interface Dropbox : NSObject <NSOpenSavePanelDelegate> {
	NSString *dropboxInfoDir;
    BOOL hasWarnedFallback;
    BOOL hasSetOpenDialogModalPath;
    NSUserDefaults *defaults;
}

+ (Dropbox *)sharedDropbox;
- (NSString *)userDropboxPath;
- (NSString *)dropboxPathFallback;
- (BOOL)isDropboxInstalled;
- (BOOL)checkFoldersActive;
- (NSArray *)sharedFolders;
- (NSArray *)allDropboxFolders;
- (NSArray *)activeSharedFolders;
- (NSString *)uniqueID;
- (NSString *)uniqueIDFallback;
- (BOOL)createFrenzyFolders;
- (void)copyAvatarTo:(NSString *)path;
- (void)createInfoFile:(NSString *)path;
- (NSArray *)dropboxFolders:(BOOL)sharedOnly;
- (void)updateActiveSharedFolders:(NSArray *)activeFolders;
- (void)deactivateSharedFolders:(NSArray *)folders;
- (void)activateSharedFolders:(NSArray *)folders;
- (int)getArchiveNumber:(NSString *)infoPath;
- (NSString *)addressBookFirstName;
- (void)addAlternativeFolder:(NSDictionary *)folderDict;

- (NSMutableArray *)alternativeFolders;
- (NSArray *)activeSharedFoldersFullPaths;
- (NSArray *)sharedFoldersFullPathsThatExist;

- (NSString *)sharedFolderFullPath:(id)sharedFolder activeOnly:(BOOL)activeOnly;
- (NSArray *)sharedFoldersFullPaths:(BOOL)activeOnly;

- (NSString *)folderDisplayName:(NSString *)rawPath;
- (BOOL)isPathLocal:(NSString *)path;
- (NSString *)chooseAlternativeFolder;

@end
