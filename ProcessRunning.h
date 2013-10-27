//
//  ProcessRunning.h
//  Frenzy
//
//  Created by John Winter on 3/08/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ProcessRunning : NSObject {

@private
    int numberOfProcesses;
    NSMutableArray *processList;
}

- (id)init;
- (int)numberOfProcesses;
- (void)obtainFreshProcessList;
- (BOOL)findProcessWithName:(NSString *)procNameToSearch;

@end
