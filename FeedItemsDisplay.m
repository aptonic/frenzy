//
//  FeedItemsDisplay.m
//  Frenzy
//
//  Created by John Winter on 8/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "FeedItemsDisplay.h"
#import "FrenzyAppDelegate.h"

@implementation FeedItemsDisplay

@synthesize currentFeedItems;

- (FeedItemsDisplay *)initWithWebView:(WebView *)aWebView
{
	self = [super init];
	
	if (self) {
		webView = [aWebView retain];
		[webView setUIDelegate:self];
		[webView setPolicyDelegate:self];
		[webView setFrameLoadDelegate:self];
        
        feedElements = [[FeedElements alloc] init];
        feedFileElements = [[FeedFileElements alloc] init];
        [feedFileElements setWebView:webView];
        sharedFilesHelper = [ShareFilesHelper sharedFilesHelper];
        fm = [NSFileManager defaultManager];
	}
	return self;
}

- (void)loadItems
{
	NSArray *feedItems = [[FeedStorage sharedFeedStorage] feedItems];
	[self setCurrentFeedItems:feedItems];

	NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcesPath stringByAppendingString:@"/feed.html"];
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(deleteToggle:) name:@"DeleteToggle" object:nil];
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
        request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener 
{
    NSURL *url = [request URL];
    
	if ([url isFileURL]) {
		[listener use];
	} else {
        [[NSWorkspace sharedWorkspace] openURL:url];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MenuItemClicked" object:self 
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSNumber numberWithBool:YES], @"noRefocus", nil]];	
        [self simulateMouseUp:NSMakePoint(10, 10)];
	}
}

- (NSUInteger)webView:(WebView *)sender dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
    return WebDragDestinationActionNone;
}

- (NSUInteger)webView:(WebView *)webView dragSourceActionMaskForPoint:(NSPoint)point
{
	return WebDragDestinationActionNone;
}

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems 
{
	NSMutableArray *menuItems = [NSMutableArray arrayWithArray:defaultMenuItems];
	
	NSArray *itemsToRemove = [NSArray arrayWithObjects:[NSNumber numberWithInteger:WebMenuItemTagOpenLinkInNewWindow], 
							  [NSNumber numberWithInteger:WebMenuItemTagDownloadLinkToDisk], 
							  [NSNumber numberWithInteger:WebMenuItemTagReload],
							  [NSNumber numberWithInteger:WebMenuItemTagOpenImageInNewWindow], 
							  [NSNumber numberWithInteger:WebMenuItemTagDownloadImageToDisk], 
							  [NSNumber numberWithInteger:WebMenuItemTagOpenFrameInNewWindow], nil];
	
    NSString *webLinkURLKey = [[element objectForKey:WebElementLinkURLKey] absoluteString];
	if ([webLinkURLKey hasPrefix:@"javascript:"]) {
        
        if ([webLinkURLKey rangeOfString:@"open_fileIndex_"].location != NSNotFound) {
            // Right clicking on a file
            NSMenuItem *revealMenuItem = [[NSMenuItem alloc] initWithTitle:@"Reveal in Finder" action:@selector(revealFromMenuItem:) keyEquivalent:@""];
            [revealMenuItem setTarget:self];
            [revealMenuItem setRepresentedObject:[element objectForKey:@"WebElementDOMNode"]];
            return [NSArray arrayWithObject:revealMenuItem];
        } else {
            return nil;
        }
    }

	
	for (NSNumber *n in itemsToRemove) {
		NSUInteger toRemove = [[menuItems valueForKey:@"tag"] indexOfObject:n];
		if (toRemove != NSNotFound) 
			[menuItems removeObjectAtIndex:toRemove];
	}
	
    if ([menuItems count] >= 1) 
        if ([[menuItems objectAtIndex:0] isSeparatorItem]) [menuItems removeObjectAtIndex:0];
    
	return menuItems;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame 
{
	[[webView windowScriptObject] setValue:self forKey:@"AppController"];
    [[webView windowScriptObject] setValue:feedFileElements forKey:@"FileController"]; 
	
	NSArray *feedItems = [self currentFeedItems];
	//NSLog(@"Loading %d items", [feedItems count]);
    
	int index = 0;
	
	DOMDocument *myDOMDocument = [[webView mainFrame] DOMDocument];
	DOMElement *mainBlock = [myDOMDocument getElementById:@"feed-list"];
	
    [feedElements setMainDOMDocument:myDOMDocument];
    [feedElements setMainBlock:mainBlock];
    [feedFileElements setMainDOMDocument:myDOMDocument];
    [feedElements setFeedItems:feedItems];
    [feedFileElements setFeedItems:feedItems];
    
	if ([feedItems count] <= 0)
		[mainBlock appendChild:[feedElements feedEmptyDiv]];
	
	for (FeedItem *feedItem in feedItems) {
		DOMElement *item = [feedElements itemDiv:index];
        
        NSString *avatarPath = [feedItem avatarPathForUniqueID:[feedItem originalSender]];
		DOMElement *avatarImage = [feedElements avatarImage:avatarPath];
        
        if (![fm fileExistsAtPath:avatarPath])
            [item appendChild:[feedElements avatarPlaceholder]];
        
		[item appendChild:avatarImage];
		
        [item appendChild:[feedElements avatarShadow]];
        
        DOMElement *infoDiv = [feedElements infoDiv];
		[item appendChild:infoDiv];
		
        DOMElement *deleteButton = [feedElements deleteButton:feedItem index:index];
        if (deleteButton != nil) [infoDiv appendChild:deleteButton];
        
        DOMElement *replyButton = [feedElements replyButton:feedItem index:index];
        if (replyButton != nil) [infoDiv appendChild:replyButton];
        
		[infoDiv appendChild:[feedElements mainHeading:[feedItem actionText]]];
		
        DOMElement *itemURL = [feedElements itemURL:feedItem];
        if (itemURL != nil) [infoDiv appendChild:itemURL];
	
        DOMElement *itemMessage = [feedElements itemMessage:feedItem];
        if (itemMessage != nil) [infoDiv appendChild:itemMessage];
        
        DOMElement *filesInfo = [feedFileElements filesInfo:feedItem index:index];
        if (filesInfo != nil) [infoDiv appendChild:filesInfo];

        [infoDiv appendChild:[feedElements footerInfo:feedItem]];
		
        DOMElement *itemMessages = [feedElements messages:feedItem index:index];
   		if (itemMessages != nil) [item appendChild:itemMessages];
        
		[mainBlock appendChild:item];
		index++;
	}
	
    [self finalJSInit];
	[sender scrollPoint:NSMakePoint(0, 0)];
    [self performSelector:@selector(getScrollViewStatus) withObject:nil afterDelay:0.0];
}

- (void)getScrollViewStatus
{
    NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
    if ([scrollView hasVerticalScroller]) 
        [self webViewHasVerticalScrollbar];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(reply:) || aSelector == @selector(deleteItem:) || 
        aSelector == @selector(getPathStatus:) || aSelector == @selector(getLatestFooterInfo:)) {
        return NO;
    }
    return YES; 
}

- (void)reply:(int)index
{
    FeedItem *feedItem = [[self currentFeedItems] objectAtIndex:index];
	[self performSelector:@selector(replyNotify:) withObject:feedItem afterDelay:0];
}

- (void)replyNotify:(FeedItem *)feedItem
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FeedItemReply" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																									  feedItem, @"feedItem", nil]];
}

- (void)deleteItem:(int)index
{
    FeedItem *feedItem = [[self currentFeedItems] objectAtIndex:index];
	[NSApp activateIgnoringOtherApps:YES];
	int result = NSRunAlertPanel(@"Delete feed item", @"Are you sure?", @"Delete", @"Cancel", nil);
	if (result) {
		[[FeedStorage sharedFeedStorage] deleteItem:feedItem fromSharedFolders:([feedItem sharedFolders])];
		[self loadItems];
	}
}

- (void)deleteToggle:(NSNotification *)notif
{
	WebScriptObject *scriptObject = [webView windowScriptObject];
	BOOL optionHeld = [[[notif userInfo] objectForKey:@"modifiers"] boolValue];
    NSString *script = [NSString stringWithFormat:@"deleteButtonsToggle(%@)", (optionHeld ? @"true" : @"false")];
    [scriptObject evaluateWebScript:script];
}

- (void)finalJSInit
{
   	WebScriptObject *scriptObject = [webView windowScriptObject];
    NSString *script = [NSString stringWithFormat:@"finalJSInit()"];
    [scriptObject evaluateWebScript:script];
}

- (void)webViewHasVerticalScrollbar
{
    WebScriptObject *scriptObject = [webView windowScriptObject];
    NSString *script = [NSString stringWithFormat:@"webViewHasVerticalScrollbar()"];
    [scriptObject evaluateWebScript:script];
}

- (NSString *)getLatestFooterInfo:(int)index
{
    FeedItem *feedItem = [[self currentFeedItems] objectAtIndex:index];
    DOMElement *footerInfo = [feedElements footerInfo:feedItem];
    return [(DOMText *)[footerInfo firstChild] wholeText];
}

// Used for checking if a users avatar exists
- (BOOL)getPathStatus:(NSString *)path
{
    if (IsEmpty(path) || [[path className] isEqualToString:@"WebUndefined"]) return NO;
    
    if ([fm fileExistsAtPath:[[NSURL URLWithString:path] path]])
        return YES;
    else
        return NO;
}

- (void)revealFromMenuItem:(id)sender
{
    id element = [sender representedObject];
    
    int feedItemIndex = [[element valueForKey:@"feedItemIndex"] intValue];
    int fileIndex = [[element valueForKey:@"fileIndex"] intValue];
    
    [feedFileElements openOrReveal:feedItemIndex fileIndex:fileIndex reveal:YES viaMenu:YES];
    [self simulateMouseUp:NSMakePoint(10, 10)];
}

- (void)simulateMouseUp:(NSPoint)where
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    NSEvent* mouseUpEvent = [NSEvent mouseEventWithType:NSLeftMouseUp location:where
                                          modifierFlags:0 timestamp:GetCurrentEventTime() windowNumber:0 context:context eventNumber:1 clickCount:1 pressure:0];
    
    NSView *subView = [webView hitTest:[mouseUpEvent locationInWindow]];
    if(subView)
        [subView mouseUp: mouseUpEvent];
}

- (void)dealloc
{
	[webView release];
	[webWindow release];
    [feedElements release];
    [feedFileElements release];
	[super dealloc];
}

@end
