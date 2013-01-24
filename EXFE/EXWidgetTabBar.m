//
//  EXWidgetTabBar.m
//  EXFE
//
//  Created by Stony Wang on 13-1-16.
//
//

#import "EXWidgetTabBar.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation EXWidgetTabBar
@synthesize CurveFrame;
@synthesize widgets;

- (void)setCurveFrame:(CGRect)frame{
    CurveFrame = frame;
    [self changeLayer];
}

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        CurveFrame = curveFrame;
        [self changeLayer];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        gestureRecognizer.delegate = self;
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
    }
    return self;
}

- (NSInteger)hitIndex:(CGPoint)location
{    
    for (NSUInteger  i = 0; i < self.widgets.count; i++) {
        CGRect rect = [self getRectByIndex:i];
        if (CGRectContainsPoint(rect, location)) {
            return i;
        }
    }
    return -1;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    if ([self hitIndex:location] >= 0) {
        return YES;
    }
    return NO;
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded){
        CGPoint location = [recognizer locationInView:self];
        NSInteger index = [self hitIndex:location];
        if (index >= 0) {
            NSLog(@"tap");
            if (tar != nil && act != nil){
                [tar performSelector:act withObject:self withObject:[NSNumber numberWithInteger:index]];
            }
        }
    }
}

- (CGRect)getRectByIndex:(NSInteger)index
{
    CGFloat y = 44;
    CGFloat y_drop = 15;
    CGFloat w = 30;
    CGFloat h = 38;
    CGFloat maxX = CGRectGetMaxX(self.bounds) - 8;
    CGRect widgetRect = CGRectMake(maxX - w, y, w, h);
    return CGRectOffset(widgetRect, -60 * index, index == 0 ? y_drop : 0);
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
    
    UIImage* img = [UIImage imageNamed:@"dock.png"];
    [img drawInRect:b];
    
    NSInteger count = 0;
    if (widgets) {
        for (UIImage* img in widgets) {
            CGRect rect = [self getRectByIndex:count];
            [img drawInRect:rect];
            count ++;
        }
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    tar = target;
    act = action;
}

- (void)clearDelegate
{
    tar = nil;
    act = nil;
}

- (void)changeLayer{
    
    CGRect bounds = self.bounds;
    
    CGFloat x0 = (CurveFrame.origin.x + CurveFrame.size.width * 0.0f);
    CGFloat y0 = (CurveFrame.origin.y + CurveFrame.size.height * 0.0f);
    CGFloat x1 = (CurveFrame.origin.x + 32);
    CGFloat y1 = (CurveFrame.origin.y + CurveFrame.size.height * 0.0f);
    CGFloat x2 = (CurveFrame.origin.x + 78 - 32);
    CGFloat y2 = (CurveFrame.origin.y + CurveFrame.size.height * 1.0f);
    CGFloat x3 = (CurveFrame.origin.x + CurveFrame.size.width * 1.0f);
    CGFloat y3 = (CurveFrame.origin.y + CurveFrame.size.height * 1.0f);
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    UIBezierPath *curvePath = [UIBezierPath bezierPath];
    [curvePath moveToPoint:CGPointMake(0, 0)];
    [curvePath addLineToPoint:CGPointMake(0, y0)];
    [curvePath addLineToPoint:CGPointMake(x0, y0)];
    [curvePath addCurveToPoint:CGPointMake(x3, y3) controlPoint1:CGPointMake(x1, y1) controlPoint2:CGPointMake(x2, y2)];
    [curvePath addLineToPoint:CGPointMake(bounds.size.width, y3)];
    [curvePath addLineToPoint:CGPointMake(bounds.size.width, 0)];
    [curvePath closePath];
    maskLayer.path = [curvePath CGPath];
    
    //    CGMutablePathRef path = CGPathCreateMutable();
    //    CGPathMoveToPoint(path, NULL, 0, 0);
    //    CGPathAddLineToPoint(path, NULL, 0, y0);
    //    CGPathAddLineToPoint(path, NULL, x0, y0);
    //    CGPathAddCurveToPoint(path, NULL, x1, y1, x2, y2, x3, y3);
    //    CGPathAddLineToPoint(path, NULL, bounds.size.width, y3);
    //    CGPathAddLineToPoint(path, NULL, bounds.size.width, 0);
    //    CGPathCloseSubpath(path);
    //    maskLayer.path = path ;
    
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

@end
