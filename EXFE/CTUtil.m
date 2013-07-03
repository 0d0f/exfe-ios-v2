//
//  CTUtil.m
//  EXFE
//
//  Created by huoju on 8/8/12.
//
//

#import "CTUtil.h"

@implementation CTUtil
+ (CGSize) CTSizeOfString:(NSMutableAttributedString*)attributedString minLineHeight:(float) minheight linespacing:(float)linespaceing constraint:(CGSize)constraint{

    CTParagraphStyleSetting setting[2] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight}
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(setting, 2);
    [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0,[attributedString length])];

    CFAttributedStringRef stringref=(__bridge CFAttributedStringRef)attributedString;
    CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString(stringref);
    CFRange range;
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), nil, constraint, &range);
    CFRelease(style);
    CFRelease(framesetter);
    return coreTextSize;
}

@end
