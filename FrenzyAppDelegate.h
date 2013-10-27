//
//  FrenzyAppDelegate.h
//  Frenzy
//
//  Created by John Winter on 8/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "StatusItem.h"
#import "TransparentWindow.h"
#import "ShareItem.h"
#import "FeedItemsDisplay.h"
#import "FeedStorage.h"
#import "FirstLaunch.h"
#import "DropboxMonitor.h"
#import "ApplicationConnectors.h"
#import "ClockSkew.h"
#import "OSDetect.h"
#import "DSClickableURLTextField.h"
#import "Sparkle/Sparkle.h"
#import "NSData-AES.h"
#import "MASShortcut.h"

#define kPreferenceGlobalShortcut @"GlobalShortcut"

@interface FrenzyAppDelegate : NSObject {
    TransparentWindow *window;
	IBOutlet StatusItem *statusItem;
	IBOutlet ShareItem *shareItem;
	IBOutlet FirstLaunch *firstLaunch;
	IBOutlet DSClickableURLTextField *frenzyAppUrl;
	IBOutlet NSWindow *aboutWindow;
	IBOutlet NSTextField *aboutVersion;
	IBOutlet WebView *webView;
	IBOutlet NSView *mainView;
	IBOutlet NSButton *prefsButton;
    IBOutlet NSMenuItem *checkForUpdatesMenuItem;
	NSDictionary *lastAppInfo;
	
	BOOL isFirstLaunch;
	BOOL hasShownWindow;
    BOOL dragOperationInProgress;
	DropboxMonitor *dropboxMonitor;
	ApplicationConnectors *applicationConnectors;
	ClockSkew *clockSkew;
    NSTimer *injectFeedItemTimer;
}

@property (assign) IBOutlet TransparentWindow *window;
@property (assign) IBOutlet StatusItem *statusItem;
@property (assign) IBOutlet NSWindow *aboutWindow;
@property (retain) NSDictionary *lastAppInfo;
@property (retain) DropboxMonitor *dropboxMonitor;
@property (retain) ShareItem *shareItem;
@property BOOL dragOperationInProgress;

- (IBAction)showPreferencesMenu:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)showAbout:(id)sender;
- (IBAction)showWebStore:(id)sender;
- (IBAction)checkUpdates:(id)sender;

- (void)hideWindow;
- (void)showWindow;
- (void)initializeFrenzy;
- (void)systemClockChanged;
- (void)setupTimeChangeNotification;
- (void)checkActiveFolders;
- (NSData *)addressBookImage;
- (NSString *)addressBookFirstName;

@end
