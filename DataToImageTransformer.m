//
//  DataToImageTransformer.m
//  Frenzy
//
//  Created by John Winter on 25/03/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "DataToImageTransformer.h"


@implementation DataToImageTransformer

+ (Class)transformedValueClass {
    return [NSImage class];
} // the class of the return value from transformedValue:

+ (BOOL)allowsReverseTransformation {
    return YES;
} // if YES then must also have reverseTransformedValue:

- (id)transformedValue:(id)value {
    if (value == nil || [value length] < 1) return nil;
    NSImage *i = nil;
    if ([value isKindOfClass:[NSData class]]) {
        i = [[[NSImage alloc] initWithData:value] autorelease];
    }
    return i;
}

- (id)reverseTransformedValue:(id)value {
    if (value == nil) return nil;
    NSData *d = nil;
    if ([value isKindOfClass:[NSImage class]]) {
        d = [value TIFFRepresentation];
    }
    return d;
}

@end
