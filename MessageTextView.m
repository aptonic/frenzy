//
//  MessageTextView.m
//  Frenzy
//
//  Created by John Winter on 22/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "MessageTextView.h"


@implementation MessageTextView

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == 36) // enter key
    {
        NSUInteger modifiers = [theEvent modifierFlags];
        if ((modifiers & NSShiftKeyMask) || (modifiers & NSAlternateKeyMask)) {
            // option/alt held: new line
            [super insertNewline:self];
        } else {
            // straight enter key: perform action
            [button performClick:nil];
        }
    } else {
        // allow NSTextView to handle everything else
        [super keyDown:theEvent];
    }
}

- (void)awakeFromNib
{
    dragHandler = [DragHandler sharedDragHandler];
    NSArray *draggedTypeArray = [dragHandler supportedDraggingTypes];
    [self registerForDraggedTypes:draggedTypeArray];
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
    NSPasteboard *pb = [sender draggingPasteboard];
    [NSApp activateIgnoringOtherApps:YES];
    
    BOOL foundSupportedType = NO;
    for (NSString *type in [[dragHandler supportedDraggingTypes] arrayByRemovingObject:NSStringPboardType]) {
        if ([[pb types] containsObject:type]) {
            foundSupportedType = YES;
            break;
        }
    }
    
    if (foundSupportedType) 
        return [dragHandler performDragOperation:sender];
    else
        return [super performDragOperation:sender];
}

@end
