//
//  EXLabel.m
//  EXFE
//
//  Created by Stony Wang on 12-12-29.
//
//

#import "EXLabel.h"
#import "Util.h"

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
        if (isExpended) {
            CGContextMoveToPoint   (ctx, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - 5 ); 
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.bounds) - 5, CGRectGetMaxY(self.bounds) - 5); 
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.bounds) - 5, CGRectGetMaxY(self.bounds)); 
        }else{
            CGContextMoveToPoint   (ctx, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds) - 5 );  
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds)); 
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(self.bounds) - 5, CGRectGetMaxY(self.bounds));
        }
        CGContextClosePath(ctx);
        
        CGContextSetRGBFillColor(ctx, COLOR255(0x7F), COLOR255(0x7F), COLOR255(0x7F), 1);
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
    hasMore = fitFull.height > fit4.height;
    CGFloat bestHeight = fitFull.height;
    if (self.numberOfLines > 0){
        bestHeight = MIN(fit4.height, bestHeight);
        isExpended = NO;
    }else{
        isExpended = YES;
    }
    
    self.frame = CGRectMake(CGRectGetMinX(self.frame) , CGRectGetMinY(self.frame), ow, bestHeight);
}

@end
