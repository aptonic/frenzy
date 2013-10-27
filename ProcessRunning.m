//
//  ProcessRunning.m
//  Frenzy
//
//  Created by John Winter on 3/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "ProcessRunning.h"
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <sys/sysctl.h>

typedef struct kinfo_proc kinfo_proc;

@implementation ProcessRunning
- (id) init
{
    self = [super init];
	
    if (self != nil)
    {
        numberOfProcesses = -1; // means "not initialized"
        processList = NULL;
    }
	
    return self;
}

- (int)numberOfProcesses
{
    return numberOfProcesses;
}

- (void)setNumberOfProcesses:(int)num
{
    numberOfProcesses = num;
}

- (int)getBSDProcessList:(kinfo_proc **)procList
   withNumberOfProcesses:(size_t *)procCount
{
    int             err;
    kinfo_proc *    result;
    bool            done;
    static const int    name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    size_t          length;
	
    // a valid pointer procList holder should be passed
    assert( procList != NULL );
    // But it should not be pre-allocated
    assert( *procList == NULL );
    // a valid pointer to procCount should be passed
    assert( procCount != NULL );
	
    *procCount = 0;
	
    result = NULL;
    done = false;
	
    do
    {
        assert( result == NULL );
		
        // Call sysctl with a NULL buffer to get proper length
        length = 0;
        err = sysctl((int *)name,(sizeof(name)/sizeof(*name))-1,NULL,&length,NULL,0);
        if( err == -1 )
            err = errno;
		
        // Now, proper length is optained
        if( err == 0 )
        {
            result = malloc(length);
            if( result == NULL )
                err = ENOMEM;   // not allocated
        }
		
        if( err == 0 )
        {
            err = sysctl( (int *)name, (sizeof(name)/sizeof(*name))-1, result, &length, NULL, 0);
            if( err == -1 )
                err = errno;
			
            if( err == 0 )
                done = true;
            else if( err == ENOMEM )
            {
                assert( result != NULL );
                free( result );
                result = NULL;
                err = 0;
            }
        }
    }while ( err == 0 && !done );
	
    // Clean up and establish post condition
    if( err != 0 && result != NULL )
    {
        free(result);
        result = NULL;
    }
	
    *procList = result; // will return the result as procList
    if( err == 0 )
        *procCount = length / sizeof( kinfo_proc );
	
    assert( (err == 0) == (*procList != NULL ) );
	
    return err;
}

- (void)obtainFreshProcessList
{
    int i;
    kinfo_proc *allProcs = 0;
    size_t numProcs;
    NSString *procName;
	
    int err =  [self getBSDProcessList:&allProcs withNumberOfProcesses:&numProcs];
    if( err )
    {
        numberOfProcesses = -1;
        processList = NULL;
		
        return;
    }
	
    // Construct an array for ( process name )
    processList = [NSMutableArray arrayWithCapacity:numProcs];
    for( i = 0; i < numProcs; i++ )
    {
        procName = [NSString stringWithFormat:@"%s", allProcs[i].kp_proc.p_comm];
        [processList addObject:procName];
    }
	
    [self setNumberOfProcesses:numProcs];
	
    // NSLog(@"# of elements = %d total # of process = %d\n",
    //         [processArray count], numProcs );
	
    free( allProcs );
	
}

- (BOOL)findProcessWithName:(NSString *)procNameToSearch
{
    NSUInteger index;
	
    index = [processList indexOfObject:procNameToSearch];
	
    if( index == NSNotFound )
        return NO;
    else
        return YES;
}

@end