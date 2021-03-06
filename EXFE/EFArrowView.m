//
//  EFArrowView.m
//  EFFE
//
//  Created by 0day on 13-4-8.
//
//

#import "EFArrowView.h"

#define kDefaultCornerRadius    (4.0f)
#define kDefaultStrokeColor     [UIColor whiteColor]
#define kDefaultStrokeWidth     (1.0f)

#define kArrowEdgeLength        (10.0f)
#define kArrowHalfEdgeLength    (7.0f)
#define kArrowHeight            (7.0f)

@implementation EFArrowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cornerRadius = kDefaultCornerRadius;
        self.pointPosition = (CGPoint){0, 0};
        self.strokeColor = kDefaultStrokeColor;
        self.strokeWidth = kDefaultStrokeWidth;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setPointPosition:(CGPoint)pointPosition andArrowDirection:(EFArrowDirection)arrowDirection {
    self.arrowDirection = arrowDirection;
    self.pointPosition = pointPosition;
}

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contEFt = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = _strokeColor;
    
    //// Gradient Declarations
    CGGradientRef gradient = NULL;
    if (_gradientColors && [_gradientColors count]) {
        CGFloat gradientLocations[] = {0, 1};
        gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)_gradientColors, gradientLocations);
    }
    
    //// Shadow Declarations
    UIColor* shadow = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    CGSize shadowOffset = CGSizeMake(0.0f, 0.0f);
    CGFloat shadowBlurRadius = 4;
    
    // View Bounds
    CGRect viewBounds = self.bounds;
    CGFloat width = CGRectGetWidth(viewBounds);
    CGFloat height = CGRectGetHeight(viewBounds);
    CGPoint arrowPoint1, arrowPoint2, arrowPoint3, curvePoint11, curvePoint12, curvePoint13, curvePoint21, curvePoint22, curvePoint23, curvePoint31, curvePoint32, curvePoint33, curvePoint41, curvePoint42, curvePoint43;
    
    switch (_arrowDirection) {
        case kEFArrowDirectionUp:
            arrowPoint1 = (CGPoint){_pointPosition.x - kArrowHalfEdgeLength, kArrowHeight};
            arrowPoint2 = (CGPoint){_pointPosition.x, 0.0f};
            arrowPoint3 = (CGPoint){_pointPosition.x + kArrowHalfEdgeLength, kArrowHeight};
            curvePoint11 = (CGPoint){width - (kArrowHeight + _cornerRadius), kArrowHeight};
            curvePoint12 = (CGPoint){width - (kArrowHeight), kArrowHeight};
            curvePoint13 = (CGPoint){width - (kArrowHeight), kArrowHeight + _cornerRadius};
            curvePoint21 = (CGPoint){width - (kArrowHeight), height - (kArrowHeight + _cornerRadius)};
            curvePoint22 = (CGPoint){width - (kArrowHeight), height - (kArrowHeight)};
            curvePoint23 = (CGPoint){width - (kArrowHeight + _cornerRadius), height - (kArrowHeight)};
            curvePoint31 = (CGPoint){(kArrowHeight + _cornerRadius), height - (kArrowHeight)};
            curvePoint32 = (CGPoint){(kArrowHeight), height - (kArrowHeight)};
            curvePoint33 = (CGPoint){(kArrowHeight), height - (kArrowHeight + _cornerRadius)};
            curvePoint41 = (CGPoint){(kArrowHeight), (kArrowHeight + _cornerRadius)};
            curvePoint42 = (CGPoint){(kArrowHeight), (kArrowHeight)};
            curvePoint43 = (CGPoint){(kArrowHeight + _cornerRadius), (kArrowHeight)};
            break;
        case kEFArrowDirectionDown:
            arrowPoint1 = (CGPoint){_pointPosition.x + kArrowHalfEdgeLength, height - kArrowHeight};
            arrowPoint2 = (CGPoint){_pointPosition.x, height};
            arrowPoint3 = (CGPoint){_pointPosition.x - kArrowHalfEdgeLength, height - kArrowHeight};
            curvePoint11 = (CGPoint){(kArrowHeight + _cornerRadius), height - kArrowHeight};
            curvePoint12 = (CGPoint){(kArrowHeight), height - kArrowHeight};
            curvePoint13 = (CGPoint){(kArrowHeight), height - (kArrowHeight + _cornerRadius)};
            curvePoint21 = (CGPoint){(kArrowHeight), (kArrowHeight + _cornerRadius)};
            curvePoint22 = (CGPoint){(kArrowHeight), (kArrowHeight)};
            curvePoint23 = (CGPoint){(kArrowHeight + _cornerRadius), (kArrowHeight)};
            curvePoint31 = (CGPoint){width - (kArrowHeight + _cornerRadius), (kArrowHeight)};
            curvePoint32 = (CGPoint){width - (kArrowHeight), (kArrowHeight)};
            curvePoint33 = (CGPoint){width - (kArrowHeight), (kArrowHeight + _cornerRadius)};
            curvePoint41 = (CGPoint){width - (kArrowHeight), height - (kArrowHeight + _cornerRadius)};
            curvePoint42 = (CGPoint){width - (kArrowHeight), height - (kArrowHeight)};
            curvePoint43 = (CGPoint){width - (kArrowHeight + _cornerRadius), height - (kArrowHeight)};
            break;
        case kEFArrowDirectionLeft:
            break;
        case kEFArrowDirectionRight:
            arrowPoint1 = (CGPoint){width - kArrowHeight, _pointPosition.y - kArrowHalfEdgeLength};
            arrowPoint2 = (CGPoint){width, _pointPosition.y};
            arrowPoint3 = (CGPoint){width - kArrowHeight, _pointPosition.y + kArrowHalfEdgeLength};
            curvePoint11 = (CGPoint){width - kArrowHeight, height - (kArrowHeight + _cornerRadius)};
            curvePoint12 = (CGPoint){width - kArrowHeight, height - kArrowHeight};
            curvePoint13 = (CGPoint){width - (kArrowHeight + _cornerRadius), height - kArrowHeight};
            curvePoint21 = (CGPoint){kArrowHeight + _cornerRadius, height - kArrowHeight};
            curvePoint22 = (CGPoint){kArrowHeight, height - kArrowHeight};
            curvePoint23 = (CGPoint){kArrowHeight, height - (kArrowHeight + _cornerRadius)};
            curvePoint31 = (CGPoint){kArrowHeight, kArrowHeight + _cornerRadius};
            curvePoint32 = (CGPoint){kArrowHeight, kArrowHeight};
            curvePoint33 = (CGPoint){kArrowHeight + _cornerRadius, kArrowHeight};
            curvePoint41 = (CGPoint){width - (kArrowHeight + _cornerRadius), kArrowHeight};
            curvePoint42 = (CGPoint){width - kArrowHeight, kArrowHeight};
            curvePoint43 = (CGPoint){width - kArrowHeight, kArrowHeight + _cornerRadius};
            break;
        default:
            break;
    }
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:arrowPoint1];
    [bezierPath addLineToPoint:arrowPoint2];
    [bezierPath addLineToPoint:arrowPoint3];
    [bezierPath addLineToPoint:curvePoint11];
    [bezierPath addCurveToPoint:curvePoint13 controlPoint1:curvePoint11 controlPoint2:curvePoint12];
    [bezierPath addLineToPoint:curvePoint21];
    [bezierPath addCurveToPoint:curvePoint23 controlPoint1:curvePoint21 controlPoint2:curvePoint22];
    [bezierPath addLineToPoint:curvePoint31];
    [bezierPath addCurveToPoint:curvePoint33 controlPoint1:curvePoint31 controlPoint2:curvePoint32];
    [bezierPath addLineToPoint:curvePoint41];
    [bezierPath addCurveToPoint:curvePoint43 controlPoint1:curvePoint41 controlPoint2:curvePoint42];
    [bezierPath closePath];
    
    CGContextSaveGState(contEFt);
    CGContextSetShadowWithColor(contEFt, shadowOffset, shadowBlurRadius, shadow.CGColor);
    if (gradient) {
        CGContextBeginTransparencyLayer(contEFt, NULL);
        [bezierPath addClip];
        CGContextDrawLinearGradient(contEFt, gradient, CGPointMake(width * 0.5f, 0.0f), CGPointMake(width * 0.5f, height), 0);
        CGContextEndTransparencyLayer(contEFt);
    }
    CGContextRestoreGState(contEFt);
    
//    CGContEFtSaveGState(contEFt);
//    CGContEFtSetShadowWithColor(contEFt, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [strokeColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
//    CGContEFtRestoreGState(contEFt);
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
