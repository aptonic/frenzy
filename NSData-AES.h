//
//  NSData-AES.h
//  Encryption
//
//  Created by Jeff LaMarche on 2/12/09.
//  Copyright 2009 Jeff LaMarche Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

// Supported keybit values are 128, 192, 256
#define KEYBITS		256
#define AESEncryptionErrorDescriptionKey	@"description"

@interface NSData(AES)
- (NSData *)AESEncryptWithPassphrase:(NSString *)pass;
- (NSData *)AESDecryptWithPassphrase:(NSString *)pass;
@end
