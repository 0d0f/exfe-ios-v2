//
//  EFMapView.m
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFTouchDownGestureRecognizer.h"
#import "EFMapEditingReadyView.h"
#import "EFMapEditingPathView.h"
#import "EFMapEditingAnnotationView.h"
#import "EFMapOverlay.h"

#define kOffsetY            (44.0f)
#define kOffsetRightHand    (-20.0f)
#define kOffsetLeftHand     (20.0f)
#define kPenSize            (CGSize){12.0f, 12.0f}
#define kMinDistance        (16.0f)
#define kCircleSize         (CGSize){kMinDistance * 2.0f, kMinDistance * 2.0f}
#define kDefaultPathColor   [UIColor colorWithRed:0.0f green:(124.0f / 255.0f) blue:1.0f alpha:1.0f]

@interface EFMapView ()

// inner gesture view
@property (nonatomic, strong) UIView            *gestureView;

// new gesture added
@property (nonatomic, strong) EFTouchDownGestureRecognizer  *touchDownGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer        *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;

@property (nonatomic, weak)   UIView                        *editingBaseView;
@property (nonatomic, weak)   EFMapEditingReadyView         *editingReadyView;
@property (nonatomic, weak)   EFMapEditingPathView          *editingPathView;
@property (nonatomic, weak)   EFMapEditingAnnotationView    *editingAnnotatoinView;

@property (nonatomic, strong) EFCrumPath        *pathOverlay;

@property (nonatomic, strong) NSMutableArray    *lines;
@property (nonatomic, strong) NSMutableArray    *strokeColors;
@property (nonatomic, strong) NSMutableArray    *timestamps;
@property (nonatomic, strong) UIView            *penView;
@property (nonatomic, strong) UIView            *circleView;
@property (nonatomic, assign) CGFloat           maxDistance;
@property (nonatomic, assign) BOOL              isDrawingStarted;

@end

@interface EFMapView (Private)

- (void)_showAnimate;

- (void)_fitCurve;

- (void)_beginWithPoint:(CGPoint)point;
- (void)_moveWithPoint:(CGPoint)point;
- (void)_endWithPoint:(CGPoint)point;

@end

@implementation EFMapView (Private)

- (void)_showAnimate {
    [self.penView.layer removeAllAnimations];
    
    self.penView.layer.transform = CATransform3DMakeTranslation(0.0f, kOffsetY, 0.0f);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [self.penView.layer valueForKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.duration = 0.233f;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    [self.penView.layer addAnimation:animation forKey:nil];
    self.penView.layer.transform = CATransform3DIdentity;
    
    self.penView.layer.opacity = 0.0f;
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [self.penView.layer valueForKeyPath:@"opacity"];
    animation.toValue = [NSNumber numberWithDouble:1.0f];
    animation.duration = 0.233f;
    animation.fillMode = kCAFillModeForwards;
    [self.penView.layer addAnimation:animation forKey:nil];
    self.penView.layer.opacity = 1.0f;
    
    // Circle View
    [self insertSubview:self.circleView belowSubview:self.penView];
    
    [self.circleView.layer removeAllAnimations];
    
    self.circleView.layer.opacity = 1.0f;
    
    CATransform3D transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
    self.circleView.layer.transform = transform;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.beginTime = CACurrentMediaTime() + 0.233f;
    animation.fromValue = [NSValue valueWithCATransform3D:transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.duration = 0.233f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    [self.circleView.layer addAnimation:animation forKey:nil];
}

- (void)_fitCurve {
    NSMutableArray *points = [self.lines lastObject];
    NSUInteger count = points.count;
    if (count < 3)
        return;
    
    CGPoint point1 = [points[count - 3] CGPointValue];
    CGPoint point2 = [points[count - 2] CGPointValue];
    CGPoint point3 = [points[count - 1] CGPointValue];
    
    CGFloat x1 = fabs(point2.x - point1.x);
    CGFloat y1 = fabs(point2.y - point1.y);
    
    CGFloat tanA = y1 / x1;
    CGFloat A = atan(tanA);
    
    CGFloat x2 = fabs(point3.x - point2.x);
    CGFloat y2 = fabs(point3.y - point2.y);
    
    CGFloat tanB = y2 / x2;
    CGFloat B = atan(tanB);
    
    CGFloat x3 = fabs(point3.x - point1.x);
    CGFloat y3 = fabs(point3.y - point1.y);
    CGFloat z3 = sqrt(x3 * x3 + y3 * y3);
    
    NSDate *date2 = [self.timestamps objectAtIndex:count - 2];
    NSDate *date3 = [self.timestamps objectAtIndex:count - 1];
    
    NSTimeInterval duration = [date3 timeIntervalSinceDate:date2];
    if (duration >= 0.5f)
        return;
    
    if (fabs(A - B) < M_PI * 2.33f / z3) {
        [points removeObjectAtIndex:count - 2];
        [self.timestamps removeObjectAtIndex:count - 2];
    }
}

- (void)_beginWithPoint:(CGPoint)point {
    point.x += (self.operationStyle == kEFMapOperationStyleRightHand) ? kOffsetRightHand : kOffsetLeftHand;
    point.y -= kOffsetY;
    
    // Pen View
    self.penView.center = point;
    [self addSubview:self.penView];
    
    self.circleView.center = point;
    [self _showAnimate];
    
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:200];
    [points addObject:[NSValue valueWithCGPoint:point]];
    [self.lines addObject:points];
    [self.strokeColors addObject:kDefaultPathColor];
    [self.timestamps addObject:[NSDate date]];
    
    self.maxDistance = 0.0f;
    self.isDrawingStarted = NO;
    
    [self setNeedsDisplay];
}

- (void)_moveWithPoint:(CGPoint)point {
    point.x += (self.operationStyle == kEFMapOperationStyleRightHand) ? kOffsetRightHand : kOffsetLeftHand;
    point.y -= kOffsetY;
    
    self.penView.center = point;
    
    NSMutableArray *points = [self.lines lastObject];
    [points addObject:[NSValue valueWithCGPoint:point]];
    [self.timestamps addObject:[NSDate date]];
    
    CGPoint firstPoint = [points[0] CGPointValue];
    CGPoint lastPoint = [[points lastObject] CGPointValue];
    CGFloat distance = sqrt((firstPoint.x - lastPoint.x) * (firstPoint.x - lastPoint.x) + (firstPoint.y - lastPoint.y) * (firstPoint.y - lastPoint.y));
    
    if (self.isDrawingStarted) {
        [self _fitCurve];
        self.maxDistance = MAX(self.maxDistance, distance);
        [self setNeedsDisplay];
    } else {
        if (distance >= kMinDistance) {
            self.isDrawingStarted = YES;
            self.maxDistance = 0.0f;
            [points removeAllObjects];
            [points addObject:[NSValue valueWithCGPoint:point]];
            
            CATransform3D transform = CATransform3DMakeScale(2.0f, 2.0f, 2.0f);
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.fromValue = [self.circleView.layer valueForKeyPath:@"transform"];
            animation.toValue = [NSValue valueWithCATransform3D:transform];
            animation.duration = 0.233f;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            
            [self.circleView.layer addAnimation:animation forKey:nil];
            
            animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = [self.circleView.layer valueForKeyPath:@"opacity"];
            animation.toValue = [NSNumber numberWithDouble:0.0f];
            animation.duration = 0.233f;
            animation.fillMode = kCAFillModeForwards;
            [self.circleView.layer addAnimation:animation forKey:nil];
            self.circleView.layer.opacity = 0.0f;
        }
    }
}

- (void)_endWithPoint:(CGPoint)point {
    CATransform3D newTransform = CATransform3DMakeScale(2.0f, 2.0f, 2.0f);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [self.penView.layer valueForKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:newTransform];
    animation.duration = 0.233f;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.penView.layer addAnimation:animation forKey:nil];
    self.penView.layer.transform = newTransform;
    
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [self.penView.layer valueForKeyPath:@"opacity"];
    animation.toValue = [NSNumber numberWithDouble:0.0f];
    animation.duration = 0.233f;
    animation.fillMode = kCAFillModeForwards;
    [self.penView.layer addAnimation:animation forKey:nil];
    self.penView.layer.opacity = 0.0f;
    
    if (!self.isDrawingStarted) {
        [self.lines removeLastObject];
        [self.strokeColors removeLastObject];
        
        newTransform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
        animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [self.circleView.layer valueForKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:newTransform];
        animation.duration = 0.233f;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [self.circleView.layer addAnimation:animation forKey:nil];
        self.circleView.layer.transform = CATransform3DIdentity;
    }
    self.isDrawingStarted = NO;
    self.maxDistance = 0.0f;
    [self setNeedsDisplay];
}

@end

@implementation EFMapView

static UIView * ReverseSubviews(UIView *view) {
    if (!view.subviews.count)
        return nil;
    
    for (UIView *subview in view.subviews) {
        if ([subview.gestureRecognizers count]) {
            return subview;
        }
    }
    
    for (UIView *subview in view.subviews) {
        return ReverseSubviews(subview);
    }
    
    return nil;
}

- (void)_initEditingViews {
    CGRect viewBounds = self.bounds;
    CGRect baseViewFrame = (CGRect){{50.0f, CGRectGetHeight(viewBounds) - 37.0f}, {CGRectGetWidth(viewBounds) - 100.0f, 25.0f}};
    
    UIView *baseView = [[UIView alloc] initWithFrame:baseViewFrame];
    baseView.backgroundColor = [UIColor clearColor];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:baseView];
    self.editingBaseView = baseView;
    
    CGRect baseViewBounds = baseView.bounds;
    
    EFMapEditingReadyView *readyView = [[EFMapEditingReadyView alloc] initWithFrame:baseViewBounds];
    [baseView addSubview:readyView];
    self.editingReadyView = readyView;
    
    CGRect pathViewFrame = (CGRect){CGPointZero, {CGRectGetWidth(baseViewBounds), 37}};
    EFMapEditingPathView *pathView = [[EFMapEditingPathView alloc] initWithFrame:pathViewFrame];
    [baseView addSubview:pathView];
    self.editingPathView = pathView;
    
    EFMapEditingAnnotationView *annatationView = [[EFMapEditingAnnotationView alloc] initWithFrame:baseViewBounds];
    [baseView addSubview:annatationView];
    self.editingAnnotatoinView = annatationView;
    
    self.editingState = kEFMapViewEditingStateReady;
}

- (void)_init {
    self.gestureView = ReverseSubviews(self);
    NSAssert(self.gestureView, @"There should be a gesture view.");
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delaysTouchesBegan = NO;
    
    [self.gestureView addGestureRecognizer:self.tapGestureRecognizer];
    [self.gestureView addGestureRecognizer:self.panGestureRecognizer];
    
    // touch down gesture
//    self.touchDownGestureRecognizer = [[EFTouchDownGestureRecognizer alloc] init];
//    self.touchDownGestureRecognizer.minimumNumberOfTouches = 1;
//    self.touchDownGestureRecognizer.maximumNumberOfTouches = 1;
    
    [self _initEditingViews];
    
    self.editing = NO;
    
//    __weak typeof(self) weakSelf = self;
//    
//    self.touchDownGestureRecognizer.touchesBeganCallback = ^(NSSet *touches, UIEvent *event){
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:weakSelf.gestureView];
//        [weakSelf _beginWithPoint:point];
//    };
//    self.touchDownGestureRecognizer.touchesMovedCallback = ^(NSSet *touches, UIEvent *event){
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:weakSelf.gestureView];
//        [weakSelf _moveWithPoint:point];
//    };
//    self.touchDownGestureRecognizer.touchesEndedCallback = ^(NSSet *touches, UIEvent *event){
//        UITouch *touch = [touches anyObject];
//        CGPoint point = [touch locationInView:weakSelf.gestureView];
//        [weakSelf _endWithPoint:point];
//    };
//    self.touchDownGestureRecognizer.touchesCancelledCallback = ^(NSSet *touches, UIEvent *event){
//        NSLog(@"Cancel happend.");
//    };
    
//    for (UIGestureRecognizer *gesture in self.gestureView.gestureRecognizers) {
//        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
//            [gesture requireGestureRecognizerToFail:self.touchDownGestureRecognizer];
//        }
//    }
//    
//    self.touchDownGestureRecognizer.enabled = NO;
//    [self.gestureView addGestureRecognizer:self.touchDownGestureRecognizer];
    
    self.lines = [[NSMutableArray alloc] initWithCapacity:20];
    self.strokeColors = [[NSMutableArray alloc] initWithCapacity:20];
    self.timestamps = [[NSMutableArray alloc] initWithCapacity:20];
    
    UIView *penView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, kPenSize}];
    penView.layer.cornerRadius = kPenSize.width * 0.5f;
    penView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    penView.layer.shadowColor = [UIColor blackColor].CGColor;
    penView.layer.shadowOffset = (CGSize){0, 0};
    penView.layer.shadowRadius = 4.0f;
    penView.layer.shadowOpacity = 0.3f;
    penView.layer.masksToBounds = YES;
    CALayer *blueLayer = [CALayer layer];
    blueLayer.backgroundColor = [UIColor colorWithRed:0.0f green:(124.0f / 255.0f) blue:1.0f alpha:1.0f].CGColor;
    blueLayer.frame = (CGRect){{2, 2}, {8, 8}};
    blueLayer.cornerRadius = 4;
    [penView.layer addSublayer:blueLayer];
    self.penView = penView;
    
    UIView *circleView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, kCircleSize}];
    circleView.layer.cornerRadius = kCircleSize.width * 0.5f;
    circleView.layer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;
    circleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    circleView.layer.borderWidth = 0.5f;
    circleView.layer.masksToBounds = YES;
    self.circleView = circleView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewBounds = self.bounds;
    CGRect baseViewFrame = (CGRect){{50.0f, CGRectGetHeight(viewBounds) - 37.0f}, {CGRectGetWidth(viewBounds) - 100.0f, 25.0f}};
    self.editingBaseView.frame = baseViewFrame;
}

#pragma mark - Gesture Hanlder

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.gestureView];
    UIGestureRecognizerState state = tap.state;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            break;
            [self _beginWithPoint:point];
        default:
            break;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self.gestureView];
    UIGestureRecognizerState state = pan.state;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            [self _beginWithPoint:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self _moveWithPoint:point];
            self.editingState = kEFMapViewEditingStateEditingPath;
            break;
        case UIGestureRecognizerStateEnded:
            [self _endWithPoint:point];
        default:
            break;
    }
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.penView removeFromSuperview];
    [self.penView.layer removeAllAnimations];
    
    [self.circleView removeFromSuperview];
    [self.circleView.layer removeAllAnimations];
}

#pragma mark - Property Accessor

- (void)setEditingState:(EFMapViewEditingState)editingState {
    [self willChangeValueForKey:@"editingState"];
    _editingState = editingState;
    [self didChangeValueForKey:@"editingState"];
    
    switch (editingState) {
        case kEFMapViewEditingStateEditingPath:
            self.editingPathView.hidden = NO;
            self.editingReadyView.hidden = YES;
            self.editingAnnotatoinView.hidden = YES;
            break;
        case kEFMapViewEditingStateEditingAnnotation:
            self.editingAnnotatoinView.hidden = NO;
            self.editingPathView.hidden = YES;
            self.editingReadyView.hidden = YES;
            break;
        case kEFMapViewEditingStateReady:
        default:
            self.editingReadyView.hidden = NO;
            self.editingPathView.hidden = YES;
            self.editingAnnotatoinView.hidden = YES;
            break;
    }
}

- (void)setEditing:(BOOL)editing {
    [self willChangeValueForKey:@"editing"];
    _editing = editing;
    [self didChangeValueForKey:@"editing"];
    
    for (UIGestureRecognizer *gesture in self.gestureView.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]] && gesture != self.tapGestureRecognizer) {
            gesture.enabled = editing ? NO : YES;
        } else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] && gesture != self.panGestureRecognizer) {
            ((UIPanGestureRecognizer *)gesture).minimumNumberOfTouches = editing ? 2 : 1;
        }
    }
    
    self.touchDownGestureRecognizer.enabled = editing ? YES : NO;
    self.tapGestureRecognizer.enabled = editing ? YES : NO;
    self.panGestureRecognizer.enabled = editing ? YES : NO;
    
    self.editingBaseView.hidden = editing ? NO : YES;
    
    
//    if (editing) {
//        for (UIGestureRecognizer *gesture in self.gestureView.gestureRecognizers) {
//            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]] || [gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
//                [self.touchDownGestureRecognizer requireGestureRecognizerToFail:gesture];
//            }
//        }
//    }
}

@end