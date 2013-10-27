//
//  NSImage+AppIconSwizzle.m
//  Frenzy
//
//  Created by John Winter on 27/12/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "NSImage+AppIconSwizzle.h"
#import <objc/runtime.h>


@implementation NSImage (AppIconSwizzle)

#define SetNSError(ERROR_VAR, FORMAT,...) \
if (ERROR_VAR) { \
NSString *errStr = [@"+[NSObject(JRSwizzle) jr_swizzleMethod:withMethod:error:]: " stringByAppendingFormat:FORMAT,##__VA_ARGS__]; \
*ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
code:-1 \
userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
}

+ (void)load
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    // have to call imageNamed: once prior to swizzling to avoid infinite loop
    [[NSApplicationFrenzy sharedApplication] applicationIconImage];
	
    // swizzle!
    NSError *error = nil;
	
    if (![NSImage jr_swizzleClassMethod:@selector(imageNamed:) withClassMethod:@selector(_sensible_imageNamed:) error:&error])
        NSLog(@"couldn't swizzle imageNamed: application icons will not update: %@", error);
	
    [pool release];
}


+ (id)_sensible_imageNamed:(NSString *)name
{
    if ([name isEqualToString:@"NSApplicationIcon"]) {
        return [NSImage imageNamed:@"icon-64"];
		
	}
	
    return [self _sensible_imageNamed:name];
}

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_ 
{
#if OBJC_API_VERSION >= 2
    Method origMethod = class_getClassMethod(self, origSel_);
    if (!origMethod) {
        SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
        return NO;
    }
	
    Method altMethod = class_getClassMethod(self, altSel_);
    if (!altMethod) {
        SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
        return NO;
    }
	
    id metaClass = objc_getMetaClass(class_getName(self));
	
    class_addMethod(metaClass,
                    origSel_,
                    class_getMethodImplementation(metaClass, origSel_),
                    method_getTypeEncoding(origMethod));
    class_addMethod(metaClass,
                    altSel_,
                    class_getMethodImplementation(metaClass, altSel_),
                    method_getTypeEncoding(altMethod));
	
    method_exchangeImplementations(class_getClassMethod(self, origSel_), class_getClassMethod(self, altSel_));
    return YES;
#else
    assert(0);
    return NO;
#endif
}


@end
