//
//  NSImage+AppIconSwizzle.h
//  Frenzy
//
//  Created by John Winter on 27/12/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSApplicationFrenzy.h"

@interface NSImage (AppIconSwizzle)

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_;

@end
