//
//  EXTabBar.m
//  EXFE
//
//  Created by Stony Wang on 13-1-24.
//
//

#import "EXTabBar.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "Util.h"

@implementation EXTabBar
@synthesize widgets;
@synthesize contents;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        gestureRecognizer.delegate = self;
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];
    }
    return self;
}

- (NSInteger)hitIndex:(CGPoint)location withPadding:(CGSize)padding
{
    for (NSUInteger  i = 0; i < self.widgets.count; i++) {
        CGRect rect = [self getRectByIndex:i];
        CGRect touch = CGRectMake(CGRectGetMinX(rect) - padding.width, CGRectGetMinY(rect) - padding.height, CGRectGetWidth(rect) + padding.width * 2, CGRectGetHeight(rect) + padding.height * 2);
        if (CGRectContainsPoint(touch, location)) {
            return i;
        }
    }
    return -1;
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded){
        CGPoint location = [recognizer locationInView:self];
        NSInteger index = [self hitIndex:location withPadding:CGSizeMake(15, 0)];
        if (index >= 0) {
            if (tar != nil && act != nil){
                [tar performSelector:act withObject:self withObject:[NSNumber numberWithInteger:index]];
            }
        }
    }
}

- (CGRect)getRectByIndex:(NSInteger)index
{
    CGFloat y = 0;
    CGFloat w = 30;
    CGFloat h = 30;
    CGFloat maxX = CGRectGetMaxX(self.bounds) - 8;
    CGRect widgetRect = CGRectMake(maxX - w, y, w, h);
    return CGRectOffset(widgetRect, -60 * index, 0);
}

- (void)drawRect:(CGRect)rect
{
    //CGRect b = self.bounds;
    
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
                        CGPoint orginal = CGPointMake(CGRectGetMidX(rect) - 3 - numSize.width / 2 , CGRectGetMidY(rect) - numSize.height / 2);
                        CGRect numRect = CGRectMake(orginal.x, orginal.y, numSize.width, numSize.height);
                        {
                            CGContextRef context = UIGraphicsGetCurrentContext();
                            CGContextSaveGState(context);
                            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                            CGContextTranslateCTM(context, 0, CGRectGetMidY(numRect));
                            CGContextScaleCTM(context, 1.0, -1.0);
                            CGContextTranslateCTM(context, 0, 0 - CGRectGetMidY(numRect));
                            
                            CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0f), 1.0f, [UIColor COLOR_WA(0x00, 0xAF)].CGColor);
                            
                            CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), 13.0, NULL);
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

@end
