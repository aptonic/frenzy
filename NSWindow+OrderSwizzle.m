//
//  NSWindow+OrderSwizzle.m
//  Frenzy
//
//  Created by John Winter on 6/06/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "NSWindow+OrderSwizzle.h"

@implementation NSWindow (NSWindow_OrderSwizzle)

+ (void)load {
    if (self == [NSWindow class]) {
        // Swap the implementations of -[NSWindow setLevel:] and -[NSWindow replacement_setLevel:].
        // When the -setLevel: message is sent to an NSWindow instance, -replacement_setLevel: will
        // be called instead. Calling [self replacement_setLevel:] thus calls the original method.
        Method originalMethod = class_getInstanceMethod(self, @selector(setLevel:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(replacement_SetLevel:));
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

- (void)replacement_SetLevel:(NSInteger)level {
    // Stop modalPanels being reordered behind the main window
    if ([[NSApp currentModalWindow] isEqual:self]) {
        return;
    } else {
        NSParameterAssert(_cmd == @selector(setLevel:));
        [self replacement_SetLevel:level];
    }
}

@end
