//
//  NSArray+RemoveObject.m
//  Frenzy
//
//  Created by John Winter on 6/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "NSArray+RemoveObject.h"


@implementation NSArray (NSArray_RemoveObject)

-(NSArray *)arrayByRemovingObject:(id)anObject
{
    if (anObject == nil) { return [[self copy] autorelease]; } //dodge an exception
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:self];
    [newArray removeObject:anObject];
    return [NSArray arrayWithArray:newArray];
}

@end
