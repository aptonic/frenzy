//
//  SharedFoldersTable.m
//  Frenzy
//
//  Created by John Winter on 27/11/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "SharedFoldersTable.h"


@implementation SharedFoldersTable

@synthesize sharedFolders, activeSharedFolders;

- (void)updateFoldersTable:(BOOL)shouldScrollToTop
{	
	NSTableColumn *activeColumn = [foldersTable tableColumnWithIdentifier:@"active"];
	NSButtonCell *checkBox = [[[NSButtonCell alloc] init] autorelease];
	[checkBox setButtonType:NSSwitchButton];
	[checkBox setTitle:@""];
	[checkBox setState:NSOffState];
	[checkBox setImagePosition:NSImageOnly];
	[checkBox setRefusesFirstResponder:YES];
	[checkBox setControlSize:NSSmallControlSize];
	[activeColumn setDataCell:checkBox];

    NSArray *allFolders = [[[Dropbox sharedDropbox] sharedFolders] arrayByAddingObjectsFromArray:[[Dropbox sharedDropbox] alternativeFolders]];
    
	[self setSharedFolders:allFolders];
	[self setActiveSharedFolders:[NSMutableArray arrayWithArray:
								  [[Dropbox sharedDropbox] activeSharedFolders]]];
	
	[foldersTable reloadData];
    
    if (shouldScrollToTop) {
        [foldersTable scrollToBeginningOfDocument:nil];
        [foldersTable deselectAll:nil];
    }
    
    [self tableViewSelectionIsChanging:nil];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView 
{
    return [[self sharedFolders] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row 
{	
    id sharedFolder = [[self sharedFolders] objectAtIndex:row];
    
	if ([[tableColumn identifier] isEqualToString:@"active"]) {
        if ([sharedFolder isKindOfClass:[NSDictionary class]]) {

            if ([[(NSDictionary *)sharedFolder objectForKey:@"active"] boolValue])
                return [NSNumber numberWithInteger:NSOnState];
            else
                return [NSNumber numberWithInteger:NSOffState];
            
        } else {
            NSString *folder = [sharedFolder lastPathComponent];
            
            if ([[self activeSharedFolders] containsObject:folder])
                return [NSNumber numberWithInteger:NSOnState];
            else
                return [NSNumber numberWithInteger:NSOffState];
        }
		
	} else if ([[tableColumn identifier] isEqualToString:@"folder"]) {
        if ([sharedFolder isKindOfClass:[NSDictionary class]]) {
            return [[Dropbox sharedDropbox] folderDisplayName:[(NSDictionary *)sharedFolder objectForKey:@"path"]];
        } else {
            return [sharedFolder lastPathComponent];
        }
	}

	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row 
{     
   	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id sharedFolder = [[self sharedFolders] objectAtIndex:row];
    
    if ([sharedFolder isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *alternativeFolders = [[Dropbox sharedDropbox] alternativeFolders];
        NSMutableDictionary *selectedFolderDict = [NSMutableDictionary dictionaryWithDictionary:sharedFolder];
        
        int indexOfObjectToUpdate = [alternativeFolders indexOfObject:selectedFolderDict];
        if (indexOfObjectToUpdate == -1) return;
        
        if ([[selectedFolderDict objectForKey:@"active"] boolValue])
            [selectedFolderDict setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
        else
            [selectedFolderDict setObject:[NSNumber numberWithBool:YES] forKey:@"active"];
        
        [alternativeFolders replaceObjectAtIndex:indexOfObjectToUpdate withObject:selectedFolderDict]; 
        [defaults setObject:alternativeFolders forKey:@"alternativeFolders"];
    } else {
        NSString *folder = [sharedFolder lastPathComponent];
        
        if ([[self activeSharedFolders] containsObject:folder])
            [[self activeSharedFolders] removeObject:folder];
        else
            [[self activeSharedFolders] addObject:folder];
        
        [[self activeSharedFolders] sortUsingSelector:@selector(localizedCompare:)];
        
        [defaults setObject:[self activeSharedFolders] forKey:@"folders"];
    }
    
	[defaults synchronize];
	
	[[Dropbox sharedDropbox] createFrenzyFolders];
	[self updateFoldersTable:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadEverything" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadCount" object:self userInfo:nil];
}

-(void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
    if ([foldersTable selectedRow] == -1 || ![[[self sharedFolders] objectAtIndex:[foldersTable selectedRow]] isKindOfClass:[NSDictionary class]]) {
		[[aNotification object] deselectAll:self];
		[removeButton setHidden:YES];
	} else {
		[removeButton setHidden:NO];
	}
}

- (void)selectLastItem
{
    [foldersTable selectRowIndexes:[NSIndexSet indexSetWithIndex:[foldersTable numberOfRows] - 1] byExtendingSelection:NO];
    [foldersTable scrollToEndOfDocument:nil];
    [[foldersTable window] makeFirstResponder:foldersTable];
    [self tableViewSelectionIsChanging:nil];
}

- (IBAction)removeFolder:sender
{
    if ([foldersTable selectedRow] == -1) return;
    id selectedRowObject = [[self sharedFolders] objectAtIndex:[foldersTable selectedRow]];
    
    if (!IsEmpty(selectedRowObject) && [selectedRowObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *selectedFolderDict = (NSDictionary *)selectedRowObject;
        
        NSMutableArray *alternativeFolders = [[Dropbox sharedDropbox] alternativeFolders];
        [alternativeFolders removeObject:selectedFolderDict];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:alternativeFolders forKey:@"alternativeFolders"];
        [defaults synchronize];
        
        [self updateFoldersTable:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadEverything" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadCount" object:self userInfo:nil];
    }
}

- (void)dealloc
{
	[sharedFolders release];
	[super dealloc];
}

@end
