//
//  ClockSkew.h
//  Frenzy
//
//  Created by John Winter on 24/10/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSHost+ThreadedAdditions.h"
#import "Dropbox.h"

@interface ClockSkew : NSObject <NSStreamDelegate> {
	NSInputStream *inputStream;
	NSTimer *connectionTimeoutTimer;
	NSArray *timeServers;
	int retryCount;
}

- (void)updateClockSkew;

- (void)handleInputStreamEvent:(NSStreamEvent)eventCode;
- (void)readBytes:(NSInputStream *)stream;
- (void)startConnectionTimeoutTimer;
- (void)stopConnectionTimeoutTimer;
- (void)shutdownConnection;
- (int)calculateClockSkew:(NSString *)nistOutput;

@end
