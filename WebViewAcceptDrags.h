//
//  WebViewAcceptDrags.h
//  Frenzy
//
//  Created by John Winter on 4/05/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "DragHandler.h"

@interface WebViewAcceptDrags : WebView {
    DragHandler *dragHandler;
}

@end
