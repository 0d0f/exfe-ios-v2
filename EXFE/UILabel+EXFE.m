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
    } if (self.numberOfLines == 1){
        CGRect frame1 = self.frame;
        [self sizeToFit];
        CGRect frame2 = self.frame;
        frame2.size.width = frame1.size.width;
        self.frame = frame2;
    }else {
        CGRect frame = self.frame;
        CGSize size = [self sizeWrapContent:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)];
        
        CGSize ruler = CGSizeZero;
        NSMutableString *str = [NSMutableString stringWithString:@""];
        for (NSUInteger i = 0; i < self.numberOfLines; i++) {
            if (i != 0) {
                [str appendString:@"\n"];
            }
            if (i < self.numberOfLines - 1) {
                [str appendString:@"g"];
            } else {
                [str appendString:@"M"];
            }
            ruler = [str sizeWithFont:self.font constrainedToSize:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT) lineBreakMode:self.lineBreakMode];
            if (ruler.height > size.height) {
                frame.size.height = size.height;
                self.frame = frame;
                return;
            }
        }
        frame.size.height = ruler.height;
        self.frame = frame;
        return ;
    }
}


@end
