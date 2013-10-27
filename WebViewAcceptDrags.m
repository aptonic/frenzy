//
//  WebViewAcceptDrags.m
//  Frenzy
//
//  Created by John Winter on 4/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "WebViewAcceptDrags.h"


@implementation WebViewAcceptDrags

- (void)awakeFromNib
{
    dragHandler = [DragHandler sharedDragHandler];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return [dragHandler draggingEntered:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)theEvent
{
    return [dragHandler draggingUpdated:theEvent];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return [dragHandler prepareForDragOperation:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return [dragHandler performDragOperation:sender];
}

- (void)dealloc
{
    [super dealloc];
}

@end
