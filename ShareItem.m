//
//  ShareItem.m
//  Frenzy
//
//  Created by John Winter on 10/06/10.
//  Copyright 2010 Aptonic Software. All rights reserved.
//

#import "ShareItem.h"


@implementation ShareItem

@synthesize itemDict, feedItemsDisplay, shareTitle, lastActiveButton, popupMaskView, replyToFeedItem, files, textEditor, sharingDisabled;

- (void)awakeFromNib
{
	shareFilesHelper = [ShareFilesHelper sharedFilesHelper];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(feedItemReply:) name:@"FeedItemReply" object:nil];
	
	CALayer *mainLayer = [mainView layer];
	
	CGRect mainLayerFrame = [mainLayer frame];
	//[textEditorContainer layer].zPosition = 1;
	[shareButtonView layer].zPosition = 2;
	[textEditor setTypingAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Lucida Grande" size:14.0], NSFontAttributeName, nil]];
	
	NSURL *popupImageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForImageResource:@"popup"]];
	popupImage = [NSImage imageNamed:@"popup.png"];
	
	popupContainerLayer = [CALayer layer];
	
	popupContainerLayer.frame = CGRectMake(SCROLLVIEW_OFFSET, MESSAGE_BOX_HEIGHT, mainLayerFrame.size.width - (SCROLLVIEW_OFFSET * 2), [popupImage size].height);
	popupContainerLayer.masksToBounds = YES;
	popupContainerLayer.zPosition = 0;
	
	[mainLayer addSublayer:popupContainerLayer];
	
	popupInnerLayer = [CALayer layer];
	id image = [self imageRefFromURL:popupImageURL];
	popupInnerLayer.contents = image;
	
	popupInnerLayer.anchorPoint = CGPointMake(0.0, 0.0);
	popupInnerLayer.frame = CGRectMake(0, -[popupImage size].height, [popupContainerLayer frame].size.width, [popupImage size].height);
	popupInnerLayer.masksToBounds = YES;
	
	POPUP_WIDTH = [popupInnerLayer frame].size.width;
	
	
	[popupContainerLayer addSublayer:popupInnerLayer];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(mouseEvent:) name:@"MouseEvent" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:NSControlTextDidChangeNotification object:nil];
}

- (void)addHeadingLayer:(NSString *)title
{
	headingLayer = [self addLabel:title toLayer:popupInnerLayer];
	headingLayer.frame = CGRectMake(POPUP_BOX_PADDING, 328, POPUP_WIDTH - (POPUP_BOX_PADDING * 2), 15);
	headingLayer.font = [NSFont fontWithName:@"Helvetica-Bold" size:12];
	CGColorRef headingColor = CGColorCreateGenericRGB(0, 0, 0, 0.5);
	headingLayer.foregroundColor = headingColor;
	CGColorRelease(headingColor);
	[headingLayer setValue:[NSNumber numberWithBool:YES] forKey:@"isHeading"];
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(cancelOperation:)) {
		if (popupOpen && isReply) 
			[self closePopup:YES clearTextEditor:YES];
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
				
		[self enableTextField];
		return YES;
	}
	return NO;
}

- (void)feedItemReply:(NSNotification *)notif
{
	FeedItem *feedItem = [[notif userInfo] objectForKey:@"feedItem"];

	hasToggledReply = NO;
	isReply = YES;
	[self setFiles:nil];
	[self setReplyToFeedItem:feedItem];
	
	[self popup:NO];
	[self setFirstResponder];
}

- (void)enableTextField
{
    if (!sharingDisabled) {
        if ((![[[textEditor textStorage] mutableString] isEqualToString:@""] || 
             ((shareLink || shareFiles) && !isReply)) && ([[self activeFolders] count] > 0 || isReply))
            [shareButton setEnabled:YES];
        else
            [shareButton setEnabled:NO];
    } else {
        [shareButton setEnabled:NO];
    }
}

- (void)textDidChange:(NSNotification *)aNotification
{
	if ([[[textEditor textStorage] mutableString] isEqualToString:@""] && !shareLink && !shareFiles && !isReply) {
		if (popupOpen) [self closePopup:YES clearTextEditor:YES];
	} else {
		if (!popupOpen) [self popup:YES];
	}
	
	[self enableTextField];
}

/* messageOnly is true if this is a plain message with no link, false if items are involved */

- (void)popup:(BOOL)messageOnly
{		
	popupOpen = YES;
	
	if (isReply) {
		if ([[[self replyToFeedItem] type] isEqualToString:FeedItemURLType]) {
			[self setItemDict:[NSDictionary dictionaryWithObjectsAndKeys:[[self replyToFeedItem] title], @"title", 
							   [[self replyToFeedItem] url], @"url", nil]];
			shareLink = YES;
			shareFiles = NO;
		} else if ([[[self replyToFeedItem] type] isEqualToString:FeedItemMessageType]) {
			[self setItemDict:[NSDictionary dictionaryWithObjectsAndKeys:[[[[self replyToFeedItem] messages] lastObject] objectForKey:@"message"], @"title", nil]];
			shareLink = NO;
			shareFiles = NO;
		} else if ([[[self replyToFeedItem] type] isEqualToString:FeedItemFileType]) {
			shareFiles = YES;
			shareLink = NO;
		}
	} else {
		if (messageOnly) {
			shareLink = NO;
			shareFiles = NO;
		} else {
			// Files or a link?
			if (!IsEmpty([self files])) {
				shareFiles = YES;
			} else {
				shareLink = YES;
			}
		}
	}
	
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	[self clearPopupLayer];
	
	CALayer *textLayer;
	
	if (messageOnly) {
		NSURL *popupImageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForImageResource:@"popup-n"]];
		id image = [self imageRefFromURL:popupImageURL];
		popupInnerLayer.contents = image;
		textLayer = [CALayer layer];
		textLayer.frame = CGRectMake(POPUP_BOX_PADDING, 357, 300, 80);
		[popupInnerLayer addSublayer:textLayer];
	} else {
        [self addHeadingLayer:[self getShareHeading]];
		
		NSURL *popupImageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForImageResource:@"popup"]];
		id image = [self imageRefFromURL:popupImageURL];
		popupInnerLayer.contents = image;
		
		NSMutableString *textLayerString = [NSMutableString string];
		
		if (shareFiles) {
			for (NSDictionary *dict in (isReply ? [[self replyToFeedItem] files] : [self files])) {
				[textLayerString appendFormat:@"• %@\n\n", (isReply ? [dict objectForKey:@"name"] : [[dict objectForKey:@"path"] lastPathComponent])];
			}
			
			[textLayerString replaceCharactersInRange:NSMakeRange([textLayerString length]-2, 2) withString:@""];
		} else {
			textLayerString = [[self itemDict] objectForKey:@"title"];
		}
		
		textLayer = [self addTextFieldLabel:textLayerString toLayer:popupInnerLayer];
		textLayer.frame = CGRectMake(POPUP_BOX_PADDING, 317 - [textLayer frame].size.height, [textLayer frame].size.width, [textLayer frame].size.height);
	}
		
	// Add line
	CALayer *lineLayer = [CALayer layer];
	
    lineLayer.frame = CGRectMake(0, textLayer.frame.origin.y - 18, 350, (mainView.window.backingScaleFactor > 1 ? 14:  15));
	lineLayer.masksToBounds = YES;

	NSImage *lineImage = [[NSImage alloc] initWithSize:NSMakeSize(550, 1)];
	[lineImage lockFocus];
		[[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.5] set]; 
		NSRectFill(NSMakeRect(0, 0.5, [lineImage size].width, [lineImage size].height));
	[lineImage unlockFocus];
	
	CGImageSourceRef finalImageSource = CGImageSourceCreateWithData((CFDataRef)[lineImage TIFFRepresentation], NULL);
	CGImageRef finalImage = CGImageSourceCreateImageAtIndex(finalImageSource, 0, NULL);
	CFRelease(finalImageSource);
	[lineImage release];
	lineLayer.contentsGravity = kCAGravityCenter;
	lineLayer.contents = (id)finalImage;
	CFRelease(finalImage);
	[popupInnerLayer addSublayer:lineLayer];
	int buttonsAreaHeight = [self addToButtons:textLayer];
	[CATransaction commit];
	
	NSRect popupMaskRect;
	
	if (messageOnly) {
		popupMaskRect = NSMakeRect(SCROLLVIEW_OFFSET, 59, 330, buttonsAreaHeight + 5);
	} else {
		if (isReply)
			popupMaskRect = NSMakeRect(SCROLLVIEW_OFFSET, 59, 330, [textLayer frame].size.height + 45);
		else
			popupMaskRect = NSMakeRect(SCROLLVIEW_OFFSET, 59, 330, [textLayer frame].size.height + buttonsAreaHeight + 45);
	}
	
	PopupMaskView *tmpPopupMaskView = [[PopupMaskView alloc] initWithFrame:popupMaskRect];
	[[[mainView window] contentView] addSubview:tmpPopupMaskView];
	[self setPopupMaskView:tmpPopupMaskView];
	[tmpPopupMaskView release];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.25f] forKey:kCATransactionAnimationDuration];	
	
	CGRect frame = popupInnerLayer.frame;
	
	if (isReply) buttonsAreaHeight = -3;
	
	if (messageOnly)
		frame.origin.y = buttonsAreaHeight - 344;
	else
		frame.origin.y = [textLayer frame].size.height + buttonsAreaHeight - 304;
	
	if (frame.origin.y > 0) frame.origin.y = 0;
	
	popupInnerLayer.frame = frame;
	[CATransaction commit];
	
	[self enableTextField];
}

- (int)addToButtons:(CALayer *)textLayer
{
	int buttonsAreaHeight = BUTTON_ROW_HEIGHT;
	int buttonYOffset = 37;
	float xPos = POPUP_BOX_PADDING;
	
	NSArray *sharedFolders = [[Dropbox sharedDropbox] activeSharedFoldersFullPaths];

	int rowWidth = 0;
    
	for (NSString *sharedFolder in sharedFolders) {
        
		BOOL buttonActive = NO;
		if ([sharedFolders count] == 1) buttonActive = YES;
			
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		if ([[defaults objectForKey:@"activeFolders"] containsObject:sharedFolder] && (!hasToggledReply && !isReply)) buttonActive = YES;
		
		CALayer *button = [self addButton:[sharedFolder lastPathComponent] highlighted:buttonActive origin:CGPointMake(0, 0) addLayer:NO];
		[button setValue:[NSNumber numberWithBool:buttonActive] forKey:@"active"];
		[button setValue:[NSNumber numberWithBool:YES] forKey:@"isButton"];

		[button setValue:sharedFolder forKey:@"folder"];

		rowWidth += [button frame].size.width + BUTTON_PADDING;
		
		if (rowWidth > POPUP_WIDTH - POPUP_BOX_PADDING) {
			// Start new row
			buttonYOffset += BUTTON_ROW_HEIGHT;
			buttonsAreaHeight += BUTTON_ROW_HEIGHT;
			xPos = POPUP_BOX_PADDING;
			rowWidth = [button frame].size.width + BUTTON_PADDING;
			
			// Max height
			if (buttonsAreaHeight > MAX_BUTTON_AREA_HEIGHT) return MAX_BUTTON_AREA_HEIGHT + 5;
		}
		
		[popupInnerLayer addSublayer:button];
		[button setFrame:CGRectMake(xPos, textLayer.frame.origin.y - buttonYOffset, [button frame].size.width, [button frame].size.height)];
		xPos += [button frame].size.width + BUTTON_PADDING;
	}
	
	buttonsAreaHeight += 5;
	
	if ([sharedFolders count] == 1)
		return -3;
	else
		return buttonsAreaHeight;
}

- (void)clearPopupLayer
{
	for (CALayer *layer in [[popupInnerLayer.sublayers copy] autorelease]) {
		[layer removeFromSuperlayer];
	}
	[[self popupMaskView] removeFromSuperview];
	[self setPopupMaskView:nil];
}

- (void)closePopup:(BOOL)animate clearTextEditor:(BOOL)clearTextEditor
{	
	shareLink = NO;
	shareFiles = NO;
	popupOpen = NO;
	isReply = NO;
	hasToggledReply = NO;
	
	if (animate) {
		[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithFloat:0.25f] forKey:kCATransactionAnimationDuration];	
	} else {
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}
	
	CGRect frame = popupInnerLayer.frame;
	frame.origin.y = -[popupImage size].height;
	popupInnerLayer.frame = frame;
			
	[self setShareTitle:nil];
	[CATransaction commit];
	
	if (clearTextEditor) [[[textEditor textStorage] mutableString] setString:@""];
	
	[[self popupMaskView] removeFromSuperview];
	[self setPopupMaskView:nil];
}

- (NSArray *)activeFolders
{
	NSMutableArray *activeFolders = [[NSMutableArray alloc] init];
	
	// Get array of active folders
	for (CALayer *layer in popupInnerLayer.sublayers) {
		if ([[layer valueForKey:@"isButton"] boolValue] && [[layer valueForKey:@"active"] boolValue]) {
			[activeFolders addObject:[layer valueForKey:@"folder"]];
		}
	}
	
	return [activeFolders autorelease];
}

- (IBAction)share:(id)sender
{	
    [shareButton setEnabled:NO];
	FeedItem *feedItem = [[FeedItem alloc] init];
	
	if (shareLink) {
		[feedItem setType:FeedItemURLType];
		[feedItem setTitle:[itemDict objectForKey:@"title"]];
		[feedItem setUrl:[[self itemDict] objectForKey:@"url"]];
	} else if (shareFiles) {
		[feedItem setType:FeedItemFileType];

		if (!isReply) {
			[shareFilesHelper createSharedFiles:[self files] inFolders:[self activeFolders] forItem:feedItem];
		}
	} else {
		[feedItem setType:FeedItemMessageType];
	}
	
	NSMutableArray *messages = [NSMutableArray array];
	
	if (isReply) {
		[feedItem setReplyTo:[[self replyToFeedItem] feedName]];
		[feedItem setReplyToID:[[self replyToFeedItem] uniqueID]];
		[feedItem setTo:[[self replyToFeedItem] sharedFolders]];
		[feedItem setReplaces:[[self replyToFeedItem] itemID]];
		[feedItem setFiles:[[self replyToFeedItem] files]];
		[feedItem setFilesDirectory:[[self replyToFeedItem] filesDirectory]];
		[feedItem setOriginalSender:[[self replyToFeedItem] originalSender]];
		[messages addObjectsFromArray:[[self replyToFeedItem] messages]];
		
		if (IsEmpty([[self replyToFeedItem] originalItemID]))
			[feedItem setOriginalItemID:[[self replyToFeedItem] itemID]];
		else
			[feedItem setOriginalItemID:[[self replyToFeedItem] originalItemID]];
	} else {
		[feedItem setTo:[self activeFolders]];
		[feedItem setOriginalSender:[[Dropbox sharedDropbox] uniqueID]];
	}
	
	if (!IsEmpty([[textEditor textStorage] string])) {
		NSDictionary *messageInfo = [NSDictionary dictionaryWithObjectsAndKeys:[[Dropbox sharedDropbox] uniqueID], @"sender", [[textEditor textStorage] string], @"message", [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] , @"timestamp", nil];
		[messages addObject:messageInfo];
	}
	
	[feedItem setMessages:messages];
		
	[[FeedStorage sharedFeedStorage] addItem:feedItem toSharedFolders:(isReply ? [[self replyToFeedItem] sharedFolders] : [self activeFolders])];
	[feedItem release];
	[[[textEditor textStorage] mutableString] setString:@""];
	[self setReplyToFeedItem:nil];
	[self setItemDict:nil];
	[self setFiles:nil];
	
	if (!isReply) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[self activeFolders] forKey:@"activeFolders"];
		[defaults synchronize];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self userInfo:nil];
	[feedItemsDisplay loadItems];
}

- (CATextLayer *)addLabel:(NSString *)name toLayer:(CALayer *)layer
{
	CATextLayer *textLayer = [CATextLayer layer];
	textLayer.string = name;
	
	textLayer.font = [NSFont systemFontOfSize:12];
	textLayer.fontSize = 12;
	CGColorRef labelColor = CGColorCreateGenericRGB(0, 0, 0, 0.7);
	textLayer.foregroundColor = labelColor;
	CGColorRelease(labelColor);
	textLayer.alignmentMode = kCAAlignmentLeft;
	textLayer.anchorPoint = CGPointMake(0, 0);
	textLayer.truncationMode = kCATruncationEnd;
	textLayer.shadowOpacity = 0.4;
	textLayer.shadowOffset = CGSizeMake(0, -0.5);
	textLayer.shadowRadius = 1;
	textLayer.masksToBounds = YES;
    textLayer.contentsScale = [mainView window].backingScaleFactor;
	
	[layer addSublayer:textLayer];
	return textLayer;
}

- (void)setFirstResponder
{
	[[textEditor window] makeFirstResponder:textEditor];
}

- (void)updateTextViewEditability
{
    if (!sharingDisabled) {
        if ([[[Dropbox sharedDropbox] activeSharedFoldersFullPaths] count] <= 0) {
            [textEditor setEditable:NO];
            [textEditor setSelectable:NO];
        } else {
            [textEditor setEditable:YES];
            [textEditor setSelectable:YES];
        }	
    } else {
        [textEditor setEditable:NO];
        [textEditor setSelectable:NO];
    }
}

- (CALayer *)addButton:(id)sharedFolder highlighted:(BOOL)highlighted origin:(CGPoint)origin addLayer:(BOOL)addLayer
{
	CALayer *buttonLayer = [CALayer layer];
	
	id buttonImg = [self btnGenerator:[[[Dropbox sharedDropbox] sharedFolderFullPath:sharedFolder activeOnly:YES] 
                                       lastPathComponent] highlighted:highlighted];
	
    if (mainView.window.backingScaleFactor > 1)
        buttonLayer.frame = CGRectMake(origin.x, origin.y,
								   (float)CGImageGetWidth((CGImageRef)buttonImg) / 2, (float)CGImageGetHeight((CGImageRef)buttonImg) / 2);
    else
        buttonLayer.frame = CGRectMake(origin.x, origin.y,
                                       (float)CGImageGetWidth((CGImageRef)buttonImg), (float)CGImageGetHeight((CGImageRef)buttonImg));
	
	[buttonLayer setValue:[NSNumber numberWithBool:YES] forKey:@"isButton"];
	[buttonLayer setValue:sharedFolder forKey:@"folder"];
	buttonLayer.contents = buttonImg;
	if (addLayer) [popupInnerLayer addSublayer:buttonLayer];
	
	return buttonLayer;
}

- (id)btnGenerator:(NSString *)title highlighted:(BOOL)highlighted
{
	NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(20, 90, 60, 20)];
	[button setButtonType:NSToggleButton];
	[button setBezelStyle:NSRoundRectBezelStyle];
	[button setBordered:YES];
	[button setTitle:title];
	[button setEnabled:YES];
	[button sizeToFit];
	if (highlighted) [button highlight:YES];
	
	NSRect frame = [button bounds];
	NSData *data = [button dataWithPDFInsideRect:frame];
	[button release];
	NSImage *snapShot = [[NSImage alloc] initWithData:data];
	NSImage *img = [[NSImage alloc] initWithSize:frame.size];
	
	[img lockFocus];
	[[NSColor clearColor] set];
	NSRectFill(frame);
    [snapShot drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[img unlockFocus];
	
	CGImageSourceRef finalImageSource = CGImageSourceCreateWithData((CFDataRef)[img TIFFRepresentation], NULL);
	CGImageRef finalImage = CGImageSourceCreateImageAtIndex(finalImageSource, 0, NULL);
	CFRelease(finalImageSource);
	[img release];
	[snapShot release];
	
	return [(id)finalImage autorelease];
}

- (CALayer *)addTextFieldLabel:(NSString *)name toLayer:(CALayer *)layer
{
    Class oldCellClass = [NSTextField cellClass];
	[NSTextField setCellClass:[GradientBackgroundTextFieldCell class]];

	NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 48)];
	[[label cell] setFont:[NSFont systemFontOfSize:12]];
	[[label cell] setLineBreakMode:NSLineBreakByWordWrapping];
	[label setAlignment:NSLeftTextAlignment];
	[[label cell] setTruncatesLastVisibleLine:YES];
	[label setStringValue:name];
	[label setTextColor:[NSColor colorWithCalibratedRed:0.35 green:0.35 blue:0.35 alpha:1]];
	[label setEditable:NO];
	[label setSelectable:NO];
	[label setBezeled:NO];
	[label setDrawsBackground:NO];
	
	NSShadow *sh = [[NSShadow alloc] init];
	[sh setShadowOffset:NSMakeSize(0, -1)];
	[sh setShadowColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.25]];
	[sh setShadowBlurRadius:3];
	
	NSMutableParagraphStyle *pSt = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[pSt setAlignment:[label alignment]];
	[pSt setLineBreakMode:NSLineBreakByWordWrapping];
	NSDictionary *atts = [NSDictionary dictionaryWithObjectsAndKeys:
						  [label font],NSFontAttributeName,
						  sh,NSShadowAttributeName,
						  [label textColor],NSForegroundColorAttributeName,
						  pSt,NSParagraphStyleAttributeName,nil];
	[sh release];
	[pSt release];
	
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:[label stringValue] attributes:atts];
	[label setAttributedStringValue:string];
	
	gNSStringGeometricsTypesetterBehavior = NSTypesetterBehavior_10_2_WithCompatibility;
	float height = [string heightForWidth:[label frame].size.width + 6];
	NSRect labelFrame = [label frame];
	labelFrame.size.height = height;
	[label setFrame:labelFrame];
	[string release];
	
   	[NSTextField setCellClass:oldCellClass];
    
	NSRect frame = [label bounds];
	NSData *data = [label dataWithPDFInsideRect:frame];
	[label release];
	NSImage *snapShot = [[NSImage alloc] initWithData:data];
	
	NSImage *img = [[NSImage alloc] initWithSize:frame.size];
	
	[img lockFocus];
	[[NSColor clearColor] set];
	NSRectFill(frame);
    [snapShot drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
	[img unlockFocus];
	
	CGImageSourceRef finalImageSource = CGImageSourceCreateWithData((CFDataRef)[img TIFFRepresentation], NULL);
	CGImageRef finalImage = CGImageSourceCreateImageAtIndex(finalImageSource, 0, NULL);
	CFRelease(finalImageSource);
	[img release];
	[snapShot release];
	
	CALayer *labelLayer = [CALayer layer];
    if (mainView.window.backingScaleFactor > 1)
        labelLayer.frame = CGRectMake(0, 0,
                                       (float)CGImageGetWidth((CGImageRef)finalImage) / 2, (float)CGImageGetHeight((CGImageRef)finalImage) / 2);
    else
        labelLayer.frame = CGRectMake(0, 0,
                                       (float)CGImageGetWidth((CGImageRef)finalImage), (float)CGImageGetHeight((CGImageRef)finalImage));
	
	[labelLayer setContents:(id)finalImage];
	[layer addSublayer:labelLayer];
	CFRelease(finalImage);
	
	return labelLayer;
}

- (id)imageRefFromURL:(NSURL *)url
{
	CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
	CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
	CFRelease(source);
	return [(id)image autorelease];
}

- (NSString *)getShareHeading
{
    if (isReply) {
        NSString *replyFormat = @"Reply to %@";
        NSString *recipient = [[self replyToFeedItem] feedName];
        
        if ([recipient isEqualToString:@"You"]) {
            BOOL found = NO;
            
            for (NSDictionary *message in [[[self replyToFeedItem] messages] reverseObjectEnumerator]) {
                if (![[message objectForKey:@"sender"] 
                      isEqualToString:[[Dropbox sharedDropbox] uniqueID]]) {
                    
                    recipient = [[[FeedStorage sharedFeedStorage] feedNames] 
                                 objectForKey:[message objectForKey:@"sender"]];
                    found = YES;
                }
            }
            if (!found)
                replyFormat = @"Reply";
        }
        return [NSString stringWithFormat:replyFormat, recipient];
    } else {        
        NSMutableString *headingString = [NSMutableString string];
        [headingString appendString:@"Share "];
        
        if (shareLink) {
            [headingString appendString:@"Link"];
        } else {
            NSFileManager *fm = [NSFileManager defaultManager];
            
            int numFolders = 0;
            int numFiles = 0;
            
            for (NSDictionary *eachFile in [self files]) {
                NSString *path = [eachFile objectForKey:@"path"];
                
                NSError *error = nil;
                NSDictionary *fattrs = [fm attributesOfItemAtPath:path error:&error];
                if (!fattrs) {
                    NSLog(@"Error getting file attributes for item with path %@\n%@", path, [error description]);
                    continue;
                }
                
                if ([fattrs objectForKey:NSFileType] == NSFileTypeDirectory)
                    numFolders++;
                else
                    numFiles++;
            }
            
            if (numFolders > 0 && numFiles <= 0)
                [headingString appendString:@"Folder"];
            else
                [headingString appendString:@"File"];
            
            if ([[self files] count] > 1) [headingString appendString:@"s"];
            
        }
        return headingString;
    }

}

- (void)mouseEvent:(NSNotification *)notif
{
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	NSEvent *event = [[notif userInfo] objectForKey:@"event"];
	
	CALayer *hitLayer = [[mainView layer] hitTest:NSPointToCGPoint([event locationInWindow])];
	CGPoint hitLayerOrigin = hitLayer.frame.origin;
	id folder = [hitLayer valueForKey:@"folder"];
	
	if ([event type] == NSLeftMouseDown) {
		if ([[hitLayer valueForKey:@"isButton"] boolValue]) {

			CALayer *activeButton = [self addButton:folder highlighted:YES origin:hitLayerOrigin addLayer:YES];
			[activeButton setValue:[hitLayer valueForKey:@"active"] forKey:@"active"];
			[activeButton setValue:[NSNumber numberWithBool:YES] forKey:@"highlighted"];
			[self setLastActiveButton:activeButton];
  			[hitLayer removeFromSuperlayer];
		} else {
			[self setLastActiveButton:nil];
		}
	} else if ([event type] == NSLeftMouseUp) {
		if ([[self lastActiveButton] isEqual:hitLayer]) {
			if ([[hitLayer valueForKey:@"highlighted"] boolValue]) {
				if ([[hitLayer valueForKey:@"active"] boolValue]) {
					[hitLayer removeFromSuperlayer];
					CALayer *activeButton = [self addButton:folder highlighted:NO origin:hitLayerOrigin addLayer:YES];
					[activeButton setValue:[NSNumber numberWithBool:NO] forKey:@"highlighted"];
					[activeButton setValue:[NSNumber numberWithBool:NO] forKey:@"active"];
					[self enableTextField];
					[self setLastActiveButton:activeButton];
				} else {
					[hitLayer setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
					[self enableTextField];
				}
			} else {				
				[hitLayer removeFromSuperlayer];
				CALayer *activeButton = [self addButton:folder highlighted:NO origin:hitLayerOrigin addLayer:YES];
				[activeButton setValue:[NSNumber numberWithBool:NO] forKey:@"highlighted"];
				[self setLastActiveButton:activeButton];
			}
		} else {
			if ((isReply && shareLink) || hasToggledReply) {
				if (!hasToggledReply) {
					hasToggledReply = YES;
					isReply = NO;
				} else {
					hasToggledReply = NO;
					isReply = YES;
				}
				
				[self popup:NO];
			}
		}
	} else if ([event type] == NSLeftMouseDragged) {
		if ([[self lastActiveButton] isEqual:hitLayer]) {
			CALayer *activeButton = [self addButton:folder highlighted:YES origin:hitLayerOrigin addLayer:YES];
			[activeButton setValue:[hitLayer valueForKey:@"active"] forKey:@"active"];
			[activeButton setValue:[NSNumber numberWithBool:YES] forKey:@"highlighted"];
			[self setLastActiveButton:activeButton];
            [hitLayer removeFromSuperlayer];
		} else {
			if ([[[self lastActiveButton] valueForKey:@"active"] boolValue]) return; 
			[[self lastActiveButton] removeFromSuperlayer];
			CALayer *activeButton = [self addButton:[[self lastActiveButton] valueForKey:@"folder"] highlighted:NO 
											 origin:[self lastActiveButton].frame.origin addLayer:YES];
			[activeButton setValue:[NSNumber numberWithBool:NO] forKey:@"highlighted"];
			[self setLastActiveButton:activeButton];
		}
	}
		
	[CATransaction commit];
}

@end
