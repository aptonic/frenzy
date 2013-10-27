//
//  NSAttributedString+Hyperlink.m
//  Dropzone
//
//  Created by John Winter on 4/03/09.
//  Copyright 2009 Wintersoft Limited. All rights reserved.
//

#import "NSAttributedString+Hyperlink.h"

@implementation NSAttributedString (Hyperlink)

+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withUnderline:(BOOL)withUnderline
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
	
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
	
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
	
    // next make the text appear with an underline
	
	if (withUnderline)
		[attrString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
	
	[attrString addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize: NSSmallControlSize]] range:range];
    [attrString endEditing];
	
    return [attrString autorelease];
}

@end
