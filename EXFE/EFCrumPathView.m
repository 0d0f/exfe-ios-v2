//
//  EFCrumPathView.m
//  MarauderMap
//
//  Created by 0day on 13-7-4.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFCrumPathView.h"
#import "EFCrumPath.h"

@interface EFCrumPathView ()
@property (nonatomic, strong) NSRecursiveLock *lock;
@end

@interface EFCrumPathView (Private)
- (CGPathRef)_pathForPoints:(NSArray *)points
                   clipRect:(MKMapRect)mapRect
                  zoomScale:(MKZoomScale)zoomScale;
@end

@implementation EFCrumPathView

- (id)initWithOverlay:(id<MKOverlay>)overlay {
    self = [super initWithOverlay:overlay];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
    EFCrumPath *crumPath = (EFCrumPath *)self.overlay;
    NSArray *mapPoints = crumPath.mapPoints;
    
    CGFloat lineWidth = 8.0f / zoomScale;
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    
    CGPathRef path = [self _pathForPoints:mapPoints
                                 clipRect:clipRect
                                zoomScale:zoomScale];
    
    if (path != nil) {
        CGContextAddPath(context, path);
        CGContextSetStrokeColorWithColor(context, crumPath.linecolor.CGColor);
        
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        if (kEFMapLineStyleDashedLine == crumPath.lineStyle) {
            CGFloat dashes[] = {0.0f, lineWidth * 4};
            CGContextSetLineDash(context, 0, dashes, 2);
        } else if (kEFMapLineStyleLine == crumPath.lineStyle) {
        }
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
}

@end

@implementation EFCrumPathView (Private)

static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r)
{
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}

#define MIN_POINT_DELTA 5.0

- (CGPathRef)_pathForPoints:(NSArray *)mapPoints
                   clipRect:(MKMapRect)mapRect
                  zoomScale:(MKZoomScale)zoomScale {
    NSParameterAssert(mapPoints);
    
    NSUInteger pointCount = mapPoints.count;
    
    if (pointCount < 2 || !mapPoints)
        return NULL;
    
    [self.lock lock];
    
    MKMapPoint *points = (MKMapPoint *)malloc(sizeof(MKMapPoint) * pointCount);
    for (int i = 0; i < pointCount; i++) {
        EFLocation *mapPoint = mapPoints[i];
        MKMapPoint point = [mapPoint mapPointValue];
        points[i] = point;
    }
    
    CGMutablePathRef path = NULL;
    
    BOOL needsMove = YES;
    
#define POW2(a) ((a) * (a))
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    double minPointDelta = MIN_POINT_DELTA / zoomScale;
    double c2 = POW2(minPointDelta);
    
    MKMapPoint point, lastPoint = points[0];
    NSUInteger i;
    
    for (i = 1; i < pointCount - 1; i++) {
        point = points[i];
        double a2b2 = POW2(point.x - lastPoint.x) + POW2(point.y - lastPoint.y);
        
        if (a2b2 >= c2) {
            if (lineIntersectsRect(point, lastPoint, mapRect)) {
                if (!path)
                    path = CGPathCreateMutable();
                
                if (needsMove) {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
            } else {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            
            lastPoint = point;
        }
    }
    
#undef POW2
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    point = points[pointCount - 1];
    if (lineIntersectsRect(lastPoint, point, mapRect))
    {
        if (!path)
            path = CGPathCreateMutable();
        if (needsMove)
        {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    free(points);
    points = NULL;
    
    [self.lock unlock];
    
    return path;
}

@end