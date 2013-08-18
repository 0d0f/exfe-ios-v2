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
#import "EFMapOverlay.h"

#define kOffsetY            (44.0f)
#define kOffsetRightHand    (-20.0f)
#define kOffsetLeftHand     (20.0f)
#define kPenSize            (CGSize){12.0f, 12.0f}
#define kMinDistance        (16.0f)
#define kCircleSize         (CGSize){kMinDistance * 2.0f, kMinDistance * 2.0f}
#define kDefaultPathColor   [UIColor colorWithRed:0.0f green:(124.0f / 255.0f) blue:1.0f alpha:1.0f]
#define kOfflineDuration    (30.0f)

@interface EFMapView ()

// inner gesture view
@property (nonatomic, strong) UIView            *gestureView;

// new gesture added
@property (nonatomic, strong) EFTouchDownGestureRecognizer  *touchDownGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer        *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer        *normalTapGestureRecognizer;

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

@property (nonatomic, strong) NSTimer           *updateLocationTimer;

@end

@interface EFMapView (Private)

- (void)_showAnimate;

- (void)_fitCurve;

- (void)_beginWithPoint:(CGPoint)point;
- (void)_moveWithPoint:(CGPoint)point;
- (void)_endWithPoint:(CGPoint)point;

- (void)_fireTimer;
- (void)_invalideTimer;

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

- (void)_fireTimer {
    [self _invalideTimer];
    self.updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval:kOfflineDuration
                                                                target:self
                                                              selector:@selector(runloop:)
                                                              userInfo:nil
                                                               repeats:NO];
}

- (void)_invalideTimer {
    if (self.updateLocationTimer) {
        if ([self.updateLocationTimer isValid]) {
            [self.updateLocationTimer invalidate];
        }
        
        self.updateLocationTimer = nil;
    }
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

- (void)_initOperationBaseView {
    CGRect viewBounds = self.bounds;
    CGRect operationBaseViewFrame = (CGRect){{0.0f, CGRectGetHeight(viewBounds) - 50.0f}, {CGRectGetWidth(viewBounds), 50.0f}};
    UIView *operationBaseView = [[UIView alloc] initWithFrame:operationBaseViewFrame];
    [self addSubview:operationBaseView];
    self.operationBaseView = operationBaseView;
}

- (void)_initEditingViews {
    CGRect viewBounds = self.bounds;
    CGRect operationBaseViewFrame = self.operationBaseView.frame;
    CGRect baseViewFrame = (CGRect){{50.0f, CGRectGetHeight(operationBaseViewFrame) - 37.0f}, {CGRectGetWidth(viewBounds) - 100.0f, 25.0f}};
    
    UIView *baseView = [[UIView alloc] initWithFrame:baseViewFrame];
    baseView.backgroundColor = [UIColor clearColor];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.operationBaseView addSubview:baseView];
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
    annatationView.delegate = self;
    [baseView addSubview:annatationView];
    self.editingAnnotatoinView = annatationView;
}

- (void)_initOperationButtons {
    CGRect viewBounds = self.operationBaseView.bounds;
    
    UIButton *editingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editingButton.layer.cornerRadius = 4.0f;
    editingButton.backgroundColor = [UIColor blueColor];
    editingButton.frame = (CGRect){{10.0f, 10.0f}, {30.0f, 30.0f}};
    [editingButton addTarget:self action:@selector(editingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
#warning test only
//    [self.operationBaseView addSubview:editingButton];
    self.editingButton = editingButton;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"map_remove_30.png"] forState:UIControlStateNormal];
    cancelButton.frame = (CGRect){{CGRectGetWidth(viewBounds) - 40.0f, 10.0f}, {30.0f, 30.0f}};
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.operationBaseView addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    UIButton *headingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headingButton.backgroundColor = [UIColor clearColor];
    [headingButton setBackgroundImage:[UIImage imageNamed:@"btn_pad.png"] forState:UIControlStateNormal];
    [headingButton setImage:[UIImage imageNamed:@"map_arrow_g5.png"] forState:UIControlStateNormal];
    headingButton.frame = (CGRect){{CGRectGetWidth(viewBounds) - 42.0f, 10.0f}, {32.0f, 32.0f}};
    [headingButton addTarget:self action:@selector(headingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.operationBaseView addSubview:headingButton];
    self.headingButton = headingButton;
}

- (void)_init {
    self.gestureView = ReverseSubviews(self);
    NSAssert(self.gestureView, @"There should be a gesture view.");
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.delegate = self;
    
    [self.gestureView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delaysTouchesBegan = NO;
    
    [self.gestureView addGestureRecognizer:self.panGestureRecognizer];
    
    [self _initOperationBaseView];
    [self _initEditingViews];
    [self _initOperationButtons];
    
    self.editingState = kEFMapViewEditingStateNormal;
    
    // touch gesture
    self.touchDownGestureRecognizer = [[EFTouchDownGestureRecognizer alloc] init];
    self.touchDownGestureRecognizer.minimumNumberOfTouches = 1;
    self.touchDownGestureRecognizer.maximumNumberOfTouches = 1;
    
    __weak typeof(self) weakSelf = self;
    
    self.touchDownGestureRecognizer.touchesMovedCallback = ^(NSSet *touches, UIEvent *event){
        if ([weakSelf.delegate respondsToSelector:@selector(mapViewDidScroll:)]) {
            [weakSelf.delegate mapViewDidScroll:weakSelf];
        }
    };
    
    [self.gestureView addGestureRecognizer:self.touchDownGestureRecognizer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    [self.gestureView addGestureRecognizer:tap];
    self.normalTapGestureRecognizer = tap;
    
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

- (void)dealloc {
    [self _invalideTimer];
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
    CGRect operationBaseViewFrame = (CGRect){{0.0f, CGRectGetHeight(viewBounds) - 50.0f}, {CGRectGetWidth(viewBounds), 50.0f}};
    self.operationBaseView.frame = operationBaseViewFrame;
}

#pragma mark - Timer Runloop

- (void)runloop:(NSTimer *)timer {
    [self _invalideTimer];
    [self.headingButton setImage:[UIImage imageNamed:@"map_arrow_g5.png"] forState:UIControlStateNormal];
}

#pragma mark - Public

- (void)userLocationDidChange {
    [self.headingButton setImage:[UIImage imageNamed:@"map_arrow_blue.png"] forState:UIControlStateNormal];
    [self _fireTimer];
}

#pragma mark - EFMapEditingAnnotationViewDelegate

- (void)mapEditingAnnotationView:(EFMapEditingAnnotationView *)view isChangingToTitle:(NSString *)title {
    if ([self.delegate respondsToSelector:@selector(mapView:isChangingSelectedAnnotationTitle:)]) {
        [self.delegate mapView:self isChangingSelectedAnnotationTitle:title];
    }
}

- (void)mapEditingAnnotationView:(EFMapEditingAnnotationView *)view didChangeToTitle:(NSString *)title {
    if ([self.delegate respondsToSelector:@selector(mapView:didChangeSelectedAnnotationTitle:)]) {
        [self.delegate mapView:self didChangeSelectedAnnotationTitle:title];
    }
}

- (void)mapEditingAnnotationView:(EFMapEditingAnnotationView *)view didChangeToStyle:(EFAnnotationStyle)annotationStyle {
    if ([self.delegate respondsToSelector:@selector(mapView:didChangeSelectedAnnotationStyle:)]) {
        [self.delegate mapView:self didChangeSelectedAnnotationStyle:annotationStyle];
    }
}

#pragma mark - Action Handler

- (void)editingButtonPressed:(id)sender {
    NSArray *annotations = [self selectedAnnotations];
    if (annotations.count) {
        [self deselectAnnotation:annotations[0] animated:YES];
    }
    
    if (kEFMapViewEditingStateEditingPath != self.editingState) {
        self.editingState = kEFMapViewEditingStateEditingPath;
    } else {
        self.editingState = kEFMapViewEditingStateNormal;
    }
}

- (void)cancelButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mapViewCancelButtonPressed:)]) {
        [self.delegate mapViewCancelButtonPressed:self];
    }
}

- (void)headingButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mapViewHeadingButtonPressed:)]) {
        [self.delegate mapViewHeadingButtonPressed:self];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (gestureRecognizer == self.tapGestureRecognizer) {
            CGPoint location = [touch locationInView:gestureRecognizer.view];
            NSArray *selectedAnnotations = [self selectedAnnotations];
            if (selectedAnnotations.count) {
                id<MKAnnotation> annotation = selectedAnnotations[0];
                UIView *annotationView = [self viewForAnnotation:annotation];
                location = [annotationView convertPoint:location fromView:gestureRecognizer.view];
                if (CGRectContainsPoint(annotationView.bounds, location)) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - Gesture Hanlder

- (void)handleTap:(UITapGestureRecognizer *)tap {
    UIGestureRecognizerState state = tap.state;
    
    if (tap == self.tapGestureRecognizer) {
        switch (state) {
            case UIGestureRecognizerStateEnded:
                [self deselectAnnotation:[self selectedAnnotations][0] animated:YES];
                break;
            default:
                break;
        }
    } else if (tap == self.normalTapGestureRecognizer) {
        switch (state) {
            case UIGestureRecognizerStateEnded:
                if (self.selectedAnnotations.count) {
                    [self deselectAnnotation:[self selectedAnnotations][0] animated:YES];
                } else if ([self.delegate respondsToSelector:@selector(mapView:tappedAtCoordinate:)]) {
                    CGPoint location = [tap locationInView:self.gestureView];
                    CLLocationCoordinate2D coordinate = [self convertPoint:location toCoordinateFromView:self.gestureView];
                    [self.delegate mapView:self tappedAtCoordinate:coordinate];
                }
                break;
                
            default:
                break;
        }
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
        case kEFMapViewEditingStateNormal:
            self.editing = NO;
            self.editingBaseView.hidden = YES;
            self.cancelButton.hidden = YES;
            self.headingButton.hidden = NO;
            self.tapGestureRecognizer.enabled = NO;
            break;
        case kEFMapViewEditingStateEditingPath:
            self.editingPathView.hidden = NO;
            self.editingReadyView.hidden = YES;
            self.editingAnnotatoinView.hidden = YES;
            self.editing = YES;
            self.editingBaseView.hidden = NO;
            self.cancelButton.hidden = NO;
            self.headingButton.hidden = YES;
            self.tapGestureRecognizer.enabled = NO;
            break;
        case kEFMapViewEditingStateEditingAnnotation:
            self.editingAnnotatoinView.hidden = NO;
            self.editingPathView.hidden = YES;
            self.editingReadyView.hidden = YES;
            self.editing = NO;
            self.editingBaseView.hidden = NO;
            self.cancelButton.hidden = NO;
            self.headingButton.hidden = YES;
            self.tapGestureRecognizer.enabled = YES;
            break;
        case kEFMapViewEditingStateReady:
        default:
            self.editingReadyView.hidden = NO;
            self.editingPathView.hidden = YES;
            self.editingAnnotatoinView.hidden = YES;
            self.editing = YES;
            self.editingBaseView.hidden = NO;
            self.cancelButton.hidden = NO;
            self.headingButton.hidden = YES;
            self.tapGestureRecognizer.enabled = NO;
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
        } else if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            gesture.enabled = editing ? NO : YES;
        }
    }
    
    self.panGestureRecognizer.enabled = editing ? YES : NO;
}

@end
