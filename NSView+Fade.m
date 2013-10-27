//
//  NSView+Fade.m
//  Dropzone
//
//  Created by John Winter on 29/12/07.
//  Copyright 2009 Aptonic Software. All rights reserved.
//

#import "NSView+Fade.h"

@implementation NSView(Fade)

- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade 
{
	if(!fade){
		[self setHidden:hidden];
	}else{
		if(!hidden){
			[self setHidden:NO];
		}

		NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
		[animDict setObject:self forKey:NSViewAnimationTargetKey];
		[animDict setObject:(hidden ? NSViewAnimationFadeOutEffect : NSViewAnimationFadeInEffect) forKey:NSViewAnimationEffectKey];
		NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animDict]];
        [anim setAnimationBlockingMode:NSAnimationNonblocking];
        [anim setAnimationCurve:NSAnimationEaseInOut];
		[anim setDuration:0.15];
		[anim startAnimation];
		[anim autorelease];
	}
	
}

@end