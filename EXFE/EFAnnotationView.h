//
//  EFAnnotationView.h
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <MapKit/MapKit.h>

@class EFAnnotationView;
@protocol EFAnnotationViewDelegate <NSObject>

- (void)annotationView:(EFAnnotationView *)view didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@class EFAnnotation, EFMarauderMapDataSource;
@interface EFAnnotationView : MKAnnotationView

@property (nonatomic, weak) id<EFAnnotationViewDelegate> delegate;
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, weak) EFMarauderMapDataSource *mapDataSource;

- (void)reloadWithAnnotation:(EFAnnotation *)annotatoin;

@end
