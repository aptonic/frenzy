//
//  FeedElements.h
//  Frenzy
//
//  Created by John Winter on 6/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "FeedStorage.h"
#import "FeedItem.h"
#import "GHNSString+TimeInterval.h"

@interface FeedElements : NSObject {
    NSArray *feedItems;
    DOMDocument *mainDOMDocument;
    DOMElement *mainBlock;
    BOOL fadeButtonsActive;
}

@property (retain) NSArray *feedItems;
@property (retain) DOMElement *mainBlock;
@property (nonatomic, retain) DOMDocument *mainDOMDocument;

- (DOMElement *)feedEmptyDiv;
- (DOMElement *)itemDiv:(int)index;

- (DOMElement *)avatarImage:(NSString *)path;
- (DOMElement *)avatarShadow;
- (DOMElement *)avatarPlaceholder;

- (DOMElement *)infoDiv;
- (DOMElement *)mainHeading:(NSString *)text;

- (DOMElement *)replyButton:(FeedItem *)feedItem index:(int)index;
- (DOMElement *)deleteButton:(FeedItem *)feedItem index:(int)index;

- (DOMElement *)itemURL:(FeedItem *)feedItem;
- (DOMElement *)itemMessage:(FeedItem *)feedItem;
- (DOMElement *)messages:(FeedItem *)feedItem index:(int)index;

- (DOMElement *)footerInfo:(FeedItem *)feedItem;

@end
