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
    [attributedString addAttribute:(id)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0,[attributedString length])];
    CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CFRange range;
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), nil, constraint, &range);

    CFRelease(framesetter);
    return coreTextSize;
}

@end
