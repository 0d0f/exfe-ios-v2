//
//  UIScreen+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-7-16.
//
//

#import "UIScreen+EXFE.h"



@implementation UIScreen (EXFE)

- (enum UIScreenRatio) ratio
{
    CGFloat ww = CGRectGetWidth(self.bounds);
    CGFloat hh = CGRectGetHeight(self.bounds);
    
    NSInteger w = ww + 0.5;
    NSInteger h = hh + 0.5;
    if (w > h) {
        NSUInteger a = w;
        w = h;
        h = a;
    }
    
    if (h * 3 == w * 4) {
        return UIScreenRatioWide;
    }
    
    if (h * 2 == w * 3) {
        return UIScreenRatioStandard;
    }
    
    if (ABS(h * 9 / 16 - w) <= 1 ) {
        return UIScreenRatioLong;
    }
    
    return UIScreenRatioUnspecific;
}

@end
