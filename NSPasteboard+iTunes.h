//
//  NSPasteboard+iTunes.h
//  Dropzone
//
//  Created by John Winter on 26/04/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define AIiTunesTrackPboardType @"CorePasteboardFlavorType 0x6974756E" /* CorePasteboardFlavorType 'itun' */

@interface NSPasteboard(iTunes)

- (NSArray *)filenamesFromITunesDragPasteboard;


@end
