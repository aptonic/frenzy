//
//  PrefsController.h
//  Frenzy
//
//  Created by John Winter on 9/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginItem.h"
#import "SharedFoldersTable.h"
#import <Quartz/Quartz.h>
#import "DataToImageTransformer.h"
#import "IKImagePicker.h"
#import "MASShortcutView.h"
#import "MASShortcut+UserDefaults.h"

@interface PrefsController : NSWindowController <NSAnimationDelegate, NSWindowDelegate> {
	IBOutlet MASShortcutView *shortcutView;
	IBOutlet NSButton *addToLoginItems;
	IBOutlet NSImageView *avatarImageView;
	
	NSMutableDictionary *toolbarItems;
	NSMutableArray *toolbarIdentifiers;
	NSMutableDictionary *toolbarViews;
	NSView *contentSubview;
	NSViewAnimation *viewAnimation;
	NSString *initialDisplayName;
	
	IBOutlet NSView *generalView;
	IBOutlet NSView *dropboxView;
	IBOutlet NSToolbarItem *generalToolbarItem;
	IBOutlet NSToolbarItem *dropboxToolbarItem;
	IBOutlet SharedFoldersTable *sharedFoldersTable;
	IBOutlet NSTextField *displayNameField;
}

+ (void)showPrefs;
- (void)addView:(NSView *)view toolBarItem:(NSToolbarItem *)toolBarItem label:(NSString *)label;
- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate;
- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView;
- (NSRect)frameForView:(NSView *)view;
- (void)setupToolbar;
+ (BOOL)isShowingPrefs;
- (IBAction)addToLoginItems:sender;
- (IBAction)autoHideChanged:sender;
- (IBAction)changeDisplayName:(id)sender;
- (void)updateFoldersTable:(BOOL)shouldScrollToTop;
+ (PrefsController *)prefsController;
- (IBAction)selectAvatar:sender;
- (IBAction)chooseFolder:sender;
- (BOOL)updateDisplayName;
- (void)focusNameField;
- (void)changeActiveTab:(NSString *)identifier;

@property (retain) NSString *initialDisplayName;

@end
