//
//  ShareItem.h
//  Frenzy
//
//  Created by John Winter on 10/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QuartzCore/QuartzCore.h"
#import "TransparentWindow.h"
#import "FeedItemsDisplay.h"
#import "FeedItem.h"
#import "PopupMaskView.h"
#import "NS(Attributed)String+Geometrics.h"
#import "GradientBackgroundTextFieldCell.h"
#import "ShareFilesHelper.h"

#define POPUP_BOX_PADDING 8
#define BUTTON_PADDING 8
#define MAX_BUTTON_AREA_HEIGHT 250
#define BUTTON_ROW_HEIGHT 25

@interface ShareItem : NSObject {
	IBOutlet NSView *mainView;
	IBOutlet NSTextView *textEditor;
	IBOutlet NSBox *textEditorContainer;
	IBOutlet NSView *shareButtonView;
	IBOutlet NSButton *shareButton;
	
	CALayer *popupContainerLayer;
	CALayer *popupInnerLayer;
	CATextLayer *headingLayer;
	
	NSTextField *shareTitle;
	NSDictionary *itemDict;
	NSArray *files;
	NSImage *popupImage;
	PopupMaskView *popupMaskView;
	
	FeedItemsDisplay *feedItemsDisplay;
	FeedStorage *feedStorage;
	
	BOOL shareLink;
	BOOL shareFiles;
	BOOL isReply;
	BOOL popupOpen;
	BOOL hasToggledReply;
    BOOL sharingDisabled;
	
	CALayer *lastActiveButton;
	
	int POPUP_WIDTH;
	
	FeedItem *replyToFeedItem;
	ShareFilesHelper *shareFilesHelper;
}

@property (retain) NSDictionary *itemDict;
@property (retain) NSArray *files;
@property (retain) FeedItemsDisplay *feedItemsDisplay;
@property (retain) NSTextField *shareTitle;
@property (retain) NSTextView *textEditor;
@property (retain) CALayer *lastActiveButton;
@property (retain) NSView *popupMaskView;
@property (retain) FeedItem *replyToFeedItem;
@property BOOL sharingDisabled;

- (IBAction)share:(id)sender;
- (CATextLayer *)addLabel:(NSString *)name toLayer:(CALayer *)layer;
- (id)imageRefFromURL:(NSURL *)url;
- (void)popup:(BOOL)messageOnly;
- (void)closePopup:(BOOL)animate clearTextEditor:(BOOL)clearTextEditor;
- (void)clearPopupLayer;
- (void)setFirstResponder;
- (CALayer *)addTextFieldLabel:(NSString *)name toLayer:(CALayer *)layer;
- (id)btnGenerator:(NSString *)title highlighted:(BOOL)highlighted;
- (int)addToButtons:(CALayer *)textLayer;
- (CALayer *)addButton:(NSString *)name highlighted:(BOOL)highlighted origin:(CGPoint)origin addLayer:(BOOL)addLayer;
- (NSArray *)activeFolders;
- (void)enableTextField;
- (void)updateTextViewEditability;
- (NSString *)getShareHeading;

@end
