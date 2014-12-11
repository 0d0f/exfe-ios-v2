//
//  EXBubbleButton.m
//  BubbleTextField
//
//  Created by huoju on 8/11/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import "EXBubbleButton.h"

@implementation EXBubbleButton
@synthesize customObject;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [FONT_COLOR_HL set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path fill];
    [path stroke];

    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.25] set]; //Black
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, rect.size.width-0.5, 0);
    CGContextAddLineToPoint(currentContext, rect.size.width-0.5, rect.size.height);
    CGContextSetLineWidth(currentContext, 1);
    CGContextStrokePath(currentContext);
    CGContextRestoreGState(currentContext);

    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.25] set];
    CGContextSaveGState(currentContext);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, 0.5, 0);
    CGContextAddLineToPoint(currentContext, 0.5, rect.size.height);
    CGContextSetLineWidth(currentContext, 1);
    CGContextStrokePath(currentContext);
    CGContextRestoreGState(currentContext);
}

@end
