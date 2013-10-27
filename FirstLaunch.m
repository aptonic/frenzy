//
//  FirstLaunch.m
//
//  Created by John Winter on 14/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "FirstLaunch.h"
#import "FrenzyAppDelegate.h"

@implementation FirstLaunch

@synthesize currentViewName;

- (void)firstLaunch
{
	// Set up a NSViewAnimation to animate the transitions.
	viewAnimation = [[NSViewAnimation alloc] init];
	[viewAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[viewAnimation setAnimationCurve:NSAnimationEaseInOut];
	[viewAnimation setDelegate:self];
	
	[contentSubview setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
	
	firstLaunchViews = [[NSMutableDictionary alloc] init];
	sharedFolderCheckboxes = [[NSMutableArray alloc] init];
    NSMutableArray *sharedFolderFullPaths = [NSMutableArray arrayWithArray:[[Dropbox sharedDropbox] sharedFoldersFullPathsThatExist]];
	showingFinalSetupView = NO;
	
	[self addView:selectFolderView label:@"Select Folders"];
	[self addView:createSharedFolderView label:@"Create Shared Folder"];
    [self addView:waitForSharedFolderView label:@"Wait for Shared Folder"];
	[self addView:finalSetupView label:@"Final Setup"];
	[self addView:installExtensionsView label:@"Install Extensions"];
	
	firefoxExtension = [[FirefoxExtension alloc] init];
	
	//NSArray *sharedFolders = [NSArray arrayWithObjects:@"test", nil];
	//NSArray *sharedFolders = nil;
    
	step = 0;
	
	if ([sharedFolderFullPaths count] < 1) {
		[firstLaunchTitle setStringValue:@"Welcome to Frenzy"];
		[self displayViewForIdentifier:@"Create Shared Folder" animate:NO];
        [firstLaunchWindow makeFirstResponder:sharedFolderName];
		[sharedFolderName selectText:nil];
	} else {
		[self prepareFolderSelection];
		[self displayViewForIdentifier:@"Select Folders" animate:NO];
	}
	
    [shortcutView setAssociatedUserDefaultsKey:kPreferenceGlobalShortcut];
	[firstLaunchWindow center];
	[firstLaunchWindow makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)addView:(NSView *)view label:(NSString *)label
{
	NSString *identifier = [[label copy] autorelease];
	[firstLaunchViews setObject:view forKey:identifier];
}

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate
{	
	// Find the view we want to display.
	NSView *newView = [firstLaunchViews objectForKey:identifier];
	
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
		[firstLaunchWindow setInitialFirstResponder:newView];
		[self setCurrentViewName:identifier];
		if (animate) {
			[self crossFadeView:oldView withView:newView];
		} else {
			[oldView removeFromSuperviewWithoutNeedingDisplay];
			[newView setHidden:NO];
			[firstLaunchWindow setFrame:[self frameForView:newView] display:YES animate:animate];
		}
	}
}

- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView
{
	[viewAnimation stopAnimation];
	
	
	[viewAnimation setDuration:0.25];
	
	NSDictionary *fadeOutDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									   oldView, NSViewAnimationTargetKey,
									   NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
									   nil];
	
	NSDictionary *fadeInDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									  newView, NSViewAnimationTargetKey,
									  NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
									  nil];
	
	NSDictionary *resizeDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									  firstLaunchWindow, NSViewAnimationTargetKey,
									  [NSValue valueWithRect:[firstLaunchWindow frame]], NSViewAnimationStartFrameKey,
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
	if (showingFinalSetupView) 	
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstLaunchCompleted" 
															object:self userInfo:nil];
	showingFinalSetupView = NO;
	(void)animation;
}

- (NSRect)frameForView:(NSView *)view
{
	NSRect windowFrame = [firstLaunchWindow frame];
	float topPadding = 70;
	float leftPadding = 150;
	
	windowFrame.size.height = NSHeight([view frame]) + topPadding;
	windowFrame.size.width = NSWidth([view frame]) + leftPadding;
	windowFrame.origin.y = NSMaxY([firstLaunchWindow frame]) - NSHeight(windowFrame);
	windowFrame.origin.x = NSWidth([[firstLaunchWindow screen] frame]) / 2 - NSWidth(windowFrame) / 2;
	
	return windowFrame;
}

- (IBAction)createSharedFolder:(id)sender
{
	if (step == 1) return;
	
   	NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *sharedFolderNameStr = [sharedFolderName stringValue];
    BOOL emptyName = [[sharedFolderNameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""];
    
    NSString *createPath = [[[Dropbox sharedDropbox] userDropboxPath] stringByAppendingPathComponent:sharedFolderNameStr];
    
    if (IsEmpty(sharedFolderNameStr) || emptyName) {
        NSRunAlertPanel(@"Folder name cannot be blank", 
						@"You must enter a name for the shared folder.", 
						@"OK", nil, nil);
        [sharedFolderName selectText:nil];
        return;
    } else if ([fileManager fileExistsAtPath:createPath]) {
        NSRunAlertPanel(@"Folder already exists", 
						@"There is already a folder with that name in your Dropbox folder.\n\nYou must pick another name or delete the existing folder.", 
						@"OK", nil, nil);
        [sharedFolderName selectText:nil];
        return;
    }
    
    NSError *err = nil;
    
    if (![fileManager createDirectoryAtPath:createPath withIntermediateDirectories:NO attributes:nil error:&err]) {
        NSLog(@"ERROR: Failed to create folder %@\n%@", createPath, [err description]);
        NSRunAlertPanel(@"Error creating folder", 
						@"There was a problem creating a folder with that name.\n\nTry a different name.", 
						@"OK", nil, nil);
        [sharedFolderName selectText:nil];
        return;
    }
    
    step = 1;
    
    [dropboxInstructionsLink setHyperlink:[NSURL URLWithString:@"https://www.dropbox.com/help/19"]];
    
    [self displayViewForIdentifier:@"Wait for Shared Folder" animate:YES];
    [self setupSpinner];
    
    NSString *shareFolderDropboxURL = [NSString stringWithFormat:@"https://www.dropbox.com/home/%@?share=1", sharedFolderNameStr];
    NSURL *dropboxURL = [NSURL URLWithString:[self urlEncodeValue:shareFolderDropboxURL]];
    [self performSelector:@selector(dropboxRedirect:) withObject:dropboxURL afterDelay:4];
    
    NSTimer *scanTimer = [[NSTimer scheduledTimerWithTimeInterval:1 
                                                          target:self 
                                                        selector:@selector(rescanSharedFolders:) 
                                                        userInfo:NULL repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:scanTimer forMode:NSEventTrackingRunLoopMode];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, NULL, kCFStringEncodingUTF8);
    return [result autorelease];
}

- (void)rescanSharedFolders:(NSTimer *)aTimer
{
    NSArray *sharedFolders = [[Dropbox sharedDropbox] sharedFolders];
    if ([sharedFolders count] > 0) {
        [createSharedFolderContinue setEnabled:YES];
        [createSharedFolderStatus setStringValue:@"Shared folder created"];
        [progressControl setHidden:YES];
        [firstLaunchWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        [greenTickImageView setHidden:NO withFade:YES];
        [aTimer invalidate];
        [spinnerTimer invalidate];
    }
}

- (void)setupSpinner
{
    AMIndeterminateProgressIndicatorCell *cell = [[[AMIndeterminateProgressIndicatorCell alloc] init] autorelease];
    [progressControl setCell:cell];
    [cell setSpinning:YES];
    
    spinnerTimer = [[NSTimer scheduledTimerWithTimeInterval:[cell animationDelay] 
                                                          target:self 
                                                        selector:@selector(animate:) 
                                                        userInfo:NULL repeats:YES] retain];
    // keep running while menu is open
    [[NSRunLoop currentRunLoop] addTimer:spinnerTimer forMode:NSEventTrackingRunLoopMode];
}

- (void)animate:(NSTimer *)aTimer
{	
	double value = fmod(([[progressControl cell] doubleValue] + (5.0/60.0)), 1.0);
	[[progressControl cell] setDoubleValue:value];
	[progressControl setNeedsDisplay:YES];
}

- (void)dropboxRedirect:(NSURL *)url
{
    [createSharedFolderStatus setStringValue:@"Waiting for shared folder"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)sharedFolderCreatedContinue:(id)sender
{
    NSArray *sharedFolders = [[Dropbox sharedDropbox] sharedFolders];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSArray arrayWithObjects:
                         [[sharedFolders objectAtIndex:0] lastPathComponent], nil] forKey:@"folders"];
    
    [defaults setObject:nil forKey:@"alternativeFolders"];
    [defaults synchronize];
    [self showFinalSetup:YES];
}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:nil];
}

- (IBAction)sharedFolderContinue:(id)sender
{
	if (step == 2) return;
	step = 2;
	
    NSArray *standardSharedFolders = [[Dropbox sharedDropbox] sharedFolders];
    NSMutableArray *sharedFolderFullPaths = [NSMutableArray arrayWithArray:[[Dropbox sharedDropbox] sharedFoldersFullPathsThatExist]];
    
    // Save checked shared folders
	NSMutableArray *checkedStandardFolders = [NSMutableArray array];
    NSMutableArray *checkedAlternativeFolders = [NSMutableArray array];
	
    int loopCount = 0;
    
	for (NSButton *checkbox in sharedFolderCheckboxes) {
        BOOL isChecked = ([checkbox state] == NSOnState);
        
        if (loopCount < [standardSharedFolders count]) {
            if (isChecked)
                [checkedStandardFolders addObject:[checkbox title]];
        } else {
            if (isChecked) {
                NSDictionary *folderDict = [NSDictionary dictionaryWithObjectsAndKeys:[sharedFolderFullPaths objectAtIndex:loopCount], @"path", 
                                            [NSNumber numberWithBool:YES], @"active", nil];
                [checkedAlternativeFolders addObject:folderDict];                
            }
        }
        
        loopCount++;
	}

	if ([[checkedStandardFolders arrayByAddingObjectsFromArray:checkedAlternativeFolders] count] < 1) {
		NSRunAlertPanel(@"Need at least one folder", 
						@"You must choose at least one folder to use Frenzy with.", 
						@"OK", nil, nil);
		step = 1;
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:checkedStandardFolders forKey:@"folders"];
    [defaults setObject:checkedAlternativeFolders forKey:@"alternativeFolders"];
	[defaults synchronize];
	
	if (!dropboxFoldersChanged) {
		[self showFinalSetup:YES];
	} else {
		// Just needed to confirm shared folders, no need for other screens
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstLaunchCompleted" 
															object:self userInfo:nil];
		[firstLaunchWindow orderOut:nil];
	}
}

- (void)showFinalSetup:(BOOL)animate
{
	if (!animate)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstLaunchCompleted" 
															object:self userInfo:nil];
	else
		showingFinalSetupView = YES;
	
	arrowShowing = YES;
	
	if ([firefoxExtension isFirefoxInstalled]) {
		[finishSetupButton setTitle:@"Continue"];
		NSRect frame = [finishSetupButton frame];
		frame.size.width = 100;
		frame.origin.x = 334;
		[finishSetupButton setFrame:frame];
	}
	[self displayViewForIdentifier:@"Final Setup" animate:animate];
	[self performSelector:@selector(showArrow) withObject:nil afterDelay:0.3];
}

- (IBAction)finishSetup:(id)sender;
{
	if (step == 3) return;
	step = 3;
	
	[self hideArrow];
	[arrowWindow orderOut:nil];
	arrowShowing = NO;
	
	if ([firefoxExtension isFirefoxInstalled]) {
		[firstLaunchTitle setStringValue:@"Install Firefox extension"];
		[self displayViewForIdentifier:@"Install Extensions" animate:YES];

        [imageView setHidden:YES withFade:YES];
		[self performSelector:@selector(showFirefoxImage) withObject:nil afterDelay:0.2];

	} else {
		[firstLaunchWindow orderOut:nil];
	}
}

- (IBAction)firefoxFinishSetup:(id)sender
{
	[firstLaunchWindow orderOut:nil];
	
	if ([installFirefoxExtension state] == NSOnState)
		[firefoxExtension installExtension];
}

- (void)showFirefoxImage
{
    [firefoxImageView setHidden:NO withFade:YES];
}

- (void)startArrowAnimation
{	
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	pulseAnimation.fromValue = [NSNumber numberWithFloat:0.2];
	pulseAnimation.toValue = [NSNumber numberWithFloat: 1.0];
	pulseAnimation.duration = 1;
	pulseAnimation.repeatCount = INFINITY;
	pulseAnimation.autoreverses = YES;
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	
	[[arrowView layer] addAnimation:pulseAnimation forKey:@"pulseAnimation"];
}

- (void)hideArrow
{
	if (arrowShowing) {
		[[arrowView layer] removeAllAnimations];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[[arrowView layer] setHidden:YES];
		[CATransaction commit];
	}
}

- (void)showArrow
{
	if (arrowShowing && !isSystemLeopard()) {
		[arrowWindow orderFront:nil];
		[arrowWindow positionUnderStatusItem:statusItem arrow:YES];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[arrowView layer].opacity = 0;
		[CATransaction commit];
		[self startArrowAnimation];
		[[arrowView layer] setHidden:NO];
	}
}

- (void)prepareFolderSelection
{
    NSArray *sharedFolders = [[Dropbox sharedDropbox] sharedFoldersFullPathsThatExist];
	NSArray *activeFolders = [[Dropbox sharedDropbox] activeSharedFoldersFullPaths]; 
    
    [[selectFolderScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [sharedFolderCheckboxes removeAllObjects];
    
	int offsetY = 0;
	
	NSRect oldWindowFrame = [selectFolderScrollView frame];
	oldWindowFrame.size.height = 5 + 26 * [sharedFolders count];
	if (oldWindowFrame.size.height < 189) oldWindowFrame.size.height = 189;
	
	[selectFolderScrollView setFrame:oldWindowFrame];
	
	for (NSString *folder in sharedFolders) {
		NSString *folderName = [[Dropbox sharedDropbox] folderDisplayName:folder];
		NSButton *checkbox = [[NSButton alloc] initWithFrame:NSMakeRect(5, oldWindowFrame.size.height - 26 - offsetY, 370, 20)];
		[checkbox setTitle:folderName];
		[checkbox setButtonType:NSSwitchButton];
		[[checkbox cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[checkbox setFont:[NSFont systemFontOfSize:13]];
		
		if ([activeFolders containsObject:folder] || [sharedFolders count] == 1)
			[checkbox setState:NSOnState];
		else 
			[checkbox setState:NSOffState];
		
		[selectFolderScrollView addSubview:checkbox];
		[sharedFolderCheckboxes addObject:checkbox];
        [checkbox release];
		offsetY += 26;
	}
	
	NSScrollView *scrollView = (NSScrollView *)[[selectFolderScrollView superview] superview];
	NSPoint newScrollOrigin;
	
	if ([[scrollView documentView] isFlipped])
		newScrollOrigin = NSMakePoint(0.0, 0.0);
	else
		newScrollOrigin = NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]) - NSHeight([[scrollView contentView] bounds]));
	
	[[scrollView documentView] scrollPoint:newScrollOrigin];
}

- (void)dropboxFoldersChanged
{
	[firstLaunchTitle setStringValue:@"Your Dropbox folders have changed"];
	[sharedFolderContinue setTitle:@"OK"];
	dropboxFoldersChanged = YES;
}

- (BOOL)dropboxInstallCheck
{
	if (![[Dropbox sharedDropbox] isDropboxInstalled]) {
       	NSFileManager *fm = [NSFileManager defaultManager];
        
        // See if Dropbox is already in an Applications folder
       	NSArray *searchpaths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSAllDomainsMask, YES);
        NSString *dropboxAppPath;
        
        for (NSString *path in searchpaths) {
            dropboxAppPath = [path stringByAppendingPathComponent:@"Dropbox.app"];
            if ([fm fileExistsAtPath:dropboxAppPath]) {
                foundDropboxApp = YES;
                break;
            }
        }
        
        if (foundDropboxApp) {
            [installDropboxTopLine setStringValue:@"It looks like Dropbox is installed, but it is not linked to an account."];
            [installDropboxBottomLine setStringValue:@"Launch Dropbox and setup an account, then relaunch Frenzy."];
            [downloadDropbox setTitle:@"Launch Dropbox"];
            [installDropbox setTitle:@"Launch Dropbox"];
        }
        
        [dropboxImageView setRespondsToSingleClick:YES];
		[NSApp activateIgnoringOtherApps:YES];
        [installDropbox center];
        [installDropbox makeKeyAndOrderFront:nil];
        return NO;
	}
    return YES;
}

- (IBAction)downloadDropbox:(id)sender
{
    if (foundDropboxApp) {
        BOOL launchSuccess = [[NSWorkspace sharedWorkspace] launchApplication:@"Dropbox"];
        if (!launchSuccess)
            NSRunAlertPanel(@"Failed to launch Dropbox", 
                            @"The Dropbox application could not be launched. You may need to reinstall it.", 
                            @"OK", nil, nil);
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.dropbox.com/downloading?src=index"]];
    }
    
    [NSApp terminate:nil];
}

- (void)windowWillClose:(id)sender
{
	[NSApp terminate:nil];
}

- (void)chooseFolder:(id)sender
{
    NSString *selectedDirectory = [[Dropbox sharedDropbox] chooseAlternativeFolder];
    
    if (!IsEmpty(selectedDirectory)) {
        if (![[[Dropbox sharedDropbox] sharedFolders] containsObject:selectedDirectory]) {
            NSDictionary *folderDict = [NSDictionary dictionaryWithObjectsAndKeys:selectedDirectory, @"path", 
                                        [NSNumber numberWithBool:YES], @"active", nil];

            [[Dropbox sharedDropbox] addAlternativeFolder:folderDict];
        }
        
        [self prepareFolderSelection];
        
        if ([[self currentViewName] isEqualToString:@"Create Shared Folder"])
            [self displayViewForIdentifier:@"Select Folders" animate:YES];
    }
}

- (void)dealloc
{
	[firstLaunchViews release];
	[sharedFolderCheckboxes release];
    [currentViewName release];
	[super dealloc];
}

@end
