//
//  UIBorderView.m
//  EXFE
//
//  Created by huoju on 11/30/12.
//
//

#import "UIBorderView.h"

@implementation UIBorderView

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
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(contextRef, 0.25);
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1.0);
	CGContextStrokeRect(contextRef, rect);
}

@end
