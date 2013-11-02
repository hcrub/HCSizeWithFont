//
//  NSString+HCRUB.m
//  HCRUB
//
//  Created by Neil Burchfield on 11/2/13.
//  Copyright (c) 2013 HCRUB (Neil Burchfield). All rights reserved.
//

#import "NSString+HCRUB.h"
#import <CoreText/CoreText.h>

static CFArrayRef CreateCTLinesForString(NSString *string, CGSize constrainedToSize, UIFont *font, NSLineBreakMode lineBreakMode, CGSize *renderSize)
{
    CFMutableArrayRef lines = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
    CGSize drawSize = CGSizeZero;
    
    if (font) {
        CFMutableDictionaryRef attributes = CFDictionaryCreateMutable(NULL, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attributes, kCTFontAttributeName,(__bridge const void *)(font));
        CFDictionarySetValue(attributes, kCTForegroundColorFromContextAttributeName, kCFBooleanTrue);
        
        CFAttributedStringRef attributedString = CFAttributedStringCreate(NULL, (__bridge CFStringRef)string, attributes);
        
        CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(attributedString);
        
        const CFIndex stringLength = CFAttributedStringGetLength(attributedString);
        const CGFloat lineHeight = font.lineHeight;
        const CGFloat capHeight = font.capHeight;
        
        CFIndex start = 0;
        BOOL isLastLine = NO;
        
        while (start < stringLength && !isLastLine) {
            drawSize.height += lineHeight;
            isLastLine = (drawSize.height+capHeight >= constrainedToSize.height);
            
            CFIndex usedCharacters = 0;
            CTLineRef line = NULL;
            
            if (isLastLine && (lineBreakMode != NSLineBreakByWordWrapping && lineBreakMode != NSLineBreakByCharWrapping)) {
                if (lineBreakMode == NSLineBreakByClipping) {
                    usedCharacters = CTTypesetterSuggestClusterBreak(typesetter, start, constrainedToSize.width);
                    line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters));
                } else {
                    CTLineTruncationType truncType;
                    
                    if (lineBreakMode == NSLineBreakByTruncatingHead) {
                        truncType = kCTLineTruncationStart;
                    } else if (lineBreakMode == NSLineBreakByTruncatingTail) {
                        truncType = kCTLineTruncationEnd;
                    } else {
                        truncType = kCTLineTruncationMiddle;
                    }
                    
                    usedCharacters = stringLength - start;
                    CFAttributedStringRef ellipsisString = CFAttributedStringCreate(NULL, CFSTR("…"), attributes);
                    CTLineRef ellipsisLine = CTLineCreateWithAttributedString(ellipsisString);
                    CTLineRef tempLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters));
                    line = CTLineCreateTruncatedLine(tempLine, constrainedToSize.width, truncType, ellipsisLine);
                    CFRelease(tempLine);
                    CFRelease(ellipsisLine);
                    CFRelease(ellipsisString);
                }
            } else {
                if (lineBreakMode == NSLineBreakByCharWrapping) {
                    usedCharacters = CTTypesetterSuggestClusterBreak(typesetter, start, constrainedToSize.width);
                } else {
                    usedCharacters = CTTypesetterSuggestLineBreak(typesetter, start, constrainedToSize.width);
                }
                line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters));
            }
            
            if (line) {
                drawSize.width = MAX(drawSize.width, ceilf(CTLineGetTypographicBounds(line,NULL,NULL,NULL)));
                
                CFArrayAppendValue(lines, line);
                CFRelease(line);
            }
            
            start += usedCharacters;
        }
        
        CFRelease(typesetter);
        CFRelease(attributedString);
        CFRelease(attributes);
    }
    
    if (renderSize) {
        *renderSize = drawSize;
    }
    
    return lines;
}

@implementation NSString (HCRUB)

- (CGSize)HCSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize resultingSize = CGSizeZero;
    
    CFArrayRef lines = CreateCTLinesForString(self, size, font, lineBreakMode, &resultingSize);
    if (lines) CFRelease(lines);
    
    return resultingSize;
}

@end
