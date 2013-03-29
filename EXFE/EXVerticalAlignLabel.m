//
//  EXVerticalAlignLabel.m
//  EXFE
//
//  Created by 0day on 13-3-29.
//
//

#import "EXVerticalAlignLabel.h"

@implementation EXVerticalAlignLabel

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect result = bounds;
    
    if (self.verticalAlignment == kEXLabelVerticalAlignmentTop) {
        CGFloat width = CGRectGetWidth(bounds);
        CGSize size = (CGSize){width, INFINITY};
        size = [self.text sizeWithFont:self.font
                     constrainedToSize:size
                         lineBreakMode:self.lineBreakMode];
        result.size.height = size.height;
    } else {
        // do nothing now
    }
    
    return result;
}

@end
