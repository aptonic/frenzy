//
//  DragHandler.m
//  Frenzy
//
//  Created by John Winter on 4/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "DragHandler.h"


@implementation DragHandler

@synthesize supportedDraggingTypes;

- (DragHandler *)init
{
	self = [super init];
	
	if (self) {
        supportedDraggingTypes = [[NSArray alloc] initWithObjects:NSFilenamesPboardType, NSStringPboardType, 
                                  NSFilesPromisePboardType, NSTIFFPboardType, AIiTunesTrackPboardType, nil];
	}
	return self;
}

+ (DragHandler *)sharedDragHandler
{  
	static DragHandler *dragHandler;
	
	if (!dragHandler) {
		dragHandler = [[DragHandler alloc] init];
	}
	return dragHandler;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)theEvent
{
    return [self handleDragEvent:theEvent];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)theEvent
{
    return [self handleDragEvent:theEvent];
}

- (NSDragOperation)handleDragEvent:(id <NSDraggingInfo>)theEvent
{
    NSPasteboard *pb = [theEvent draggingPasteboard];
    
    BOOL foundSupportedType = NO;
    for (NSString *type in [self supportedDraggingTypes]) {
        if ([[pb types] containsObject:type]) {
            foundSupportedType = YES;
            break;
        }
    }
    
    if (foundSupportedType)
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if (![[Dropbox sharedDropbox] checkFoldersActive]) return YES;
    
    FrenzyAppDelegate *appDelegate = (FrenzyAppDelegate *)[NSApp delegate];
    ShareItem *shareItem = [appDelegate shareItem];
    
    [appDelegate setDragOperationInProgress:YES];
    
    NSPasteboard *pasteBoard = [sender draggingPasteboard];
    
    [shareItem setFiles:nil];
    BOOL messageOnly = NO;    
    [shareItem closePopup:NO clearTextEditor:NO];
    
    if ([[pasteBoard types] containsObject:NSFilenamesPboardType] || [[pasteBoard types] containsObject:NSFilesPromisePboardType] || [[pasteBoard types] containsObject:AIiTunesTrackPboardType]) {

        NSArray *files;
        
        if ([[pasteBoard types] containsObject:AIiTunesTrackPboardType]) {
            files = [pasteBoard filenamesFromITunesDragPasteboard];
        } else if ([[pasteBoard types] containsObject:NSFilenamesPboardType]) {
            files = [[pasteBoard stringForType:NSFilenamesPboardType] propertyList];
        } else if ([[pasteBoard types] containsObject:NSFilesPromisePboardType]) {
            files = [self filenamesFromHFSPromise:sender];
        }
        
        if (IsEmpty(files)) return NO;
        
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSString *filePath in files) {
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
            
            [infoDict setValue:@"filepath" forKey:@"type"];
            [infoDict setValue:[filePath lastPathComponent] forKey:@"title"];
            [infoDict setValue:filePath forKey:@"path"];
            [items addObject:infoDict];
        }
        
        [shareItem setFiles:items];
    } else if ([[pasteBoard types] containsObject:@"NSStringPboardType"]) {
        // Either a URL or text
        NSString *draggedString = [pasteBoard stringForType:@"NSStringPboardType"];
        
        if ([self validateUrl:draggedString]) {
            [shareItem setItemDict:[NSDictionary dictionaryWithObjectsAndKeys:draggedString, @"title", 
                                    draggedString, @"url", nil]];
        } else {
            NSDictionary *attributesDict=[NSDictionary dictionaryWithObject:
                                          [NSFont fontWithName:@"Lucida Grande" size:14.0] forKey:NSFontAttributeName];
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:draggedString attributes:attributesDict];
            [[[shareItem textEditor] textStorage] setAttributedString:attributedString];
            [attributedString release];
            
            messageOnly = YES;
        }
    }
    
    [appDelegate showWindow];
    [shareItem popup:messageOnly];
    
    if (messageOnly) {
        // Move cursor and scroll to bottom
        NSRange range = { [[[shareItem textEditor] string] length], 0 };
        [[shareItem textEditor] setSelectedRange: range];
        [[shareItem textEditor] scrollRangeToVisible:range];
    }
    
    [self performSelector:@selector(ensureDragCompletedSet:) withObject:appDelegate afterDelay:2];
    
    return YES;
}

- (BOOL)validateUrl:(NSString *)candidate 
{
    return ([[[NSURL URLWithString:candidate] absoluteURL] scheme] != nil);
}

// Workaround for issue where Skitch tries to reactive itself after a drag
// In the FrenzyAppDelegate, applicationDidResignActive we check if this flag is set
// if it is and the new active application is Skitch we call [NSApp activateIgnoringOtherApps:YES];	
- (void)ensureDragCompletedSet:(FrenzyAppDelegate *)appDelegate
{
    [appDelegate setDragOperationInProgress:NO];
}

- (NSArray *)filenamesFromHFSPromise:(id <NSDraggingInfo>)draggingInfo
{
    NSString *tmpDirectory = @"/tmp/Frenzy";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:tmpDirectory error:&error];
        if (error) 
            NSLog(@"Error deleting file promise temporary directory with path (%@): %@", tmpDirectory, [error description]);
    }
    
    NSString *mkdirCommandFormat = @"mkdir \"%@\" > /dev/null 2>&1";
    NSString *mkdirCommand = [NSString stringWithFormat:mkdirCommandFormat, tmpDirectory];
    system([mkdirCommand UTF8String]);
    
    NSArray *createdFiles = [draggingInfo namesOfPromisedFilesDroppedAtDestination:[NSURL fileURLWithPath:tmpDirectory]];
    
    if ([createdFiles count] <= 0) {
        // HFSPromises failiure, can't continue
        NSLog(@"Failed to create file from HFSPromise");
        return nil;
    }
    
    NSError *err = nil;
    NSArray *tmpDirectoryItems = [fileManager contentsOfDirectoryAtPath:tmpDirectory error:&err];
    
    if (!tmpDirectoryItems) {
        NSLog(@"ERROR: Failed to get contents of file promise temporary directory at %@\n%@", tmpDirectory, [err description]);
        return nil;
    }
    
    NSString *filename = [tmpDirectoryItems objectAtIndex:0];
    
    // We need to wait until the source has actually created the files it promised

    NSString *filenameFullPath = [tmpDirectory stringByAppendingPathComponent:filename];
    
    err = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filenameFullPath error:&err];
    if (!fileAttributes) {
        NSLog(@"Failed to get attributes of item in file promise temporary directroy at path: %@", filenameFullPath);
        NSLog(@"%@", [err description]);
    }
    
    int waitCounter = 0;
    while (fileAttributes == nil || [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue] <= 0) {
        if (waitCounter >= 500) {
            break;
        }
        usleep(1000);
        
        err = nil;
        fileAttributes = [fileManager attributesOfItemAtPath:filenameFullPath error:&err];
        if (!fileAttributes) {
            NSLog(@"Failed to get attributes of item in file promise temporary directroy at path: %@", filenameFullPath);
            NSLog(@"%@", [err description]);
        }
        
        waitCounter++;
    }
    return [NSArray arrayWithObject:[tmpDirectory stringByAppendingPathComponent:filename]];
}

- (void)dealloc
{
    [supportedDraggingTypes release];
    [super dealloc];
}

@end
