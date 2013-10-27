//
//  ClockSkew.m
//  Frenzy
//
//  Created by John Winter on 24/10/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "ClockSkew.h"


@implementation ClockSkew

- (ClockSkew *)init
{
	self = [super init];
	
	if (self) {
		timeServers = [[NSArray alloc] initWithObjects:@"time-b.nist.gov",  @"nist.time.nosc.us", @"nist1-ny.ustiming.org", @"ntp-nist.ldsbc.edu", @"nist1-macon.macon.ga.us", nil];
		retryCount = 0;
	}
	return self;
}

- (void)hostLookUpComplete:(NSHost *)host
{
    [NSStream getStreamsToHost:host 
						  port:13
				   inputStream:&inputStream
				  outputStream:nil];
	
	[inputStream setDelegate:self];
	
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
	
	[inputStream open];
	[self startConnectionTimeoutTimer];
}

- (void)updateClockSkew
{
    [NSHost setHostCacheEnabled:NO];
	[NSHost hostWithName:[timeServers objectAtIndex:retryCount] inBackgroundForReceiver:self selector:@selector(hostLookUpComplete:)];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (aStream == inputStream) 
        [self handleInputStreamEvent:eventCode];
}

- (void)handleInputStreamEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
		case NSStreamEventHasBytesAvailable:
			[self readBytes:inputStream];
			break;
		case NSStreamEventEndEncountered:
			break;
        case NSStreamEventOpenCompleted:
            break;
        default:
        case NSStreamEventErrorOccurred:
            break;
    }
}

- (void)startConnectionTimeoutTimer
{
    [self stopConnectionTimeoutTimer];
    NSTimeInterval interval = 4.0;
    connectionTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:interval
															  target:self
															selector:@selector(handleConnectionTimeout)
															userInfo:nil
															 repeats:NO];
}

- (void)handleConnectionTimeout
{	
	[self shutdownConnection];
	connectionTimeoutTimer = nil;
    NSLog(@"Failed to aquire time from timeserver %@", [timeServers objectAtIndex:retryCount]);
	
	if (retryCount >= 3) {
		retryCount = 0;
		NSLog(@"Max retries exceeded");
		return;
	}
	
	retryCount++;
	[self performSelector:@selector(updateClockSkew) withObject:nil afterDelay:0.5];
}

- (void)shutdownConnection
{
	[inputStream setDelegate:nil];
	inputStream = nil;
}

// Call this when you successfully connect
- (void)stopConnectionTimeoutTimer
{
    if (connectionTimeoutTimer) {
        [connectionTimeoutTimer invalidate];
        connectionTimeoutTimer = nil;
    }
}

- (void)readBytes:(NSInputStream *)stream
{
	while ([stream hasBytesAvailable]) {
		int maxLength = 1024;
		uint8_t buffer[maxLength];
		int length = [stream read:buffer maxLength:maxLength];
		
		if (length > 0) {
			NSString *data = [[NSString alloc] initWithBytes:buffer length:length encoding:NSASCIIStringEncoding];
			if (data != nil) {
				int clockSkewReading = [self calculateClockSkew:data];
				if (clockSkewReading >= -1 && clockSkewReading < 2)
					clockSkewReading = 0;
				
                NSLog(@"Calculated clock deviation from UTC as %d using timeserver %@", clockSkewReading, [timeServers objectAtIndex:retryCount]);
                
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:[NSNumber numberWithInt:clockSkewReading] forKey:@"clockSkew"];
				[defaults synchronize];
                
                retryCount = 0;
                [self stopConnectionTimeoutTimer];
			}
			[data release];
			[self shutdownConnection];
		}
	}
}

- (int)calculateClockSkew:(NSString *)nistOutput
{
	NSArray *nistTimeComponents = [nistOutput componentsSeparatedByString:@" "];
	NSString *nistUTC = [NSString stringWithFormat:@"%@ %@", [nistTimeComponents objectAtIndex:1], [nistTimeComponents objectAtIndex:2]];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	[dateFormatter setTimeZone:timeZone];
	[dateFormatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
	NSDate *nistDate = [dateFormatter dateFromString:nistUTC];
	[dateFormatter release];
	
	NSDate *localDate = [NSDate date];
	NSString *clockSkewString = [NSString stringWithFormat:@"%.0f", 
								 [nistDate timeIntervalSince1970] - [localDate timeIntervalSince1970]];

	return [clockSkewString intValue];
}

- (void)dealloc
{
	[timeServers release];
    [self stopConnectionTimeoutTimer];
	[super dealloc];
}

@end
