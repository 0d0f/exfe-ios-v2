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

@synthesize placeholder;
@synthesize placehlderColor;
@synthesize minimumHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        placehlderColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect{
    if (self.text != nil && self.text.length > 0) {
        [super drawTextInRect:rect];
    }else{
        if (placeholder != nil && placeholder.length > 0) {
            [placehlderColor set];
            [placeholder drawInRect:rect withFont:self.font];
        }
    }
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

// Must call after text/umberOfLine/font changed
- (CGSize)sizeThatFits:(CGSize)size{
    CGFloat ow = size.width;
    CGFloat oh = size.height;
    CGSize rect = CGSizeMake(ow, INFINITY);
    
    NSMutableString *temp = [[NSMutableString alloc] initWithCapacity:self.numberOfLines * 2];
    [temp appendString:@"M|"];
    for (NSInteger i = 1 ; i < self.numberOfLines; i++) {
        [temp appendString:@"\nM|"];
    }
    
    NSString* four_lines = temp; // 4 lines
    CGSize fit4 = [four_lines sizeWithFont:self.font constrainedToSize:rect lineBreakMode:self.lineBreakMode];
    four_lines = nil;
    [temp release];
    CGSize fitFull = [self.text sizeWithFont:self.font constrainedToSize:rect lineBreakMode:self.lineBreakMode];
    CGFloat bestHeight = fitFull.height;
    if (self.numberOfLines > 0){
        hasMore = fitFull.height > fit4.height;
        bestHeight = MIN(fit4.height, bestHeight);
        isExpended = NO;
    }else{
        isExpended = YES;
    }
    
    return CGSizeMake(ow, MIN(oh, MAX(bestHeight, self.minimumHeight)));
}

//- (void)sizeToFit{
//    
//    CGSize size = [self sizeThatFits:self.bounds.size];
//    self.bounds = CGRectMake(0, 0, size.width, size.height);
//}

@end
