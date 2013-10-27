//
//  NSPasteboard+iTunes.m
//  Dropzone
//
//  Created by John Winter on 26/04/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "NSPasteboard+iTunes.h"


@implementation NSPasteboard(iTunes)

- (NSArray *)filenamesFromITunesDragPasteboard {
	NSDictionary* dict = [self propertyListForType:AIiTunesTrackPboardType];
	if (!dict) {
		return nil;
	}
	NSMutableArray* filenames = [NSMutableArray arrayWithCapacity:[dict count]];
	NSDictionary* tracks = [dict objectForKey:@"Tracks"];
	NSArray* trackIDs = [[[dict objectForKey:@"Playlists"] objectAtIndex:0] valueForKeyPath: @"Playlist Items.Track ID"];
	for (NSNumber* trackID in trackIDs) {
		[filenames addObject: [[NSURL URLWithString:[[tracks objectForKey:[trackID stringValue]] objectForKey:@"Location"]] path]];
	}
	return filenames;
}

@end
