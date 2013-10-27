//
//  ClickableImageView.h
//  Frenzy
//
//  Created by John Winter on 15/02/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ClickableImageView : NSImageView {
    BOOL respondsToSingleClick;
}

@property BOOL respondsToSingleClick;

@end
