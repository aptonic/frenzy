//
//  Dropbox.m
//  Frenzy
//
//  Created by John Winter on 11/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "Dropbox.h"
#import "MBBase64.h"
#import "GetPrimaryMACAddress.h"
#import "PrefsController.h"

@implementation Dropbox

- (Dropbox *)init
{
	self = [super init];
	
	if (self) {
        hasSetOpenDialogModalPath = NO;
		dropboxInfoDir = [[NSString alloc] initWithString:[@"~/.dropbox" stringByExpandingTildeInPath]];
        defaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

+ (Dropbox *)sharedDropbox
{  
	static Dropbox *sharedDropbox;
	
	if (!sharedDropbox) {
		sharedDropbox = [[Dropbox alloc] init];
	}
	return sharedDropbox;
}

- (NSString *)userDropboxPath
{
	// Find the users Dropbox folder by reading ~/.dropbox/host.db
	NSError *err = nil;
	
	NSString *hostPath = [dropboxInfoDir stringByAppendingPathComponent:@"host.db"];
	NSString *hostInfo = [NSString stringWithContentsOfFile:hostPath encoding:NSASCIIStringEncoding error:&err];
	
	// Base64 decode to get the folder and use dropboxPathFallback if anything goes wrong
	if (!hostInfo) {
        if (!hasWarnedFallback) {
            NSLog(@"Failed to read host.db");
            NSLog(@"%@", [err description]);
        }
        return [self dropboxPathFallback];
    } else {
        NSArray *splitHostInfo = [hostInfo componentsSeparatedByString:@"\n"];
        if ([splitHostInfo count] <= 1)
            return [self dropboxPathFallback];
        
        NSString *base64EncodedPath = [splitHostInfo objectAtIndex:1];
        NSString *decodedPath = [[[NSString alloc] initWithData:[base64EncodedPath decodeBase64] encoding:NSASCIIStringEncoding] autorelease];
        
        if (IsEmpty(decodedPath) || [[decodedPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
            return [self dropboxPathFallback];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:decodedPath]) {
            if (!hasWarnedFallback)
                NSLog(@"Dropbox path specified in host.db (%@) does not exist", decodedPath);
            return [self dropboxPathFallback];
        }
         
        //return @"/Users/john/Desktop/dropbox";
		return decodedPath;
	}
				
}

// Allow the user to choose their Dropbox path manually as fallback
- (NSString *)dropboxPathFallback
{
    if (!hasWarnedFallback) {
        NSLog(@"Using dropboxPathFallback as Dropbox path could not be determined");
        hasWarnedFallback = YES;
    }
    
    NSString *storedDropboxPath = [defaults objectForKey:@"dropboxPath"];
    
    if (!IsEmpty(storedDropboxPath) && [[NSFileManager defaultManager] fileExistsAtPath:storedDropboxPath]) {        
        return storedDropboxPath;
    } else {
        int result;
        
        NSOpenPanel *oPanel = [NSOpenPanel openPanel];
        [oPanel setCanChooseFiles:NO];
        [oPanel setCanChooseDirectories:YES];
        [oPanel setAllowsMultipleSelection:NO];
        [oPanel setTitle:@"Choose Your Dropbox Folder"];
        [oPanel setMessage:@"Frenzy could not determine the path of your Dropbox folder.\nIf you don't know where this is, check the Advanced section of the Dropbox preferences."];
        [oPanel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES]];
        
       	[NSApp activateIgnoringOtherApps:YES];
        
        result = [oPanel runModal];
        
        if (result == NSOKButton) {
            NSString *selectedDirectory = [[[oPanel URLs] objectAtIndex:0] path];
            [defaults setObject:selectedDirectory forKey:@"dropboxPath"];
            [defaults synchronize];
            return selectedDirectory;
        } else {
            [NSApp terminate:nil];
        }
    }
    
    return nil;
}

- (BOOL)isDropboxInstalled
{
	// If there is a ~/.dropbox/host.db then it is, otherwise not
    NSFileManager *fm = [NSFileManager defaultManager];
    
	if ([fm fileExistsAtPath:[dropboxInfoDir stringByAppendingPathComponent:@"host.db"]] || 
        [fm fileExistsAtPath:[dropboxInfoDir stringByAppendingPathComponent:@"host.dbx"]])
		return YES;
	else
		return NO;
}

- (BOOL)checkFoldersActive
{
    if ([[self activeSharedFoldersFullPaths] count] <= 0) {
        [NSApp activateIgnoringOtherApps:YES];
        int result = NSRunAlertPanel(@"No shared folders enabled", 
                                     @"You don't have any Dropbox shared folders enabled.\nEnable at least one shared folder to use Frenzy.", 
                                     @"Open Preferences",  @"Cancel", nil);
        
        if (result == NSAlertDefaultReturn) {
            [PrefsController showPrefs];
            [[PrefsController prefsController] changeActiveTab:@"Dropbox"];
		} else {
            if (![PrefsController isShowingPrefs]) [NSApp hide:nil];
        }
        return NO; 
    }
    return YES;
}

- (NSArray *)dropboxFolders:(BOOL)sharedOnly
{
	// Return array of folder paths in userDropboxPath that have .dropbox files in them
	NSString *filename;
	NSString *dropboxPath = [self userDropboxPath];
	NSMutableArray *folders = [NSMutableArray array];
	
   	NSError *err = nil;
    NSArray *dropboxDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dropboxPath error:&err];
    if (!dropboxDirectoryContents) {
        NSLog(@"Failed to get directory contents at dropboxPath: %@", dropboxPath);
        NSLog(@"%@", [err description]);
        return nil;
    }
    
	NSEnumerator *enumerator = [dropboxDirectoryContents objectEnumerator];
	while ((filename = [enumerator nextObject])) {
		if ([filename length] > 0) {
			// Don't add any hidden folders
			if ([filename characterAtIndex:0] == '.')
				continue;
			
			NSString *fullPath = [dropboxPath stringByAppendingPathComponent:filename];
           	NSError *err = nil;
			NSDictionary *fattrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&err];
            if (!fattrs) {
                NSLog(@"Failed to get attributes of item in dropboxFolders: at path: %@", fullPath);
                NSLog(@"%@", [err description]);
                continue;
            }
                
			NSString *fileType = [fattrs objectForKey:NSFileType];
			
			if (fileType == NSFileTypeDirectory) {
				if ([[NSFileManager defaultManager] fileExistsAtPath:[fullPath stringByAppendingPathComponent:@".dropbox"]] || !sharedOnly) {
					[folders addObject:fullPath];
				}
			}
		}
	}
	
	return folders;
}

- (NSArray *)sharedFolders
{
	return [self dropboxFolders:YES];
}

- (NSArray *)allDropboxFolders
{
	return [self dropboxFolders:NO];
}

// Returns uniqueID default or creates using this machines MAC address if it doesn't exist yet
- (NSString *)uniqueID
{
	if ([defaults objectForKey:@"uniqueID"] == nil) {
        NSString *macAddress = [GetMacAddress macAddress];
        [defaults setObject:(!IsEmpty(macAddress) ? macAddress : [self uniqueIDFallback]) forKey:@"uniqueID"];
		[defaults synchronize];
	}
	
	return [defaults objectForKey:@"uniqueID"];
}

- (NSString *)uniqueIDFallback
{
    NSLog(@"Using uniqueIDFallback");
          
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString *uuidString = [NSString stringWithString:(NSString *)strRef];
    CFRelease(strRef);
    CFRelease(uuidRef);
    
    NSString *finalString = [[[uuidString substringToIndex:13] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    return finalString;
}

// Creates .frenzy folders in each active shared folder
// then create folder with uniqueID inside each
// Returns false if an active shared folder cannot be found
- (BOOL)createFrenzyFolders
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *err = nil;
		
	NSString *dropboxPath = [self userDropboxPath];
	NSArray *sharedFolders = [[self activeSharedFolders] arrayByAddingObjectsFromArray:[self alternativeFolders]];

	for (id sharedFolder in sharedFolders) {
        NSString *fullSharedFolderPath;
        
        if ([sharedFolder isKindOfClass:[NSDictionary class]]) {
            // Alternative folder
            if (![[sharedFolder objectForKey:@"active"] boolValue])
                continue;
            else
                fullSharedFolderPath = [sharedFolder objectForKey:@"path"];
        } else {
           fullSharedFolderPath = [dropboxPath stringByAppendingPathComponent:sharedFolder];
        }
		
		if (![fileManager fileExistsAtPath:fullSharedFolderPath]) {
			NSLog(@"Shared folder %@ is listed as active but could not be found\n", sharedFolder);
			return NO;
		}
			
		NSString *folder = [[fullSharedFolderPath stringByAppendingPathComponent:@".frenzy"]
							stringByAppendingPathComponent:[self uniqueID]];
		
		if (![fileManager fileExistsAtPath:folder]) {
            if (![fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&err]) {
				NSLog(@"ERROR: Failed to create folder %@\n%@", folder, [err description]);
				continue;
			}
		}
		
		NSString *feedsPath = [folder stringByAppendingPathComponent:@"feeds"];
		err = nil;
		if (![fileManager fileExistsAtPath:feedsPath]) {
            if (![fileManager createDirectoryAtPath:feedsPath withIntermediateDirectories:YES attributes:nil error:&err]) {
				NSLog(@"ERROR: Failed to create folder %@\n%@", feedsPath, [err description]);
				continue;
			}
		}
		
		[self copyAvatarTo:folder];
		[self createInfoFile:folder];
	}
	
	return YES;
}

- (void)copyAvatarTo:(NSString *)path
{
	[[defaults objectForKey:@"userImage"] writeToFile:[path stringByAppendingPathComponent:@"avatar.png"] atomically:NO];
}

- (void)createInfoFile:(NSString *)path
{	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *infoPath = [path stringByAppendingPathComponent:@"info.json"];
	
	NSString *displayName;
	
	if (!IsEmpty([defaults objectForKey:@"displayName"])) {
		displayName = [defaults objectForKey:@"displayName"];
	} else {
		displayName = [self addressBookFirstName];
	}
	
	NSMutableArray *dictKeys = [[NSMutableArray alloc] init];
	NSMutableArray *dictObjects = [[NSMutableArray alloc] init];
	
	[dictKeys addObject:@"name"];
	[dictObjects addObject:displayName];
	
	[dictKeys addObject:@"archiveNumber"];
	
	if (![fileManager fileExistsAtPath:infoPath]) {
		[dictObjects addObject:[NSNumber numberWithInt:1]];
	} else {
		int archiveNumber = [self getArchiveNumber:infoPath];
		[dictObjects addObject:[NSNumber numberWithInt:archiveNumber]];
	}
	
	NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:dictObjects forKeys:dictKeys];
	
	NSError *err;
	BOOL wroteFile;
	
	wroteFile = [[infoDict JSONRepresentation] writeToFile:infoPath
												atomically:NO encoding:NSUTF8StringEncoding error:&err];
	
	if (!wroteFile)
		NSLog(@"Failed writing info.json to path %@:\n%@", path, err);
	
	[dictKeys release];
	[dictObjects release];
}

- (NSString *)addressBookFirstName
{
	ABAddressBook *tempBook = [ABAddressBook addressBook];
	ABPerson *person = [tempBook me];
	NSString *firstName = [person valueForProperty:kABFirstNameProperty];
	if (IsEmpty(firstName)) return @"Unknown";
	return firstName;
}

- (int)getArchiveNumber:(NSString *)infoPath
{
	NSString *userInfoContents = [[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil] 
								  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if (!IsEmpty(userInfoContents)) {
		NSDictionary *infoDict = [userInfoContents JSONValue];
		return [[infoDict objectForKey:@"archiveNumber"] intValue];
	} else {
		return 1;
	}
}

- (NSArray *)activeSharedFolders
{
	return [defaults objectForKey:@"folders"];
}

- (void)updateActiveSharedFolders:(NSArray *)activeFolders
{
	[defaults setObject:activeFolders forKey:@"folders"];
	[defaults synchronize];
}

- (void)deactivateSharedFolders:(NSArray *)folders
{
	NSMutableArray *activeFolders = [NSMutableArray arrayWithArray:[self activeSharedFolders]];
	[activeFolders removeObjectsInArray:folders];
	[self updateActiveSharedFolders:activeFolders];
}

- (void)activateSharedFolders:(NSArray *)folders
{
	NSMutableArray *activeFolders = [NSMutableArray arrayWithArray:[self activeSharedFolders]];
	[activeFolders addObjectsFromArray:folders];
	[self updateActiveSharedFolders:activeFolders];
}

- (void)addAlternativeFolder:(NSDictionary *)folderDict
{
    NSMutableArray *alternativeFolders = [self alternativeFolders];
	[alternativeFolders addObject:folderDict];
	[defaults setObject:alternativeFolders forKey:@"alternativeFolders"];
	[defaults synchronize];
}

- (NSMutableArray *)alternativeFolders
{
    NSMutableArray *alternativeFolders;
    
	if (!IsEmpty([defaults objectForKey:@"alternativeFolders"]))
		alternativeFolders = [NSMutableArray arrayWithArray:[defaults objectForKey:@"alternativeFolders"]];
	else
		alternativeFolders = [NSMutableArray array];
	
    return alternativeFolders;
}

- (NSString *)sharedFolderFullPath:(id)sharedFolder activeOnly:(BOOL)activeOnly
{
    NSString *fullSharedFolderPath;
    
    if ([sharedFolder isKindOfClass:[NSDictionary class]]) {
        // Alternative folder
        if (activeOnly) {
            if ([[sharedFolder objectForKey:@"active"] boolValue])
                fullSharedFolderPath = [sharedFolder objectForKey:@"path"];
            else
                fullSharedFolderPath = nil;
        } else {
            fullSharedFolderPath = [sharedFolder objectForKey:@"path"];
        }
    } else {
        fullSharedFolderPath = (activeOnly ? [[self userDropboxPath] stringByAppendingPathComponent:sharedFolder] : sharedFolder);
    }
    
    return fullSharedFolderPath;
}

- (NSArray *)sharedFoldersFullPaths:(BOOL)activeOnly
{
    NSArray *sharedFolders = [(activeOnly ? [self activeSharedFolders] : [self sharedFolders]) arrayByAddingObjectsFromArray:[self alternativeFolders]];
    NSMutableArray *sharedFoldersFullPaths = [NSMutableArray array];

	for (id sharedFolder in sharedFolders) {
        NSString *fullSharedFolderPath = [self sharedFolderFullPath:sharedFolder activeOnly:activeOnly];
        if (IsEmpty(fullSharedFolderPath)) continue;
        [sharedFoldersFullPaths addObject:fullSharedFolderPath];
    }
    
    return sharedFoldersFullPaths;
}

- (NSArray *)activeSharedFoldersFullPaths
{
    return [self sharedFoldersFullPaths:YES];
}

- (NSArray *)sharedFoldersFullPathsThatExist
{
    NSMutableArray *existingPaths = [NSMutableArray array];
    // Get all shared folders, active and inactive
    for (NSString *path in [self sharedFoldersFullPaths:NO]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            [existingPaths addObject:path];
    }
    return existingPaths;
}

- (NSString *)folderDisplayName:(NSString *)rawPath
{
    NSString *adjustedPath;
    if ([rawPath hasPrefix:[[Dropbox sharedDropbox] userDropboxPath]])
        adjustedPath = [rawPath substringFromIndex:[[[Dropbox sharedDropbox] userDropboxPath] length] + 1];
    else 
        adjustedPath = rawPath;
    return adjustedPath;
}

- (NSString *)chooseAlternativeFolder
{
    int result;
    
    while (1) {
        NSOpenPanel *oPanel = [NSOpenPanel openPanel];
        [oPanel setCanChooseFiles:NO];
        [oPanel setCanChooseDirectories:YES];
        [oPanel setAllowsMultipleSelection:NO];
        [oPanel setDelegate:self];
        [oPanel setCanCreateDirectories:YES];
        [oPanel setTitle:@"Choose Dropbox shared folder"];
        [oPanel setMessage:@"You can choose a shared folder to use with Frenzy that may be in a subfolder."];
        [oPanel setDirectoryURL:(hasSetOpenDialogModalPath ? nil : [NSURL fileURLWithPath:[[Dropbox sharedDropbox] userDropboxPath] isDirectory:YES])];
        
        result = [oPanel runModal];
        
        hasSetOpenDialogModalPath = YES;
        
        if (result == NSOKButton) {
            NSString *selectedDirectory = [[[oPanel URLs] objectAtIndex:0] path];
            
            if ([selectedDirectory isEqualToString:[self userDropboxPath]]) {
                NSRunAlertPanel(@"You must select a folder", 
                                @"Please choose a valid folder to use Frenzy with.", 
                                @"OK", nil, nil);
                // Try again
                continue;
            }
            
            return selectedDirectory;
        }
        break;
    }
    
    return nil;
}

- (BOOL)isPathLocal:(NSString *)path
{
    NSString *device;
    int err;
	struct statfs sfsb;
    const char * volPath = [path UTF8String];
    
    err = statfs(volPath, &sfsb);
	if (err != 0) return YES;
	
	device = [NSString stringWithCString:sfsb.f_mntfromname encoding:NSASCIIStringEncoding];
	BOOL isLocal = [device rangeOfString:@"/dev/"].location != NSNotFound;
    return isLocal;
}

- (void)dealloc
{
	[dropboxInfoDir release];
	[super dealloc];
}

@end
