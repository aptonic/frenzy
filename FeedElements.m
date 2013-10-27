//
//  FeedElements.m
//  Frenzy
//
//  Created by John Winter on 6/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import "FeedElements.h"


@implementation FeedElements

@synthesize mainDOMDocument, mainBlock, feedItems;

/* 
 No items overlay div
 Displayed when no items in feed
 */
- (DOMElement *)feedEmptyDiv
{
    DOMElement *emptyDiv = [mainDOMDocument createElement:@"div"];
    [emptyDiv setAttribute:@"id" value:@"empty"];
    return emptyDiv;
}

/*
 A feed item
 Container div for everything an item displays
*/
- (DOMElement *)itemDiv:(int)index
{
    DOMElement *item = [mainDOMDocument createElement:@"div"];
    
    if (index == [feedItems count] - 1)
        [item setAttribute:@"class" value:@"feed-item-last"];
    else
        [item setAttribute:@"class" value:@"feed-item"];
    
    NSString *fadeButtonsClass = @"";
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fadeButtons"] boolValue]) {
        [item setAttribute:@"onmouseout" value:@"$(this).addClass('buttons-hidden'); $(this).removeClass('buttons-shown');"];
        [item setAttribute:@"onmouseover" value:@"$(this).removeClass('buttons-hidden'); $(this).addClass('buttons-shown');"];
        fadeButtonsClass = @" fade-button";
        fadeButtonsActive = YES;
    }
    
    return item;
}

/*
 Avatar image
 Draws the shadow and light overlay image
 */
- (DOMElement *)avatarImage:(NSString *)path
{
    DOMElement *avatarImage = [mainDOMDocument createElement:@"img"];    
    [avatarImage setAttribute:@"class" value:([[NSFileManager defaultManager] 
                                               fileExistsAtPath:path] ? @"avatar" : @"avatar-hidden")];
    
    NSString *dateString = [[NSString stringWithFormat:@"?%f",  [[NSDate date] timeIntervalSince1970]] 
                            stringByReplacingOccurrencesOfString:@"." withString:@""];
    [avatarImage setAttribute:@"src" value:[path stringByAppendingString:dateString]];
    return avatarImage;
}

/*
 Avatar shadow
 Draws the inner shadow
 */
- (DOMElement *)avatarShadow
{
    DOMElement *avatarShadow = [mainDOMDocument createElement:@"div"];
    [avatarShadow setAttribute:@"class" value:@"shad"];
    return avatarShadow;
}

/*
 Avatar placeholder
 Shows an empty user image placeholder
 */
- (DOMElement *)avatarPlaceholder
{
    DOMElement *avatarPlaceholder = [mainDOMDocument createElement:@"img"];
    [avatarPlaceholder setAttribute:@"src" value:@"empty-user.png"];
    [avatarPlaceholder setAttribute:@"class" value:@"avatar-empty"];
    return avatarPlaceholder;
}

/*
 Item info
 Container div for all info to the right of the avatar - messages, files links etc.
 */
- (DOMElement *)infoDiv;
{
    DOMElement *infoDiv = [mainDOMDocument createElement:@"div"];
    [infoDiv setAttribute:@"class" value:@"item-info"];
    return infoDiv;
}

/*
 Main heading
 Heading at top of item that describes the event
 */
- (DOMElement *)mainHeading:(NSString *)text
{
    DOMElement *mainHeading = [mainDOMDocument createElement:@"h2"];
    DOMText *headingText = [mainDOMDocument createTextNode:text];
    [mainHeading appendChild:headingText];
    return mainHeading;
}

/*
 Reply button
 Button that a user clicks to reply to an item - will return nil if showing a reply button is inappropriate
 */
- (DOMElement *)replyButton:(FeedItem *)feedItem index:(int)index
{
    NSString *fadeButtonsClass = (fadeButtonsActive ? @" fade-button" : @"");
    
    if ([[feedItem messages] count] > 1 || ![[feedItem feedName] isEqualToString:@"You"]) {
        DOMElement *replyButton = [mainDOMDocument createElement:@"a"];
        [replyButton setAttribute:@"class" value:[NSString stringWithFormat:@"%@%@", ([[feedItem feedName] isEqualToString:@"You"] ? @"reply-button-hasdelete" : @"reply-button"), fadeButtonsClass]];
        
        NSString *replyHref;
        
        if ([[feedItem originalSender] isEqualToString:@"1JDW1"])
            replyHref = @"mailto:john@aptonic.com?subject=Reply from Frenzy";
        else
            replyHref = [NSString stringWithFormat:@"javascript:window.AppController.reply_(%d)", index]; 
        
        [replyButton setAttribute:@"href" value:replyHref];
        return replyButton;
    } else {
        return nil;
    }
}

/*
 Delete button
 Button that a user clicks to delete an item - will return nil if user does not own the item
 */
- (DOMElement *)deleteButton:(FeedItem *)feedItem index:(int)index
{
    NSString *fadeButtonsClass = (fadeButtonsActive ? @" fade-button" : @"");
    
    if ([[feedItem feedName] isEqualToString:@"You"]) {
        DOMElement *deleteButton = [mainDOMDocument createElement:@"a"];
        
        if ([[feedItem messages] count] < 2)
            [deleteButton setAttribute:@"class" value:[NSString stringWithFormat:@"%@%@", @"delete-button-nohide", fadeButtonsClass]];
        else
            [deleteButton setAttribute:@"class" value:[NSString stringWithFormat:@"%@%@", @"delete-button", fadeButtonsClass]];
        
        NSString *deleteHref = [NSString stringWithFormat:@"javascript:window.AppController.deleteItem_(%d)", index]; 
        [deleteButton setAttribute:@"href" value:deleteHref];
        return deleteButton;
    } else {
        return nil;
    }
}

/*
 Item Title/URL
 The shared link - returns nil if no link was shared
 */
- (DOMElement *)itemURL:(FeedItem *)feedItem
{
    if ([feedItem title] != nil) {
        DOMElement *link = [mainDOMDocument createElement:@"a"];
        [link setAttribute:@"href" value:[feedItem url]];
        DOMText *linkText = [mainDOMDocument createTextNode:[feedItem title]];
        [link appendChild:linkText];
        
        DOMElement *linkWrapper = [mainDOMDocument createElement:@"div"];
        [linkWrapper setAttribute:@"class" value:@"link-wrapper"];
        [linkWrapper appendChild:link];
        return linkWrapper;
    } else {
        return nil;
    }
}

/*
 Item Message
 Returns the first item message if this FeedItem type is a FeedItemMessageType - returns nil if some other type
 */
- (DOMElement *)itemMessage:(FeedItem *)feedItem
{   
    if ([[feedItem type] isEqualToString:FeedItemMessageType]) {
        NSArray *messages = [feedItem messages];
        NSDictionary *firstMessage = [messages objectAtIndex:0];
        DOMElement *message = [mainDOMDocument createElement:@"p"];
        [message setAttribute:@"class" value:@"main-message"];
        
        NSArray *components = [[firstMessage objectForKey:@"message"] componentsSeparatedByString:@"\n"];
        
        for (NSString *line in components) {
            DOMText *messageText = [mainDOMDocument createTextNode:line];
            [message appendChild:messageText];
            
            DOMElement *lineBreak = [mainDOMDocument createElement:@"br"];
            [message appendChild:lineBreak];
        }

        return message;
    } else {
        return nil;
    }
}

/*
 Item messages
 All the messages shared along with an item - returns nil if there are no messages
 */
- (DOMElement *)messages:(FeedItem *)feedItem index:(int)index
{
    int messageNumber = 0;
    
    DOMElement *messagesWrapper = [mainDOMDocument createElement:@"div"];
    [messagesWrapper setAttribute:@"class" value:@"messages-wrapper"];
    
    DOMElement *hiddenMessages = [mainDOMDocument createElement:@"div"];
    [hiddenMessages setAttribute:@"class" value:@"hidden-messages"];
    
    BOOL skippedFirstMessage = NO;
    
    for (NSDictionary *eachMessage in [[feedItem messages] reverseObjectEnumerator]) {
        // itemMessage (see method above) will display first message shared if FeedItemMessageType
        // Because the messages are shown latest first, the first message that was shared is the last one through this loop
        if (messageNumber == [[feedItem messages] count] - 1 && [[feedItem type] isEqualToString:FeedItemMessageType]) {
            messageNumber++;
            skippedFirstMessage = YES;
            continue;
        }
        
        DOMElement *messageContainer = [mainDOMDocument createElement:@"div"];
        [messageContainer setAttribute:@"class" value:@"message"];
            
        DOMElement *messageHeader = [mainDOMDocument createElement:@"div"];
        [messageHeader setAttribute:@"class" value:@"msg-header"];
        
        DOMElement *sender = [mainDOMDocument createElement:@"div"];
        [sender setAttribute:@"class" value:@"from"];
        NSString *messgeSenderName = [[[FeedStorage sharedFeedStorage] feedNames] 
                                      objectForKey:[eachMessage objectForKey:@"sender"]];
        
        DOMText *senderText = [mainDOMDocument createTextNode:messgeSenderName];
        [sender appendChild:senderText];
        
        [messageHeader appendChild:sender];
        
        if ([[eachMessage allKeys] containsObject:@"timestamp"]) {        
            DOMElement *time = [mainDOMDocument createElement:@"div"];
            [time setAttribute:@"class" value:@"time"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:
                                   [[eachMessage objectForKey:@"timestamp"] intValue] + [feedItem clockSkew]];
            
            [dateFormatter setDateFormat:@"a"];
            NSString *ampm = [[dateFormatter stringFromDate:messageDate] lowercaseString];
            [dateFormatter setDateFormat:@"h:mm"];
            
            NSString *timeString = [[dateFormatter stringFromDate:messageDate] stringByAppendingString:ampm];
            [dateFormatter setDateFormat:@" dd MMM"];
            NSString *finalTimeString = [timeString stringByAppendingString:[dateFormatter stringFromDate:messageDate]];
            [dateFormatter release];
            
            DOMText *timeText = [mainDOMDocument createTextNode:finalTimeString];
            [time appendChild:timeText];
            [messageHeader appendChild:time];
        }
        
        [messageContainer appendChild:messageHeader];
        
        DOMElement *message = [mainDOMDocument createElement:@"div"];
        [message setAttribute:@"class" value:@"message-body"];
        
        NSArray *components = [[eachMessage objectForKey:@"message"] componentsSeparatedByString:@"\n"];
        
        for (NSString *line in components) {
            DOMText *messageText = [mainDOMDocument createTextNode:line];
            [message appendChild:messageText];
            
            DOMElement *lineBreak = [mainDOMDocument createElement:@"br"];
            [message appendChild:lineBreak];
        }
        
        [messageContainer appendChild:message];
        [(messageNumber > 1 ? hiddenMessages : messagesWrapper) appendChild:messageContainer];

        messageNumber++;
    }
    
    if ([hiddenMessages hasChildNodes]) {
        [messagesWrapper appendChild:hiddenMessages];
        DOMElement *messagesExpand = [mainDOMDocument createElement:@"div"];
        [messagesExpand setAttribute:@"class" value:@"messages-expand"];

        int numHiddenMessages = (skippedFirstMessage ? [[feedItem messages] count] - 3 : [[feedItem messages] count] - 2);
        NSString *messageWord = (numHiddenMessages > 1 ? @"messages" : @"message");
        DOMText *expandText = [mainDOMDocument createTextNode:[NSString stringWithFormat:@"Show %d more hidden %@", numHiddenMessages, messageWord]];
        [messagesExpand appendChild:expandText];
        [messagesWrapper appendChild:messagesExpand];
    }
    
    if ([messagesWrapper hasChildNodes])
        return messagesWrapper;
    else
        return nil;
}

/*
 Footer info
 Says which folder the item was shared in and gives an approximate time ago
 */
- (DOMElement *)footerInfo:(FeedItem *)feedItem
{
    DOMElement *shareInfo = [mainDOMDocument createElement:@"p"];
    [shareInfo setAttribute:@"class" value:@"info"];
    NSDate *localDate = [NSDate date];
    NSString *timeAgo = [NSString gh_stringForTimeInterval:[feedItem itemTimestamp] - 
                         [localDate timeIntervalSince1970] includeSeconds:NO];
    
    NSString *firstFolderName;
    NSString *infoStringFormat;
    
    if (IsEmpty([feedItem sharedFolders])) {
        firstFolderName = @"unknown";
        infoStringFormat = @"%@ ago";
    } else {
        firstFolderName = [[[feedItem sharedFolders] objectAtIndex:0] lastPathComponent];
        infoStringFormat = @"%@ ago in %@";
    }
    
    NSMutableString *folders = [NSMutableString stringWithString:firstFolderName];
    if ([[feedItem sharedFolders] count] > 1) [folders appendString:@" and others"];
    
    NSString *infoString = [NSString stringWithFormat:infoStringFormat, timeAgo, folders];
    DOMText *shareInfoText = [mainDOMDocument createTextNode:infoString];
    [shareInfo appendChild:shareInfoText];
    return shareInfo;
}

- (void)dealloc
{
    [mainDOMDocument release];
    [feedItems release];
    [mainBlock release];
	[super dealloc];
}

@end
