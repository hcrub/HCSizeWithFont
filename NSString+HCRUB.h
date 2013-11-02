//
//  NSString+HCRUB.h
//  HCRUB
//
//  Created by Neil Burchfield on 11/2/13.
//  Copyright (c) 2013 HCRUB (Neil Burchfield). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HCRUB)

- (CGSize)HCSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
