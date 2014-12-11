//
//  EFCrumPath.m
//  MarauderMap
//
//  Created by 0day on 13-7-3.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFCrumPath.h"

@interface EFCrumPath ()
@property (readwrite) CLLocationCoordinate2D    centerPoint;
@property (readwrite) MKMapRect                 mapRect;
@property (readwrite) NSMutableArray            *innerPoints;
@end

@interface EFCrumPath (Private)
- (void)_pointsDidChange;
@end

@implementation EFCrumPath

- (id)initWithMapPoints:(NSArray *)points {
    self = [super init];
    if (self) {
        self.innerPoints = [[NSMutableArray alloc] initWithArray:points];
        self.linecolor = [UIColor blackColor]; 
        [self _pointsDidChange];
    }
    
    return self;
}

#pragma mark - MKOverlay

- (CLLocationCoordinate2D)coordinate {
    return self.centerPoint;
}

- (MKMapRect)boundingMapRect {
    return self.mapRect;
}

#pragma mark - Property Accessor

- (NSArray *)mapPoints {
    return self.innerPoints;
}

#pragma mark - Public

- (void)addMapPoint:(EFLocation *)point {
    NSParameterAssert(point);
    
    [self.innerPoints addObject:point];
    [self _pointsDidChange];
}

- (void)removeMapPoint:(EFLocation *)point {
    NSParameterAssert(point);
    
    [self.innerPoints removeObject:point];
    [self _pointsDidChange];
}

- (void)replaceMapPointAtIndex:(NSUInteger)index withMapPoint:(EFLocation *)anotherPoint {
    NSParameterAssert(anotherPoint);
    NSAssert(index != NSNotFound, @"index should not be NSNotFound");
    
    [self.innerPoints replaceObjectAtIndex:index withObject:anotherPoint];
}

- (void)replaceAllMapPointsWithMapPoints:(NSArray *)newMapPoints {
    NSParameterAssert(newMapPoints);
    
    [self.innerPoints removeAllObjects];
    [self.innerPoints addObjectsFromArray:newMapPoints];
}

#pragma mark - Private

- (void)_pointsDidChange {
    EFLocation *firstPoint = self.innerPoints[0];
    MKMapPoint firtMapPoint = [firstPoint mapPointValue];
    CGFloat minX = firtMapPoint.x,
            minY = firtMapPoint.y,
            maxX = firtMapPoint.x,
            maxY = firtMapPoint.y;
    
    for (EFLocation *mapPoint in self.innerPoints) {
        MKMapPoint point = [mapPoint mapPointValue];
        minX = MIN(minX, point.x);
        minY = MIN(minY, point.y);
        maxX = MAX(maxX, point.x);
        maxY = MAX(maxY, point.y);
    }
    
    self.mapRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    self.centerPoint = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(self.mapRect), MKMapRectGetMidY(self.mapRect)));
}

@end
