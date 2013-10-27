//
//  ShareFilesHelper.m
//  Frenzy
//
//  Created by John Winter on 27/02/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "ShareFilesHelper.h"


@implementation ShareFilesHelper

+ (ShareFilesHelper *)sharedFilesHelper
{  
	static ShareFilesHelper *sharedFilesHelper;
	
	if (!sharedFilesHelper) {
		sharedFilesHelper = [[ShareFilesHelper alloc] init];
	}
	return sharedFilesHelper;
}

- (void)createSharedFiles:(NSArray *)files inFolders:(NSArray *)folders forItem:(FeedItem *)feedItem
{
	NSMutableArray *sharedFiles = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	NSString *uniqueID = [sharedDropbox uniqueID];
	
	NSMutableArray *filesToCopy = [NSMutableArray array];
	
	for (NSDictionary *dict in files) {
		NSString *filePath = [dict objectForKey:@"path"];
		NSString *finalFilename;
        
        NSError *error = nil;
		NSDictionary *fattrs = [fm attributesOfItemAtPath:filePath error:&error];
        if (!fattrs) {
            NSLog(@"Error getting file attributes for item with path %@\n%@", filePath, [error description]);
            continue;
        }
        
		NSString *fileType;

		BOOL isDirectory = NO;
		
		if ([fattrs objectForKey:NSFileType] == NSFileTypeDirectory) {
			isDirectory = YES;
			fileType = @"folder";
		} else {
			fileType = @"file";
		}
		
		NSNumber *totalSize = [self calculateItemSize:filePath];
        
        for (NSString *sharedFolder in folders) {

			NSString *sharingPath = [[[sharedFolder stringByAppendingPathComponent:@".frenzy"] 
									  stringByAppendingPathComponent:uniqueID]
									 stringByAppendingPathComponent:@"shared"];
            
			if (![fm fileExistsAtPath:sharingPath]) {
				NSError *error = nil;
				[fm createDirectoryAtPath:sharingPath withIntermediateDirectories:NO attributes:nil error:&error];
				if (error) 
					NSLog(@"Error creating shared folder with path (%@): %@", sharingPath, [error description]);
			}
			
			if ([files count] == 1) {
				// Place single file in shared directory root and if there is another file in
				// there with that name already, append a -n suffix to the name
				NSString *toPath = [sharingPath stringByAppendingPathComponent:[filePath lastPathComponent]];

				int i = 1;
				
				while ([fm fileExistsAtPath:toPath]) {
					NSString *extension = (!IsEmpty([[filePath lastPathComponent] pathExtension]) ? 
										   [@"." stringByAppendingString:[[filePath lastPathComponent] pathExtension]] : @"");
					
					NSString *numberedFilename = [[[[filePath lastPathComponent] stringByDeletingPathExtension] 
												   stringByAppendingFormat:@"-%d", i] 
												  stringByAppendingString:extension];
					
					toPath = [sharingPath stringByAppendingPathComponent:numberedFilename];
					
					if (i >= 1000) break;
					i++;
				}
				
				[filesToCopy addObject:[NSDictionary dictionaryWithObjectsAndKeys:filePath, @"src", toPath, @"dst", nil]];
				finalFilename = [toPath lastPathComponent];
			} else {
				// Multiple files, so create directory for files named with current date/time
				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateFormat:@"yyyy-MM-dd 'at' h.mm.ss a"];
				NSString *folderName = [dateFormatter stringFromDate:[NSDate date]];
				NSString *multipleFilesFolder = [sharingPath stringByAppendingPathComponent:folderName];
				[dateFormatter release];
				
				if (![fm fileExistsAtPath:multipleFilesFolder]) {
					NSError *error = nil;
					[fm createDirectoryAtPath:multipleFilesFolder withIntermediateDirectories:NO attributes:nil error:&error];
					if (error) 
						NSLog(@"Error creating shared folder for multiple files (%@): %@", multipleFilesFolder, [error description]);
					
					[feedItem setFilesDirectory:folderName];
				}
				
				NSString *toPath = [multipleFilesFolder stringByAppendingPathComponent:[filePath lastPathComponent]];
				[filesToCopy addObject:[NSDictionary dictionaryWithObjectsAndKeys:filePath, @"src", toPath, @"dst", nil]];
				finalFilename = [toPath lastPathComponent];
			}
		}
		
		NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  finalFilename, @"name", fileType, @"type", totalSize, @"size", nil];
		
		
		[sharedFiles addObject:fileInfo];
	}
	
	[self performSelectorInBackground:@selector(copyFiles:) withObject:filesToCopy];
	
	[feedItem setFiles:sharedFiles];
}

- (void)copyFiles:(NSArray *)files
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	for (NSDictionary *fileCopyInfo in files) {
		NSString *sourcePath = [fileCopyInfo objectForKey:@"src"];
		NSString *destPath = [fileCopyInfo objectForKey:@"dst"];
		
		NSError *error = nil;
		[fm copyItemAtPath:sourcePath toPath:destPath error:&error];	
		if (error)
			NSLog(@"Error copying item from source %@ to destination %@\nError: %@", sourcePath, destPath, [error description]);
	}
	
	[fm release];
	[pool release];
}

- (void)deleteFilesForFeedItem:(FeedItem *)feedItem
{
	NSFileManager *fm = [NSFileManager defaultManager];
	Dropbox *sharedDropbox = [Dropbox sharedDropbox];
	NSString *uniqueID = [sharedDropbox uniqueID];
	
	for (NSString *sharedFolder in [feedItem sharedFolders]) {

		NSString *sharingPath = [[[sharedFolder stringByAppendingPathComponent:@".frenzy"] 
								  stringByAppendingPathComponent:uniqueID]
								 stringByAppendingPathComponent:@"shared"];
		
		if (!IsEmpty([feedItem filesDirectory])) {
			NSString *filesDir = [sharingPath stringByAppendingPathComponent:[feedItem filesDirectory]];
			
			NSError *error = nil;
			[fm removeItemAtPath:filesDir error:&error];
			if (error) 
				NSLog(@"Error deleting files directory with path (%@): %@", filesDir, [error description]);
		} else {
			for (NSDictionary *fileDict in [feedItem files]) {
				NSString *filename = [fileDict objectForKey:@"name"];
				
				if (!IsEmpty(filename)) {
					NSString *filePath = [sharingPath stringByAppendingPathComponent:filename];
					NSError *error = nil;
					[fm removeItemAtPath:filePath error:&error];
					if (error) 
						NSLog(@"Error deleting file/folder with path (%@): %@", filePath, [error description]);
				}
			}
		}
		 
	}
}

- (unsigned long long)fastFolderSizeAtFSRef:(FSRef *)theFileRef
{
    FSIterator    thisDirEnum = NULL;
    unsigned long long totalSize = 0;
	
    // Iterate the directory contents, recursing as necessary
    if (FSOpenIterator(theFileRef, kFSIterateFlat, &thisDirEnum) == noErr)
    {
        const ItemCount kMaxEntriesPerFetch = 40;
        ItemCount actualFetched;
        FSRef    fetchedRefs[kMaxEntriesPerFetch];
        FSCatalogInfo fetchedInfos[kMaxEntriesPerFetch];
		
        // DCJ Note right now this is only fetching data fork
		// sizes... if we decide to include
		// resource forks we will have to add kFSCatInfoRsrcSizes
			
			OSErr fsErr = FSGetCatalogInfoBulk(thisDirEnum,
											   kMaxEntriesPerFetch, &actualFetched,
											   NULL, kFSCatInfoDataSizes |
											   kFSCatInfoNodeFlags, fetchedInfos,
											   fetchedRefs, NULL, NULL);
        while ((fsErr == noErr) || (fsErr == errFSNoMoreItems))
        {
            ItemCount thisIndex;
            for (thisIndex = 0; thisIndex < actualFetched; thisIndex++)
            {
                // Recurse if it's a folder
                if (fetchedInfos[thisIndex].nodeFlags &
					kFSNodeIsDirectoryMask)
                {
                    totalSize += [self
								  fastFolderSizeAtFSRef:&fetchedRefs[thisIndex]];
                }
                else
                {
                    // add the size for this item
					NSString *pathString;
					CFURLRef myURLRef;
					
					myURLRef = CFURLCreateFromFSRef(kCFAllocatorDefault, &fetchedRefs[thisIndex]);
					
					if (myURLRef != NULL)
						pathString = [(NSURL *) myURLRef path];
					
					if (![[pathString lastPathComponent] isEqualToString:@".DS_Store"]) {
						totalSize += fetchedInfos
						[thisIndex].dataLogicalSize;
					}
						
					CFRelease(myURLRef);
                }
            }
			
            if (fsErr == errFSNoMoreItems)
            {
                break;
            }
            else
            {
                // get more items
                fsErr = FSGetCatalogInfoBulk(thisDirEnum,
											 kMaxEntriesPerFetch, &actualFetched,
											 NULL, kFSCatInfoDataSizes |
											 kFSCatInfoNodeFlags, fetchedInfos,
											 fetchedRefs, NULL, NULL);
            }
        }
        FSCloseIterator(thisDirEnum);
    }
    return totalSize;
}

- (NSNumber *)calculateItemSize:(NSString *)itemPath
{
	NSFileManager *fm = [NSFileManager defaultManager];
	
    NSError *error = nil;
    NSDictionary *fattrs = [fm attributesOfItemAtPath:itemPath error:&error];
    if (!fattrs) {
        //NSLog(@"Error getting file attributes for item with path %@ in calculateItemSize\n%@", itemPath, [error description]);
        return [NSNumber numberWithLongLong:0];
    }
    
	long long fileSize = [[fattrs objectForKey:NSFileSize] longLongValue]; 
	
	NSNumber *totalSize;
	
	if ([fattrs objectForKey:NSFileType] == NSFileTypeDirectory) {
		FSRef f;
		OSStatus os_status = FSPathMakeRef((const UInt8 *)[itemPath fileSystemRepresentation], &f, NULL);
		
		if (os_status != noErr) {
			NSLog(@"ShareFilesHelper: Failed to calculate size of directory");
		}
		
		totalSize = [NSNumber numberWithUnsignedLongLong:[self fastFolderSizeAtFSRef:&f]];
	} else {
		totalSize = [NSNumber numberWithLongLong:fileSize];
	}
	
	return totalSize;
}

- (NSString *)getFileStatus:(NSArray *)feedItems
{
	NSMutableArray *fileItems = [NSMutableArray array];
	
	for (FeedItem *feedItem in feedItems) {
		if ([[feedItem type] isEqualToString:FeedItemFileType]) {
			
			BOOL allFilesTransferred = YES;
			
			NSMutableArray *files = [NSMutableArray array];
			for (NSDictionary *fileInfo in [feedItem files]) {
				NSString *filename = [fileInfo objectForKey:@"name"];
				
				BOOL hasTransferred = NO;
				
				if ([self wasFileTransferCompletedForItem:feedItem]) {
					hasTransferred = YES;
					allFilesTransferred = YES;
				} else {				
					if ([self hasItemTransferred:filename forFeedItem:feedItem checkExistenceOnly:NO])
						hasTransferred = YES;
					else
						allFilesTransferred = NO;
				}
				
				[files addObject:[NSDictionary dictionaryWithObjectsAndKeys:filename, @"name", [NSNumber numberWithBool:hasTransferred], @"hasTransferred", nil]];
			}
			
			NSString *overallStatus;
			
			if (allFilesTransferred) {
				overallStatus = @"Complete";
				if (![self wasFileTransferCompletedForItem:feedItem]) [self addFileTranfersCompleted:feedItem];
			} else {
				overallStatus = @"Waiting for files";
			}
			
			NSDictionary *fileDict = [NSDictionary dictionaryWithObjectsAndKeys:[feedItem itemID], @"uid", files, @"files", overallStatus, @"status", nil];
			[fileItems addObject:fileDict];
		}
	}
	
	//NSLog(@"fileItems: %@", [fileItems JSONRepresentation]);
	return [fileItems JSONRepresentation];
}

- (BOOL)hasItemTransferred:(NSString *)itemName forFeedItem:(FeedItem *)feedItem checkExistenceOnly:(BOOL)checkExistenceOnly
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *sharingPath = [self sharingPathForItem:feedItem];			
	NSString *filesDir;
	
	if (!IsEmpty([feedItem filesDirectory]))
		filesDir = [sharingPath stringByAppendingPathComponent:[feedItem filesDirectory]];
	else
		filesDir = sharingPath;
	
	BOOL foundItemName = NO;
	BOOL hasTransferred = NO;
	
	for (NSDictionary *fileInfo in [feedItem files]) {
		NSString *filename = [fileInfo objectForKey:@"name"];
		
		if ([filename isEqualToString:itemName]) {
			foundItemName = YES;
			NSString *filePath = [filesDir stringByAppendingPathComponent:filename];
			
			if (checkExistenceOnly) {
				if ([fm fileExistsAtPath:filePath])
					hasTransferred = YES;
			} else {
				// Check if size of file is correct
				NSNumber *totalSize = [self calculateItemSize:filePath];
				
				//NSLog(@"size of: %d, meant to be %d", [totalSize intValue], [[fileInfo objectForKey:@"size"] intValue]);
				if ([totalSize intValue] >= [[fileInfo objectForKey:@"size"] intValue])
					hasTransferred = YES;			
			}
			
			break;
		}
	}
	
	if (!foundItemName) {
		NSLog(@"hasItemTransferred: could not find an item named %@ in feed item %@", itemName, feedItem);
		return NO;
	}
	
	return hasTransferred;
}

- (NSString *)sharingPathForItem:(FeedItem *)feedItem
{
    NSString *fullSharedFolderPath = [[feedItem sharedFolders] objectAtIndex:0];
    
	NSString *sharingPath = [[[fullSharedFolderPath stringByAppendingPathComponent:@".frenzy"] 
							  stringByAppendingPathComponent:[feedItem originalSender]]
							 stringByAppendingPathComponent:@"shared"];
	
	return sharingPath;
}

- (void)addFileTranfersCompleted:(FeedItem *)feedItem
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *completedItems;
	
	if (!IsEmpty([defaults objectForKey:@"fileTransfersCompleted"]))
		completedItems = [NSMutableArray arrayWithArray:[self getLastItemsFromArray:[defaults objectForKey:@"fileTransfersCompleted"] numItems:199]];
	else
		completedItems = [NSMutableArray array];
	
	[completedItems addObject:[feedItem itemID]];
	[defaults setObject:completedItems forKey:@"fileTransfersCompleted"];
	[defaults synchronize];
}

- (BOOL)wasFileTransferCompletedForItem:(FeedItem *)feedItem
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *completedItems = [defaults objectForKey:@"fileTransfersCompleted"];
	
	if (IsEmpty(completedItems)) {
		return NO;
	} else {
		if ([completedItems containsObject:(!IsEmpty([feedItem originalItemID]) ? [feedItem originalItemID] : [feedItem itemID])])
			return YES;
	}
	
	return NO;
}

- (NSArray *)getLastItemsFromArray:(NSArray *)array numItems:(int)numItems
{
	int location = [array count] - numItems;
	location = (location < 0 ? 0 : location);	
	NSArray *limitedArray = [array subarrayWithRange:NSMakeRange(location, [array count] - location)];
	return limitedArray;
}

@end
