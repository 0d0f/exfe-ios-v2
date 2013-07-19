//
//  EFCrumPath.h
//  MarauderMap
//
//  Created by 0day on 13-7-3.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "EFLocation.h"
#import "EFMapOverlayDataDefines.h"

@interface EFCrumPath : NSObject
<
MKOverlay
>

@property (readonly) NSArray *mapPoints;
@property (nonatomic, strong) UIColor *linecolor;   // Default as Black.
@property (nonatomic) CGFloat   lineWidth;
@property (nonatomic) EFMapLineStyle    lineStyle;  // Default as kEFMapLineStyleLine

- (id)initWithMapPoints:(NSArray *)points;

- (void)addMapPoint:(EFLocation *)point;
- (void)removeMapPoint:(EFLocation *)point;
- (void)replaceMapPointAtIndex:(NSUInteger)index withMapPoint:(EFLocation *)anotherPoint;

@end
