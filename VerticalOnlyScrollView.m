//
//  VerticalOnlyScrollView.m
//  Dropzone
//
//  Created by John Winter on 23/03/09.
//  Copyright 2009 Wintersoft Limited. All rights reserved.
//

#import "VerticalOnlyScrollView.h"


@implementation VerticalOnlyScrollView

- (void)scrollClipView:(NSClipView *)aClipView toPoint:(NSPoint)newOrigin {
	newOrigin.x = [aClipView bounds].origin.x;
	[super scrollClipView:aClipView toPoint:newOrigin];
}

- (void)scrollToTop
{
	NSPoint topPoint;
	[self scrollClipView:[self contentView] toPoint:topPoint];
	[self reflectScrolledClipView:[self contentView]];
}

@end
