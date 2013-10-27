//
//  PrefsController.m
//  Frenzy
//
//  Created by John Winter on 9/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "PrefsController.h"
#import "FrenzyAppDelegate.h"

PrefsController *sharedPrefsControllerInstance = nil;

@implementation PrefsController

@synthesize initialDisplayName;

+ (void)initialize {
    DataToImageTransformer *transformer = [[DataToImageTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"DataToImageTransformer"];
    [transformer release];
}

- (PrefsController *)initWithWindowNibName:(NSString *)windowNibName;
{
	self = [super initWithWindowNibName:windowNibName];
	
	// Set up an NSViewAnimation to animate the transitions.
	viewAnimation = [[NSViewAnimation alloc] init];
	[viewAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[viewAnimation setAnimationCurve:NSAnimationEaseInOut];
	[viewAnimation setDelegate:self];
	
	toolbarIdentifiers = [[NSMutableArray alloc] init];
	toolbarViews = [[NSMutableDictionary alloc] init];
	toolbarItems = [[NSMutableDictionary alloc] init];
	
	return self;
}

+ (PrefsController *)prefsController
{
	return sharedPrefsControllerInstance;
}

- (void)windowDidLoad
{
	contentSubview = [[[NSView alloc] initWithFrame:[[[self window] contentView] frame]] autorelease];
	[contentSubview setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
	[[[self window] contentView] addSubview:contentSubview];
	[[self window] setShowsToolbarButton:NO];
}

-(BOOL)windowShouldClose:(id)sender
{
	return [self updateDisplayName];
}

- (void)awakeFromNib
{
    [shortcutView setAssociatedUserDefaultsKey:kPreferenceGlobalShortcut];
}

+ (void)showPrefs
{  
	if (!sharedPrefsControllerInstance)
		sharedPrefsControllerInstance = [[PrefsController alloc] initWithWindowNibName:@"Preferences"];

	if (![self isShowingPrefs]) {
		[[[sharedPrefsControllerInstance window] toolbar] setSelectedItemIdentifier:[[[[[sharedPrefsControllerInstance window] toolbar] visibleItems] objectAtIndex:0] itemIdentifier]];
		[sharedPrefsControllerInstance setupToolbar];
		[sharedPrefsControllerInstance displayViewForIdentifier:@"General" animate:NO];
        [sharedPrefsControllerInstance updateFoldersTable:YES];
	}
	[sharedPrefsControllerInstance showWindow:NSApp];
}

- (void)showWindow:(id)sender
{
	if (![[sharedPrefsControllerInstance window] isVisible])
		[[self window] center];
	
    [[self window] setLevel:NSStatusWindowLevel+1];
	[[self window] setCanHide:NO];
    [NSApp activateIgnoringOtherApps:YES];
	[[self window] makeKeyAndOrderFront:nil];

	[super showWindow:sender];
	[[self window] setDelegate:self];
	[self setInitialDisplayName:[[NSUserDefaults standardUserDefaults] objectForKey:@"displayName"]];
	[self focusNameField];
}

+ (BOOL)isShowingPrefs
{	
	if ([[sharedPrefsControllerInstance window] isVisible]) {
		return TRUE;
	} else {
		return FALSE;
	}
}

- (void)setupToolbar
{
	[self addView:generalView toolBarItem:generalToolbarItem label:@"General"];
	[self addView:dropboxView toolBarItem:dropboxToolbarItem label:@"Dropbox"];
}

- (void)addView:(NSView *)view toolBarItem:(NSToolbarItem *)toolBarItem label:(NSString *)label
{
	NSAssert(view != nil, @"Attempted to add a nil view when calling -addView:label:image:.");
	
	NSString *identifier = [[label copy] autorelease];
	
	[toolbarIdentifiers addObject:identifier];
	[toolbarViews setObject:view forKey:identifier];
	
	NSToolbarItem *item = toolBarItem;
	[item setTarget:self];
	[item setAction:@selector(toggleActivePreferenceView:)];
	
	[toolbarItems setObject:item forKey:identifier];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{	
	NSMutableArray *itemIdentifiers = [NSMutableArray array];
	
	for (id item in [[[self window] toolbar] visibleItems])
		[itemIdentifiers addObject:[item itemIdentifier]];
	
    return itemIdentifiers;
}

- (void)toggleActivePreferenceView:sender
{
	if ([[sender label] isEqualToString:@"Dropbox"])
		[sharedFoldersTable updateFoldersTable:NO];
	
	[self displayViewForIdentifier:[sender label] animate:YES];
}

- (void)updateFoldersTable:(BOOL)shouldScrollToTop
{
	[sharedFoldersTable updateFoldersTable:shouldScrollToTop];
}

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate
{	
	// Find the view we want to display.
	NSView *newView = [toolbarViews objectForKey:identifier];
	
	// See if there are any visible views.
	NSView *oldView = nil;
	if ([[contentSubview subviews] count] > 0) {
		// Get a list of all of the views in the window. Usually at this
		// point there is just one visible view. But if the last fade
		// hasn't finished, we need to get rid of it now before we move on.
		NSEnumerator *subviewsEnum = [[contentSubview subviews] reverseObjectEnumerator];
		
		// The first one (last one added) is our visible view.
		oldView = [subviewsEnum nextObject];
		
		// Remove any others.
		NSView *reallyOldView = nil;
		while ((reallyOldView = [subviewsEnum nextObject]) != nil) {
			[reallyOldView removeFromSuperviewWithoutNeedingDisplay];
		}
	}
	
	if (![newView isEqualTo:oldView]) {		
		NSRect frame = [newView bounds];
		frame.origin.y = NSHeight([contentSubview frame]) - NSHeight([newView bounds]);
		[newView setFrame:frame];
		[contentSubview addSubview:newView];
		[[self window] setInitialFirstResponder:newView];
		
		if (animate) {
			[self crossFadeView:oldView withView:newView];
		} else {
			[oldView removeFromSuperviewWithoutNeedingDisplay];
			[newView setHidden:NO];
			[[self window] setFrame:[self frameForView:newView] display:YES animate:animate];
		}
		
		[[self window] setTitle:[[toolbarItems objectForKey:identifier] label]];
	}
}

- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView
{
	[viewAnimation stopAnimation];
	
	
	[viewAnimation setDuration:0.10];
	
	NSDictionary *fadeOutDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									   oldView, NSViewAnimationTargetKey,
									   NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
									   nil];
	
	NSDictionary *fadeInDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									  newView, NSViewAnimationTargetKey,
									  NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
									  nil];
	
	NSDictionary *resizeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									  [self window], NSViewAnimationTargetKey,
									  [NSValue valueWithRect:[[self window] frame]], NSViewAnimationStartFrameKey,
									  [NSValue valueWithRect:[self frameForView:newView]], NSViewAnimationEndFrameKey,
									  nil];
	
	NSArray *animationArray = [NSArray arrayWithObjects:
							   fadeOutDictionary,
							   fadeInDictionary,
							   resizeDictionary,
							   nil];
	
	[viewAnimation setViewAnimations:animationArray];
	[viewAnimation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	NSView *subview;
	NSEnumerator *subviewsEnum = [[contentSubview subviews] reverseObjectEnumerator];

	// This is our visible view. Just get past it.
	[subviewsEnum nextObject];
	
	while ((subview = [subviewsEnum nextObject]) != nil) {
		[subview removeFromSuperviewWithoutNeedingDisplay];
	}
	
	(void)animation;
	
	[self focusNameField];
}

- (NSRect)frameForView:(NSView *)view
// Calculate the window size for the new view.
{
	NSRect windowFrame = [[self window] frame];
	NSRect contentRect = [[self window] contentRectForFrameRect:windowFrame];
	float windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
	
	windowFrame.size.height = NSHeight([view frame]) + windowTitleAndToolbarHeight;
	windowFrame.size.width = NSWidth([view frame]);
	windowFrame.origin.y = NSMaxY([[self window] frame]) - NSHeight(windowFrame);
	
	return windowFrame;
}

- (void)focusNameField
{
	if ([[[self window] title] isEqualToString:@"General"]) {
		[[self window] makeFirstResponder:displayNameField];
		[displayNameField selectText:nil];
	}
}

- (IBAction)addToLoginItems:sender
{
	if ([addToLoginItems state] == NSOnState)
		[LoginItem ensureAutoLaunch:YES];
	else
		[LoginItem ensureAutoLaunch:NO];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)autoHideChanged:sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateAutoHide" object:self userInfo:nil];	
}

- (IBAction)selectAvatar:sender
{
	IKImagePicker *picker = [IKImagePicker imagePicker];
	[picker setInputImage:[[[NSImage alloc] initWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"userImage"]] autorelease]]; 
	[picker setValue:[NSNumber numberWithBool:YES] forKey:IKImagePickerShowEffectsKey];
	
	NSDisableScreenUpdates();
	[picker beginImagePickerWithDelegate:self didEndSelector:@selector(imagePickerValidated:code:contextInfo:) contextInfo:nil];
	
	for (NSWindow *window in [NSApp windows]) {
		if ([[window title] isEqualToString:@"Edit Picture"]) {
			NSPoint windowOrigin = [[self window] frame].origin;
			windowOrigin.x = self.window.frame.origin.x + 38;
			windowOrigin.y = self.window.frame.origin.y + 15;
			[window setFrameOrigin:windowOrigin];
            [window setLevel:NSStatusWindowLevel+2];
			break;
		}
	}
	NSEnableScreenUpdates();
}

- (void)imagePickerValidated:(IKImagePicker *)imagePicker code:(int)returnCode contextInfo:(void *)ctxInf
{
    if (returnCode == NSOKButton){
        NSImage *outputImage = [imagePicker outputImage];
		
		[avatarImageView setImage:outputImage];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[[avatarImageView image] TIFFRepresentation] forKey:@"userImage"];
		[defaults synchronize];
		
		[[Dropbox sharedDropbox] createFrenzyFolders];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeed" object:self userInfo:nil];
    }
}

// Used for changing tab programmatically 
- (void)changeActiveTab:(NSString *)identifier
{
    NSToolbar *toolbar = [[self window] toolbar];
    NSToolbarItem *item = [toolbarItems objectForKey:identifier];
    
    [toolbar setSelectedItemIdentifier:[item itemIdentifier]];
    [self displayViewForIdentifier:identifier animate:NO];
    [self toggleActivePreferenceView:item];
}

- (BOOL)updateDisplayName
{	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *displayName = [defaults objectForKey:@"displayName"];

	if (IsEmpty(displayName)) {
        [self changeActiveTab:@"General"];
		NSRunAlertPanel(@"Display name empty", 
						@"You must enter a display name.", 
						@"OK", nil, nil);
		[[self window] makeFirstResponder:displayNameField];
		return NO;
	}
	
	if (![[self initialDisplayName] isEqualToString:displayName]) {
		[[Dropbox sharedDropbox] createFrenzyFolders];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeed" object:self userInfo:nil];
		[self setInitialDisplayName:displayName];
		[defaults synchronize];
	}
	
	return YES;
}

- (IBAction)changeDisplayName:(id)sender
{
	[self updateDisplayName];
}

- (IBAction)chooseFolder:(id)sender
{
    NSString *selectedDirectory = [[Dropbox sharedDropbox] chooseAlternativeFolder];

    if (!IsEmpty(selectedDirectory)) {
        NSDictionary *folderDict = [NSDictionary dictionaryWithObjectsAndKeys:selectedDirectory, @"path", 
                                    [NSNumber numberWithBool:YES], @"active", nil];
        NSDictionary *folderDictInactive = [NSDictionary dictionaryWithObjectsAndKeys:selectedDirectory, @"path", 
                                            [NSNumber numberWithBool:NO], @"active", nil];
        
        if ([[[Dropbox sharedDropbox] sharedFolders] containsObject:selectedDirectory] || 
            [[[Dropbox sharedDropbox] alternativeFolders] containsObject:folderDict] || 
            [[[Dropbox sharedDropbox] alternativeFolders] containsObject:folderDictInactive]) {
            NSRunAlertPanel(@"Folder already added", 
                            @"That folder is already setup with Frenzy.\n\nYou can activate or deactivate this folder using the tick boxes.", 
                            @"OK", nil, nil);
            
            return;
        }
        
        [[Dropbox sharedDropbox] addAlternativeFolder:folderDict];
        [sharedFoldersTable updateFoldersTable:YES];
        [sharedFoldersTable selectLastItem];
        [[Dropbox sharedDropbox] createFrenzyFolders];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadEverything" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearUnreadCount" object:self userInfo:nil];
    }
}

@end
