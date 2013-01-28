//
//  EXWidgetTabBar.m
//  EXFE
//
//  Created by Stony Wang on 13-1-16.
//
//

#import "EXWidgetTabBar.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "Util.h"

@implementation EXWidgetTabBar
@synthesize CurveFrame;
@synthesize widgets;
@synthesize contents;

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
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        [[UIColor COLOR_SNOW] set];
        for (UIImage* img in widgets) {
            CGRect rect = [self getRectByIndex:count];
            [img drawInRect:rect];
            if (contents) {
                id obj = [self.contents objectAtIndex:count];
                if (obj) {
                    NSString* ct = (NSString *)obj;
                    if (ct.length > 0) {
                        
                        CGSize numSize = [ct sizeWithFont:font];
                        CGPoint orginal = CGPointMake(CGRectGetMidX(rect) - 3 - numSize.width / 2 , CGRectGetMidY(rect) - 5 - numSize.height / 2);
                        CGRect numRect = CGRectMake(orginal.x, orginal.y, numSize.width, numSize.height);
                        {
                            CGContextRef context = UIGraphicsGetCurrentContext();
                            CGContextSaveGState(context);
                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                            CGContextTranslateCTM(context, 0, CGRectGetMidY(numRect));
                            CGContextScaleCTM(context, 1.0, -1.0);
                            CGContextTranslateCTM(context, 0, 0 - CGRectGetMidY(numRect));
                            
                            CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor COLOR_WA(0x00, 0xAF)].CGColor);
                            
                            CTFontRef textfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), 13.0, NULL);
                            NSMutableAttributedString *textstring=[[NSMutableAttributedString alloc] initWithString:ct];
                            [textstring addAttribute:(NSString*)kCTFontAttributeName value:(id)textfontref range:NSMakeRange(0,[textstring length])];
                            [textstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_WA(0xFF, 0xFF)].CGColor range:NSMakeRange(0,[textstring length])];
                            
                            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)textstring);
                            CGMutablePathRef path = CGPathCreateMutable();
                            CGPathAddRect(path, NULL, numRect);
                            CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [textstring length]), path, NULL);
                            CFRelease(framesetter);
                            CFRelease(path);
                            CTFrameDraw(theFrame, context);
                            CFRelease(theFrame);
                            CGContextRestoreGState(context);
                        }
                        
                    }
                }
            }
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
    
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

@end
