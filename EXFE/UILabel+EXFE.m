//
//  UILabel+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-4-1.
//
//

#import "UILabel+EXFE.h"

@implementation UILabel (EXFE)

- (CGSize)sizeWrapContent:(CGSize)target
{
    return  [self.text sizeWithFont:self.font constrainedToSize:target lineBreakMode:self.lineBreakMode];
}

- (void)wrapContent
{
    if (self.numberOfLines == 0) {
        CGRect frame = self.frame;
        CGSize size = [self sizeWrapContent:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)];
        frame.size.height = size.height;
        self.frame = frame;
    }
}


@end
