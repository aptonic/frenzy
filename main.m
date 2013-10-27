//
//  main.m
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	// This is to stop Frenzy hitting the file descriptor limit.
	// Every time we monitor another Dropbox folder or file we add another
	// descriptor and the default of 256 is not enough.
	
	struct rlimit rl = {0};
	int result = 0;
	
	result = getrlimit( RLIMIT_NOFILE, &rl );
	if (result != 0)
		NSLog(@"getrlimit = %d\n", errno );
	else {
		rl.rlim_cur = 9000;
		result = setrlimit( RLIMIT_NOFILE, &rl );
		if (result != 0)
			NSLog(@"setrlimit = %d\n", errno );
	}
	
    return NSApplicationMain(argc,  (const char **) argv);
}
