//
//  FeedFileElements.m
//  Frenzy
//
//  Created by John Winter on 7/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "FeedFileElements.h"


@implementation FeedFileElements

@synthesize webView, feedItems, mainDOMDocument;

- (FeedFileElements *)init
{
	self = [super init];
	
	if (self) {
        sharedFilesHelper = [ShareFilesHelper sharedFilesHelper];
        fm = [NSFileManager defaultManager];
	}
	return self;
}

/*
 Files info
 All files shared - returns nil if no files were shared
 */
- (DOMElement *)filesInfo:(FeedItem *)feedItem index:(int)index
{
    if ([[feedItem type] isEqualToString:FeedItemFileType]) {
        DOMElement *filesInfo = [mainDOMDocument createElement:@"div"];
        [filesInfo setAttribute:@"class" value:@"file-list"];
        [filesInfo setAttribute:@"id" value:[feedItem itemID]];
        
        DOMElement *ul = [mainDOMDocument createElement:@"ul"];
        
        
        int fileIndex = 0;
        int numFilesTransferred = [[feedItem files] count];
        
        BOOL allFilesTransferred = YES;
        
        for (NSDictionary *fileDict in [feedItem files]) {
            DOMElement *li = [mainDOMDocument createElement:@"li"];
            
            NSImage *fileIcon;
            
            if ([[fileDict objectForKey:@"type"] isEqualToString:@"folder"])
                fileIcon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];	
            else
                fileIcon = [[NSWorkspace sharedWorkspace] iconForFileType:[[fileDict objectForKey:@"name"] pathExtension]];
            
            [fileIcon setSize:NSMakeSize(16, 16)];
            [fileIcon setScalesWhenResized:YES];
            
            NSImage *newIcon = [[NSImage alloc]
                                initWithSize:NSMakeSize(16, 16)];
            [newIcon lockFocus];
            [[NSGraphicsContext currentContext]
             setImageInterpolation:NSImageInterpolationHigh];
            [fileIcon drawInRect:NSMakeRect(0,0,16,16)
                        fromRect:NSMakeRect(0,0, [fileIcon size].width, [fileIcon size].height)
                       operation:NSCompositeCopy fraction:1.0];
            [newIcon unlockFocus];
            
            NSString *base64Encoded = [[newIcon TIFFRepresentation] base64EncodedString];
            [newIcon release];
            
            NSString *styleString = [NSString stringWithFormat: @"background:transparent url(data:image/png;base64,%@) no-repeat;", base64Encoded];
            [li setAttribute:@"style" value:styleString];
            
            BOOL wasFileTransferCompleted = [sharedFilesHelper wasFileTransferCompletedForItem:feedItem];
            
            if (![sharedFilesHelper hasItemTransferred:[fileDict objectForKey:@"name"] forFeedItem:feedItem 
                                    checkExistenceOnly:wasFileTransferCompleted]) {
                
                NSString *liClass = (wasFileTransferCompleted ? @"disabled-p" : @"disabled");
                [li setAttribute:@"class" value:liClass];
                allFilesTransferred = NO;
                numFilesTransferred--;
            }
            
            DOMElement *fileLink = [mainDOMDocument createElement:@"a"];
            NSString *fileLinkHref = [NSString stringWithFormat:@"javascript:window.FileController.open_fileIndex_(%d,%d)", index, fileIndex]; 
            [fileLink setAttribute:@"href" value:fileLinkHref];
            DOMText *fileLinkText = [mainDOMDocument createTextNode:[fileDict objectForKey:@"name"]];
            [fileLinkText setValue:[NSNumber numberWithInt:index] forKey:@"feedItemIndex"];
            [fileLinkText setValue:[NSNumber numberWithInt:fileIndex] forKey:@"fileIndex"];
            [fileLink setValue:[NSNumber numberWithInt:index] forKey:@"feedItemIndex"];
            [fileLink setValue:[NSNumber numberWithInt:fileIndex] forKey:@"fileIndex"];
            
            [fileLink appendChild:fileLinkText];
            [li appendChild:fileLink];
            [ul appendChild:li];
            
            fileIndex++;
        }
        
        BOOL hideRevealLink = NO;
        
        if (!allFilesTransferred) {
            NSString *fileInfo;
            NSString *fileStatusString;
            
            if ([[feedItem files] count] > 1) {
                BOOL foundFile = NO;
                
                for (NSDictionary *eachFile in [feedItem files]) {
                    if ([[eachFile objectForKey:@"type"] isEqualToString:@"file"]) {
                        foundFile = YES;
                        break;
                    }
                }
                
                if (foundFile)
                    fileInfo = @"files";
                else
                    fileInfo = @"folders";
                
            } else {
                fileInfo = [[[feedItem files] objectAtIndex:0] objectForKey:@"type"]; 
            }
            
            if ([sharedFilesHelper wasFileTransferCompletedForItem:feedItem]) {
                if (numFilesTransferred <= 0) hideRevealLink = YES;
                
                fileStatusString = (numFilesTransferred <= 0 ? [NSString stringWithFormat:@"%@ deleted", 
                                                                [self stringWithSentenceCapitalization:fileInfo]] : 
                                    [NSString stringWithFormat:@"Some %@ deleted", fileInfo]);
            } else {
                if ([[feedItem originalSender] isEqualToString:[[Dropbox sharedDropbox] uniqueID]]) {
                    fileStatusString = [NSString stringWithFormat:@"Copying %@", fileInfo];
                } else {
                    fileStatusString = [NSString stringWithFormat:@"Waiting for %@", fileInfo];
                }
            }
            
            DOMElement *fileStatusInfo = [mainDOMDocument createElement:@"p"];
            [fileStatusInfo setAttribute:@"class" value:@"file-status"];
            DOMText *fileStatusInfoText = [mainDOMDocument createTextNode:fileStatusString];
            
            [fileStatusInfo appendChild:fileStatusInfoText];
            [filesInfo appendChild:fileStatusInfo];
        }
        
        [filesInfo appendChild:ul];
        
        DOMElement *revealWrapper = [mainDOMDocument createElement:@"div"];
        [revealWrapper setAttribute:@"class" value:@"reveal"];
        
        DOMElement *revealLink = [mainDOMDocument createElement:@"a"];
        [revealLink setAttribute:@"class" value:@"reveal"];
        NSString *revealHref = [NSString stringWithFormat:@"javascript:window.FileController.reveal_(%d)", index]; 
        [revealLink setAttribute:@"href" value:revealHref];
        DOMText *revealLinkText = [mainDOMDocument createTextNode:@"Reveal in Finder"];
        [revealLink appendChild:revealLinkText];
        [revealWrapper appendChild:revealLink];
        if (!hideRevealLink && [[feedItem files] count] > 1) [filesInfo appendChild:revealWrapper];
        return filesInfo;
    } else {
        return nil;
    }
}

- (void)open:(int)index fileIndex:(int)fileIndex
{
	[self openOrReveal:index fileIndex:fileIndex reveal:NO viaMenu:NO];
}

- (void)reveal:(int)index
{
	[self openOrReveal:index fileIndex:0 reveal:YES viaMenu:NO];
}

- (void)openOrReveal:(int)index fileIndex:(int)fileIndex reveal:(BOOL)reveal viaMenu:(BOOL)viaMenu
{	
    FeedItem *feedItem = [[self feedItems] objectAtIndex:index];
	NSString *sharingPath = [[ShareFilesHelper sharedFilesHelper] sharingPathForItem:feedItem];
	
	BOOL success = NO;
	
	if (!IsEmpty([feedItem filesDirectory]) && !viaMenu) {
		NSString *filesDir = [sharingPath stringByAppendingPathComponent:[feedItem filesDirectory]];
		
		if (reveal) {
			NSString *revealDir = ([fm fileExistsAtPath:filesDir] ? filesDir : [filesDir stringByDeletingLastPathComponent]);
			success = [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:revealDir];
		} else {
			success = [[NSWorkspace sharedWorkspace] openFile:[filesDir stringByAppendingPathComponent:
                                                               [[[feedItem files] objectAtIndex:fileIndex] objectForKey:@"name"]]];
		}
	} else {
		NSDictionary *fileDict = [[feedItem files] objectAtIndex:(viaMenu ? fileIndex : 0)];
		NSString *filename;
        if (!IsEmpty([feedItem filesDirectory]))
            filename = [[sharingPath stringByAppendingPathComponent:[feedItem filesDirectory]] stringByAppendingPathComponent:[fileDict objectForKey:@"name"]];
        else
            filename = [sharingPath stringByAppendingPathComponent:[fileDict objectForKey:@"name"]];            

		if (reveal) {
			if ([fm fileExistsAtPath:filename])
				success = [[NSWorkspace sharedWorkspace] selectFile:filename inFileViewerRootedAtPath:nil];
			else
				success = [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:[filename stringByDeletingLastPathComponent]];
		} else {
			success = [[NSWorkspace sharedWorkspace] openFile:filename];
		}
	}
	
	if (!success)
		[self disableFileLink:index fileIndex:fileIndex revealLink:reveal];
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self 
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	[NSNumber numberWithBool:YES], @"noRefocus", nil]];	
}

- (NSString *)getFileStatus
{
	NSString *fileStatusJSON = [sharedFilesHelper getFileStatus:[self feedItems]];
	return fileStatusJSON;
}

- (void)disableFileLink:(int)feedItemIndex fileIndex:(int)fileIndex revealLink:(BOOL)revealLink
{
	WebScriptObject *scriptObject = [webView windowScriptObject];
    NSString *script = [NSString stringWithFormat:@"disableFileLink(%d,%d,%@)", feedItemIndex, fileIndex, (revealLink ? @"true" : @"false")];
    [scriptObject evaluateWebScript:script];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(reveal:) || aSelector == @selector(open:fileIndex:) || aSelector == @selector(getFileStatus)) {
        return NO;
    }
    return YES; 
}

- (NSString *)stringWithSentenceCapitalization:(NSString *)string
{
	return [NSString stringWithFormat:@"%@%@", [[string substringToIndex:1] capitalizedString], [string substringFromIndex:1]];
}

- (void)dealloc
{
    [webView release];
    [mainDOMDocument release];
    [feedItems release];
    [super dealloc];
}

@end
