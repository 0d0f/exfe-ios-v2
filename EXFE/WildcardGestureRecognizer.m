#import "WildcardGestureRecognizer.h"


@implementation WildcardGestureRecognizer
@synthesize touchesBeganCallback;
@synthesize touchesEndCallback;
@synthesize touchesMoveCallback;

-(id) init{
    if (self = [super init])
    {
        self.cancelsTouchesInView = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesBeganCallback)
        touchesBeganCallback(touches, event);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesEndCallback)
        touchesEndCallback(touches, event);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesMoveCallback)
        touchesMoveCallback(touches, event);
}

- (void)reset
{
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

@end
