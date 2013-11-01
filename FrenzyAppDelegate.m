//
//  FrenzyAppDelegate.m
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FrenzyAppDelegate.h"

@implementation FrenzyAppDelegate

static OSStatus dateTimeChanged(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData);

@synthesize window, aboutWindow, statusItem, lastAppInfo, dropboxMonitor, shareItem, dragOperationInProgress;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(menuItemClicked:) name:@"MenuItemClicked" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(hotKeyUpdated) name:@"HotKeyUpdated" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(firstLaunchCompleted) name:@"FirstLaunchCompleted" object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reloadFeed) name:@"ReloadFeed" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reloadEverything) name:@"ReloadEverything" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(unreadItemsUpdated:) name:@"UnreadItemsUpdated" object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(systemClockChanged) name:@"NSSystemClockDidChangeNotification" object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFeed)
                                                 name:NSApplicationDidChangeScreenParametersNotification object:nil];
    
	BOOL testFirstLaunch = NO;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (IsEmpty([defaults objectForKey:@"displayName"]))
		[defaults setObject:[self addressBookFirstName] forKey:@"displayName"];
	
	if ([defaults objectForKey:@"userImage"] == nil)
		[defaults setObject:[self addressBookImage] forKey:@"userImage"];
	
   	if (![firstLaunch dropboxInstallCheck]) return;
    
	// If no preference for shared folders to use Frenzy with is set, then show first launch screens
	if (![[Dropbox sharedDropbox] activeSharedFolders] || [[[Dropbox sharedDropbox] activeSharedFoldersFullPaths] count] <= 0 || ![[Dropbox sharedDropbox] isDropboxInstalled] || testFirstLaunch) {
		isFirstLaunch = YES;
		[firstLaunch firstLaunch];
	} else {
		isFirstLaunch = NO;
		[self checkActiveFolders];
	}

	if ([defaults objectForKey:@"startAtLogin"] == nil) {
		[defaults setBool:YES forKey:@"startAtLogin"];
		[LoginItem ensureAutoLaunch:YES];
	} else {
		if ([defaults boolForKey:@"startAtLogin"]) {
			[LoginItem ensureAutoLaunch:YES];
		} else {
			[LoginItem ensureAutoLaunch:NO];
		}
	}
	
	if ([defaults objectForKey:@"autoHide"] == nil)
		[defaults setBool:YES forKey:@"autoHide"];    
    

	if (isSystemLeopard()) [self setupTimeChangeNotification];
}

- (void)firstLaunchCompleted
{
	isFirstLaunch = NO;
	[self checkActiveFolders];
}

- (void)checkActiveFolders
{
	BOOL activeFoldersFound = [[Dropbox sharedDropbox] createFrenzyFolders];
	
	if (!activeFoldersFound) {
		isFirstLaunch = YES;
		[firstLaunch dropboxFoldersChanged];
		[firstLaunch firstLaunch];
	} else {
		[self initializeFrenzy];
	}
}

- (void)awakeFromNib
{
	[[SUUpdater alloc] init];
}

- (void)initializeFrenzy
{	
	clockSkew = [[ClockSkew alloc] init];
	[clockSkew updateClockSkew];
	
	applicationConnectors = [[ApplicationConnectors alloc] init];
	
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kPreferenceGlobalShortcut handler:^{
        [self hitMainHotKey];
    }];
    
	FeedItemsDisplay *feedItemsDisplay = [[FeedItemsDisplay alloc] initWithWebView:webView];	
	[feedItemsDisplay loadItems];
	
	[shareItem setFeedItemsDisplay:feedItemsDisplay];
	[feedItemsDisplay release];

	DropboxMonitor *dMonitor = [[DropboxMonitor alloc] init];
	[self setDropboxMonitor:dMonitor];
	[dMonitor release];
	
	[shareItem updateTextViewEditability];
}

- (void)setupTimeChangeNotification
{
	// Have to do this through carbon as NSSystemClockDidChangeNotification isn't available on 10.5
	EventTypeSpec eventType = {kEventClassSystem, kEventSystemTimeDateChanged};
	OSStatus err = InstallApplicationEventHandler(NewEventHandlerUPP(dateTimeChanged), 1, &eventType, (void*)self, NULL);
	
	if (err)
        NSLog(@"Error setting up system time change notification");
}

- (NSData *)addressBookImage
{
	ABAddressBook *tempBook = [ABAddressBook addressBook];
	ABPerson *person = [tempBook me];
	
	NSBitmapImageRep *bits;
	
	if ([person imageData] != nil) { 	
		NSImage *userImage = [[NSImage alloc] initWithData:[person imageData]];
		bits = [NSBitmapImageRep imageRepWithData:[userImage TIFFRepresentation]];
		[userImage release];
	} else {
		NSImage *userImage = [NSImage imageNamed:@"empty-user"];
		bits = [NSBitmapImageRep imageRepWithData:[userImage TIFFRepresentation]];
	}
	
	NSData *data = [bits representationUsingType:NSPNGFileType properties:nil];
	return data;
}

- (NSString *)addressBookFirstName
{
	ABAddressBook *tempBook = [ABAddressBook addressBook];
	ABPerson *person = [tempBook me];
	NSString *firstName = [person valueForProperty:kABFirstNameProperty];
	if (IsEmpty(firstName)) return @"Unknown";
	return firstName;
}

static OSStatus dateTimeChanged(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData) 
{
    [(id)inUserData performSelector:@selector(systemClockChanged) withObject:nil afterDelay:2.0];
    return 0;
}

- (void)menuItemClicked:(NSNotification *)notif
{
	if ([window isVisible] && [window alphaValue] == 1.0) {
 		[self hideWindow];
	} else {   
        [self showWindow];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadCount" object:self userInfo:nil];			
}

- (void)showWindow
{
	if (isFirstLaunch) return;

    NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	[[scrollView documentView] scrollPoint:NSMakePoint(0, 0)];
	[scrollView display];
    
	[shareItem enableTextField];
	[firstLaunch hideArrow];
	[window positionUnderStatusItem:statusItem arrow:NO];

	[[self window] makeKeyAndOrderFront:nil];
	[[self window] enableCursorRects];
	[shareItem setFirstResponder];
	
	[window setAlphaValue:1.0];
	[window setIgnoresMouseEvents:NO];
}

- (void)hideWindow
{
	if (isFirstLaunch) return;

	[shareItem closePopup:YES clearTextEditor:YES];
    [[prefsButton cell] mouseExited:nil];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [[self window] orderOut:nil];
        [window setAlphaValue:1.0];
    }];
    
    [[NSAnimationContext currentContext] setDuration:0.1];  
	[[window animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
    
	[window setIgnoresMouseEvents:YES];
	
	[firstLaunch showArrow];	
	[shareItem setFirstResponder];
}

- (IBAction)showPreferencesMenu:(id)sender
{
    [NSMenu popUpContextMenu:[statusItem mainMenu] withEvent:[NSApp currentEvent] forView:sender];
}

- (IBAction)showPrefs:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
	[PrefsController showPrefs];
}

- (IBAction)showWebStore:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
}

- (IBAction)showAbout:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
	[frenzyAppUrl setHyperlink:[NSURL URLWithString:@"http://aptonic.github.io/frenzy"]];
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	[aboutVersion setStringValue:[NSString stringWithFormat:@"Version %@", version]];
	[NSApp activateIgnoringOtherApps:YES];
    [aboutWindow setLevel:NSStatusWindowLevel+2];
	[aboutWindow setCanHide:NO];
	[aboutWindow center];
	[aboutWindow makeKeyAndOrderFront:nil];
}

- (IBAction)checkUpdates:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
}

- (void)reloadFeed
{
	[[shareItem feedItemsDisplay] loadItems];
}

- (void)reloadEverything
{
	[[FeedStorage sharedFeedStorage] reSetupFeeds];
	[[self dropboxMonitor] reApplyPaths];
	[[shareItem feedItemsDisplay] loadItems];
	[shareItem updateTextViewEditability];
}

- (void)unreadItemsUpdated:(NSNotification *)notif
{
	[statusItem setUnreadCount:[[[notif userInfo] objectForKey:@"unreadCount"] intValue]];
}

- (void)systemClockChanged
{
	[clockSkew updateClockSkew];
    
}

- (void)applicationDidResignActive:(NSNotification *)aNotification
{
    NSDictionary *activeAppDict = [[NSWorkspace sharedWorkspace] activeApplication];
    NSString *activeApp = [activeAppDict objectForKey:@"NSApplicationName"];
    
    if ([self dragOperationInProgress] && [activeApp isEqualToString:@"Skitch"]) {
        [NSApp activateIgnoringOtherApps:YES];
        return;
    }
}

- (void)hitMainHotKey
{
    if (![[Dropbox sharedDropbox] checkFoldersActive]) return;
    if ([shareItem sharingDisabled]) return;
    
	// Use AppleScript to get the path of the selected file and upload it
    // Load the script from a resource by fetching its URL from within our bundle
	NSDictionary *errorDict;
	NSAppleEventDescriptor *returnDescriptor = NULL;
	NSAppleScript *appleScript = [applicationConnectors appleScriptForActiveApplication];
	
	returnDescriptor = [appleScript executeAndReturnError:&errorDict];
	
	//NSLog(@"output: %@", [returnDescriptor stringValue]);
	
	if (returnDescriptor != NULL) {
		// Successful execution
		if (kAENullEvent != [returnDescriptor descriptorType]) {
			// Script returned an AppleScript result
			if (cAEList == [returnDescriptor descriptorType]) {
				// Result is a list of other descriptors
			} else {
				NSString *scriptOutput = [[returnDescriptor stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([scriptOutput isEqualToString:@""]) return;
				
				NSArray *items = [applicationConnectors parseConnectorOutput:scriptOutput];
				
				NSDictionary *firstItem = [items objectAtIndex:0];
				[shareItem setFiles:nil];
				
				if ([[firstItem objectForKey:@"type"] isEqualToString:@"filepath"]) {
					// Sending files...
					[shareItem setFiles:items];
					
				}
				
				BOOL foundReplyItem = NO;
				
				[shareItem closePopup:NO clearTextEditor:YES];
				[self showWindow];
				
				// If re-sharing an item already in the feed, treat this as a reply to that item
				for (FeedItem *item in [[FeedStorage sharedFeedStorage] cachedFeedItems]) {
					if ([[item url] isEqualToString:[firstItem objectForKey:@"path"]]) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"FeedItemReply" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																														  item, @"feedItem", nil]];
						foundReplyItem = YES;
						break;
					}
				}
                
                NSString *firstItemTitle = [firstItem objectForKey:@"title"];
                
                if (IsEmpty(firstItemTitle)) 
                    firstItemTitle = [firstItem objectForKey:@"path"];
                
				[shareItem setItemDict:[NSDictionary dictionaryWithObjectsAndKeys:firstItemTitle, @"title", 
									[firstItem objectForKey:@"path"], @"url", nil]];

				if (!foundReplyItem) [shareItem popup:NO];
			}
		}
	} else {
		NSString *activeAppBundleID = [[[NSWorkspace sharedWorkspace] activeApplication] 
									   objectForKey:@"NSApplicationBundleIdentifier"];
		
		NSLog(@"AppleScript error while running connector for bundleID: \"%@\"\nError: %@", 
			  activeAppBundleID, [errorDict objectForKey:@"NSAppleScriptErrorMessage"]);
	}
}

@end
