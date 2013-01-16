//
//  EXWidgetTabBar.m
//  EXFE
//
//  Created by Stony Wang on 13-1-16.
//
//

#import "EXWidgetTabBar.h"
#import "Util.h"

@implementation EXWidgetTabBar

@synthesize widgets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.6;
        
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
    CGFloat y = 6;
    CGFloat y_drop = 10;
    CGFloat w = 30;
    CGFloat h = 26;
    CGFloat maxX = CGRectGetMaxX(self.bounds) - 8;
    CGRect widgetRect = CGRectMake(maxX - w, y, w, h);
    return CGRectOffset(widgetRect, -60 * index, index == 0 ? y_drop : 0);
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
    
    [[UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)] setFill];
    UIRectFill(b);
    
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

@end
