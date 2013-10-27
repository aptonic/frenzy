//
//  FeedItemsDisplay.h
//  Frenzy
//
//  Created by John Winter on 8/01/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "FeedStorage.h"
#import "FeedItem.h"
#import "FeedElements.h"
#import "FeedFileElements.h"

@interface FeedItemsDisplay : NSObject {
	NSWindow *webWindow;
	WebView *webView;
	NSArray *currentFeedItems;
    FeedElements *feedElements;
    FeedFileElements *feedFileElements;
    ShareFilesHelper *sharedFilesHelper;
    NSFileManager *fm;
}

@property (retain) NSArray *currentFeedItems;

- (FeedItemsDisplay *)initWithWebView:(WebView *)aWebView;
- (void)loadItems;
- (void)finalJSInit;
- (void)webViewHasVerticalScrollbar;
- (void)simulateMouseUp:(NSPoint)where;

@end
