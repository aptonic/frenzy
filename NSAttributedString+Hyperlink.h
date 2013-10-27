//
//  NSAttributedString+Hyperlink.h
//  Dropzone
//
//  Created by John Winter on 4/03/09.
//  Copyright 2009 Wintersoft Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (Hyperlink)

+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withUnderline:(BOOL)withUnderline;

@end

