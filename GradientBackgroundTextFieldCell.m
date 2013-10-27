//
//  GradientBackgroundTextFieldCell.m
//  Frenzy
//
//  Created by John Winter on 21/03/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "GradientBackgroundTextFieldCell.h"


@implementation GradientBackgroundTextFieldCell

- (void)drawInteriorWithFrame:(NSRect)inCellFrame inView:(NSView*)inControlView
{
	[super drawInteriorWithFrame:inCellFrame inView:inControlView];
}

-(void)drawWithFrame:(NSRect)frame inView:(NSView *)control {
	NSImage *popupImage = [NSImage imageNamed:@"popup.png"];
    [popupImage setFlipped:YES];
    [popupImage drawAtPoint:NSMakePoint(0, -40) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[self drawInteriorWithFrame:frame inView:control];
}

@end
