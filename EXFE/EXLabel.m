//
//  EXLabel.m
//  EXFE
//
//  Created by Stony Wang on 12-12-29.
//
//

#import "EXLabel.h"

@implementation EXLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    if (hasMore){
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - 10 );  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));  // mid right
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.bounds) - 10, CGRectGetMaxY(self.bounds));  // bottom left
        CGContextClosePath(ctx);
        
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
        CGContextFillPath(ctx);
    }
}

- (void)sizeToFit{
    CGFloat ow = self.frame.size.width;
    CGFloat oh = self.frame.size.height;
    CGSize rect = CGSizeMake(ow, INFINITY);
    
    NSString* four_lines = @"M\nM\nM\nM"; // 4 lines
    CGSize fit4 = [four_lines sizeWithFont:self.font constrainedToSize:rect lineBreakMode:self.lineBreakMode];
    CGSize fitFull = [self.text sizeWithFont:self.font constrainedToSize:rect lineBreakMode:self.lineBreakMode];
    CGFloat bestHeight = fitFull.height;
    if (self.numberOfLines > 0){
        if (fit4.height < bestHeight){
            bestHeight = fit4.height;
            hasMore = YES;
        }else{
            hasMore = NO;
        }
    }else{
        hasMore = NO;
    }
    
    self.frame = CGRectMake(CGRectGetMinX(self.frame) , CGRectGetMinY(self.frame), ow, bestHeight);
}

@end
