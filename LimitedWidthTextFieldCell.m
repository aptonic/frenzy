//
//  LimitedWidthTextFieldCell.m
//  Frenzy
//
//  Created by John Winter on 30/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "LimitedWidthTextFieldCell.h"


@implementation LimitedWidthTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{	
	cellFrame.size.width -= 25;
	[super drawWithFrame:cellFrame inView:controlView];
}

@end
