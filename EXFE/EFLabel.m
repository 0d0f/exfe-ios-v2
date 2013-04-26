//
//  EFLabel.m
//  EXFE
//
//  Created by 0day on 13-4-26.
//
//

#import "EFLabel.h"

#define kDefaultEdgeInsets  (UIEdgeInsets){0, 4, 0, 0}

@implementation EFLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = kDefaultEdgeInsets;
    }
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self sizeToFit];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    rect.size.width += self.edgeInsets.left;
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    rect.origin.x += self.edgeInsets.left;
    [super drawTextInRect:rect];
}

@end
