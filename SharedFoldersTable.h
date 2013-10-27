//
//  SharedFoldersTable.h
//  Frenzy
//
//  Created by John Winter on 27/11/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dropbox.h"

@interface SharedFoldersTable : NSObject {
	NSArray *sharedFolders;
	NSMutableArray *activeSharedFolders;
	
	IBOutlet NSTableView *foldersTable;
	IBOutlet NSButton *removeButton;
}

@property (retain) NSArray *sharedFolders;
@property (retain) NSMutableArray *activeSharedFolders;

- (void)updateFoldersTable:(BOOL)shouldScrollToTop;
- (void)selectLastItem;
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification;
- (IBAction)removeFolder:sender;

@end
