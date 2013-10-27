//
//  FeedFileElements.h
//  Frenzy
//
//  Created by John Winter on 7/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "FeedItem.h"
#import "ShareFilesHelper.h"
#import "NSData+Base64.h"

@interface FeedFileElements : NSObject {
    WebView *webView;
    NSArray *feedItems;
    DOMDocument *mainDOMDocument;
    
    ShareFilesHelper *sharedFilesHelper;
    NSFileManager *fm;
}

@property (retain) WebView *webView;
@property (retain) NSArray *feedItems;
@property (retain) DOMDocument *mainDOMDocument;

- (DOMElement *)filesInfo:(FeedItem *)feedItem index:(int)index;

- (void)disableFileLink:(int)feedItemIndex fileIndex:(int)fileIndex revealLink:(BOOL)revealLink;
- (void)open:(int)index fileIndex:(int)fileIndex;
- (void)reveal:(int)index;
- (void)openOrReveal:(int)index fileIndex:(int)fileIndex reveal:(BOOL)reveal viaMenu:(BOOL)viaMenu;
- (NSString *)stringWithSentenceCapitalization:(NSString *)string;

@end
