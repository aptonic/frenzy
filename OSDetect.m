//
//  OSDetect.m
//  Frenzy
//
//  Created by John Winter on 24/07/08.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "OSDetect.h"

@implementation OSDetect

enum {
    OS_NOT_SUPPORTED,
    OS_TIGER,
    OS_LEOPARD,
	OS_SNOWLEOPARD
};

static int _operatingSystem = OS_LEOPARD;

void detectOperatingSystem()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *version = [[dict objectForKey:@"ProductVersion"] substringToIndex:4];

	if ([version isEqualToString:@"10.4"]) {
		_operatingSystem = OS_TIGER;
	} else if ([version isEqualToString:@"10.5"]) {
		_operatingSystem = OS_LEOPARD;
	} else if ([version isEqualToString:@"10.6"]) {
		_operatingSystem = OS_SNOWLEOPARD;
	} else {
		_operatingSystem = OS_NOT_SUPPORTED;
	}
}

BOOL isSystemTiger() { detectOperatingSystem(); return (_operatingSystem == OS_TIGER); }
BOOL isSystemLeopard() { detectOperatingSystem(); return (_operatingSystem == OS_LEOPARD); }
BOOL isSystemSnowLeopard() { detectOperatingSystem(); return (_operatingSystem == OS_SNOWLEOPARD); }

@end
