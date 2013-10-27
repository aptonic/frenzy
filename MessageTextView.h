//
//  MessageTextView.h
//  Frenzy
//
//  Created by John Winter on 22/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareButton.h"
#import "DragHandler.h"
#import "NSArray+RemoveObject.h"

@interface MessageTextView : NSTextView {
	IBOutlet ShareButton *button;
    DragHandler *dragHandler;
}



@end
