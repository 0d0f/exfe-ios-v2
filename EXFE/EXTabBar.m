//
//  EXTabBar.m
//  EXFE
//
//  Created by Stony Wang on 13-1-24.
//
//

#import "EXTabBar.h"

@implementation EXTabBar
@synthesize widgets;

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

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"tap");
        if (tar != nil && act != nil){
            [tar performSelector:act withObject:self];
        }
    }
}

- (CGRect)getRectByIndex:(NSInteger)index
{
    CGFloat y = 0;
    CGFloat w = 30;
    CGFloat h = 30;
    CGFloat maxX = CGRectGetMaxX(self.bounds) - 6;
    CGRect widgetRect = CGRectMake(maxX - w, y, w, h);
    return CGRectOffset(widgetRect, -60 * index, 0);
}

- (void)drawRect:(CGRect)rect
{
    CGRect b = self.bounds;
    
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
