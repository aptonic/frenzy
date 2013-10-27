//
//  ClickableImageView.m
//  Frenzy
//
//  Created by John Winter on 15/02/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "ClickableImageView.h"


@implementation ClickableImageView

@synthesize respondsToSingleClick;

- (void)mouseDown:(NSEvent *)theEvent { }

- (void)mouseUp:(NSEvent *)theEvent
{   
    int numClicks = ([self respondsToSingleClick] ? 1 : 2);
    
	if([theEvent clickCount] == numClicks)
		[self sendAction:[self action] to:[self target]];
}

@end
