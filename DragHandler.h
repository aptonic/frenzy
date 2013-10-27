//
//  DragHandler.h
//  Frenzy
//
//  Created by John Winter on 4/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareItem.h"
#import "FrenzyAppDelegate.h"
#import "NSPasteboard+iTunes.h"

@interface DragHandler : NSObject <NSDraggingDestination> {
    NSArray *supportedDraggingTypes;
}

@property (retain) NSArray *supportedDraggingTypes;

+ (DragHandler *)sharedDragHandler;
- (NSDragOperation)handleDragEvent:(id <NSDraggingInfo>)theEvent;
- (NSArray *)filenamesFromHFSPromise:(id <NSDraggingInfo>)draggingInfo;
- (BOOL)validateUrl:(NSString *)candidate;

@end
