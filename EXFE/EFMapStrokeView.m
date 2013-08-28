//
//  EFMapStrokeView.m
//  EXFE
//
//  Created by 0day on 13-7-22.
//
//

#import "EFMapStrokeView.h"

#define kDefaultStrokeColor     [UIColor redColor]
#define kDefaultStrokeWith      (1.0f)

@interface EFMapStrokeView ()
@property (nonatomic, strong) NSMutableArray *strokesToDraw;
@end

@interface EFMapStrokeView (Private)

- (void)_init;
- (void)_reloadFlag;
- (void)_reloadStrokesToDraw;

@end

@implementation EFMapStrokeView (Private)

- (void)_init {
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.strokesToDraw = [[NSMutableArray alloc] init];
}

- (void)_reloadFlag {
    NSAssert([self.dataSource respondsToSelector:@selector(numberOfStrokesForMapStrokeView:)], @"DataSource MUST implement this method.");
    _flag.numberOfStrokes = [self.dataSource numberOfStrokesForMapStrokeView:self];
}

- (void)_reloadStrokesToDraw {
    NSAssert([self.dataSource respondsToSelector:@selector(strokePointsForStrokeInMapStrokeView:atIndex:)], @"DataSource MUST implement this method.");
    
    [self.strokesToDraw removeAllObjects];
    
    MKMapRect mapRect = [self.mapView visibleMapRect];
    
    for (int i = 0; i < _flag.numberOfStrokes; i++) {
        NSArray *points = [self.dataSource strokePointsForStrokeInMapStrokeView:self atIndex:i];
        
        if (points && points.count) {
            id<EFMapStrokeViewPoint> lastPoint = [points lastObject];
            CLLocationCoordinate2D coordinate = lastPoint.coordinate;
            MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
            
            if (!MKMapRectContainsPoint(mapRect, mapPoint)) {
                [self.strokesToDraw addObject:@[]];
                continue;
            }
            
            NSMutableArray *corvertedPoints = [[NSMutableArray alloc] initWithCapacity:points.count];
            
            for (id<EFMapStrokeViewPoint> point in points) {
                CLLocationCoordinate2D coordinate = point.coordinate;
                CGPoint locationInView = [self.mapView convertCoordinate:coordinate toPointToView:self];
                NSValue *locationInViewValue = [NSValue valueWithCGPoint:locationInView];
                [corvertedPoints addObject:locationInViewValue];
            }
            
            [self.strokesToDraw addObject:corvertedPoints];
        } else {
            [self.strokesToDraw addObject:@[]];
        }
    }
}

@end

@implementation EFMapStrokeView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"MUST be on main thread.");
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, YES);
    
    for (int i = 0; i < _flag.numberOfStrokes; i++) {
        UIColor *strokeColor = nil;
        if ([self.dataSource respondsToSelector:@selector(colorForStrokeInMapStrokeView:atIndex:)]) {
            strokeColor = [self.dataSource colorForStrokeInMapStrokeView:self atIndex:i];
        }
        
        CGFloat width = kDefaultStrokeWith;
        if ([self.dataSource respondsToSelector:@selector(widthForStrokeInMapStrokeView:atIndex:)]) {
            width = [self.dataSource widthForStrokeInMapStrokeView:self atIndex:i];
        }
        
        CGContextSetLineWidth(context, width);
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextSetShadowWithColor(context, (CGSize){0.0f, 0.0f}, 1.0f, [UIColor whiteColor].CGColor);
        
        CGContextBeginPath(context);
        
        NSArray *locations = self.strokesToDraw[i];
        
        BOOL isFirstLocation = YES;
        for (NSValue *locationValue in locations) {
            CGPoint location = [locationValue CGPointValue];
            if (isFirstLocation) {
                CGContextMoveToPoint(context, location.x, location.y);
                isFirstLocation = NO;
            } else {
                CGContextAddLineToPoint(context, location.x, location.y);
            }
        }
        
        CGContextStrokePath(context);
    }
}

#pragma mark - Public

- (void)reloadData {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"MUST be on main thread.");
    
    CLLocationCoordinate2D cooridnate = self.mapView.centerCoordinate;
    CGPoint center = [self.mapView convertCoordinate:cooridnate toPointToView:self.superview];
    self.center = center;
    
    [self _reloadFlag];
    [self _reloadStrokesToDraw];
    
    [self setNeedsDisplay];
}

@end
