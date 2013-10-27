//
//  OSDetect.h
//  Frenzy
//
//  Created by John Winter on 24/07/08.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OSDetect : NSObject {

}

void detectOperatingSystem();
BOOL isSystemTiger();
BOOL isSystemLeopard();
BOOL isSystemSnowLeopard();
	
@end
