//
//  ApplicationConnectors.h
//  Frenzy
//
//  Created by John Winter on 1/10/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ApplicationConnectors : NSObject {
	NSDictionary *connectorsDict;
}

- (NSAppleScript *)appleScriptForActiveApplication;
- (NSArray *)parseConnectorOutput:(NSString *)output;

@end
