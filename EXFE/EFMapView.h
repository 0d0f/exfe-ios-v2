//
//  EFMapView.h
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    kEFMapOperationStyleRightHand = 0,
    kEFMapOperationStyleLeftHand
} EFMapOperationStyle;

typedef enum {
    kEFMapViewEditingStateNormal = 0,
    kEFMapViewEditingStateReady,
    kEFMapViewEditingStateEditingPath,
    kEFMapViewEditingStateEditingAnnotation,
} EFMapViewEditingState;

@class EFMapView;
@protocol EFMapViewDelegate <MKMapViewDelegate>

@optional
- (void)mapViewDidScroll:(EFMapView *)mapView;

@end

@interface EFMapView : MKMapView

@property (nonatomic, assign)                       id<EFMapViewDelegate>   delegate;
@property (nonatomic, assign)                       EFMapOperationStyle     operationStyle;

@property (nonatomic, assign, getter = isEditing)   BOOL                    editing;
@property (nonatomic, assign)                       EFMapViewEditingState   editingState;       // ONLY avaliable when editing is YES

- (void)removeSelectedPath;

@end
