/*
 *  IsEmpty.h
 *  Frenzy
 *
 *  Created by John Winter on 10/12/09.
 *  Copyright 2009 Aptonic Software. All rights reserved.
 *
 */

static inline BOOL IsEmpty(id thing) {
	return thing == nil
	|| ([thing respondsToSelector:@selector(length)]
		&& [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]
		&& [(NSArray *)thing count] == 0);
}