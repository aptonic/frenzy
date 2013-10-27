//
//  FirstLaunch.h
//
//  Created by John Winter on 14/07/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QuartzCore/QuartzCore.h"
#import "Dropbox.h"
#import "TransparentWindow.h"
#import "FirefoxExtension.h"
#import "OSDetect.h"
#import "NSView+Fade.h"
#import "ClickableImageView.h"
#import "AMIndeterminateProgressIndicatorCell.h"
#import "DSClickableURLTextField.h"
#import "MASShortcutView.h"

@interface FirstLaunch : NSObject <NSAnimationDelegate> {
	IBOutlet NSWindow *firstLaunchWindow;
	IBOutlet TransparentWindow *arrowWindow;
	IBOutlet StatusItem *statusItem;
	IBOutlet MASShortcutView *shortcutView;
	
	NSViewAnimation *viewAnimation;
	NSMutableDictionary *firstLaunchViews;
	NSMutableArray *sharedFolderCheckboxes;
    NSTimer *spinnerTimer;
    NSString *currentViewName;
    BOOL foundDropboxApp;
	
	IBOutlet NSView *contentSubview;
	IBOutlet NSView *createSharedFolderView;
   	IBOutlet NSView *waitForSharedFolderView;
	IBOutlet NSView *selectFolderView;
	IBOutlet NSView *finalSetupView;
	IBOutlet NSView *installExtensionsView;
	IBOutlet NSView *arrowView;
	IBOutlet NSButton *finishSetupButton;
	IBOutlet NSButton *sharedFolderContinue;
    IBOutlet NSButton *createSharedFolderContinue;
    IBOutlet NSButton *downloadDropbox;
	IBOutlet NSTextField *firstLaunchTitle;
    IBOutlet NSTextField *sharedFolderName;
    IBOutlet NSTextField *createSharedFolderStatus;
    IBOutlet NSTextField *installDropboxTopLine;
    IBOutlet NSTextField *installDropboxBottomLine;
    IBOutlet DSClickableURLTextField *dropboxInstructionsLink;
	IBOutlet NSImageView *imageView;
	IBOutlet NSImageView *firefoxImageView;
    IBOutlet NSImageView *greenTickImageView;
	IBOutlet NSButton *installFirefoxExtension;
	IBOutlet NSView *selectFolderScrollView;
	IBOutlet NSControl *progressControl;
    IBOutlet NSWindow *installDropbox;
    IBOutlet ClickableImageView *dropboxImageView;
	
	BOOL arrowShowing;
	BOOL showingFinalSetupView;
	BOOL dropboxFoldersChanged;
	FirefoxExtension *firefoxExtension;
	
	int step;
}

@property (retain) NSString *currentViewName;

- (void)firstLaunch;
- (BOOL)dropboxInstallCheck;
- (void)prepareFolderSelection;
- (IBAction)createSharedFolder:(id)sender;
- (IBAction)sharedFolderContinue:(id)sender;
- (IBAction)sharedFolderCreatedContinue:(id)sender;
- (IBAction)finishSetup:(id)sender;
- (IBAction)firefoxFinishSetup:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)downloadDropbox:(id)sender;
- (IBAction)chooseFolder:(id)sender;
- (void)startArrowAnimation;
- (void)hideArrow;
- (void)showArrow;
- (void)showFinalSetup:(BOOL)animate;
- (void)dropboxFoldersChanged;
- (void)setupSpinner;

- (NSRect)frameForView:(NSView *)view;
- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView;
- (void)addView:(NSView *)view label:(NSString *)label;
- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate;

@end
