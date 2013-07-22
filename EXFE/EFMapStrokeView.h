//
//  EFMapStrokeView.h
//  EXFE
//
//  Created by 0day on 13-7-22.
//
//

#import <MapKit/MapKit.h>

@class EFMapStrokeView;
@protocol EFMapStrokeViewPoint <NSObject>
@property (nonatomic, readonly) CLLocationCoordinate2D  coordinate;

@end

@protocol EFMapStrokeViewDataSource <NSObject>

@required
- (NSUInteger)numberOfStrokesForMapStrokeView:(EFMapStrokeView *)strokeView;
- (NSArray *)strokePointsForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index;

@optional
- (UIColor *)colorForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index;     // there is a default color.
- (CGFloat)widthForStrokeInMapStrokeView:(EFMapStrokeView *)strokeView atIndex:(NSUInteger)index;       // Default as 0.5f

@end

@interface EFMapStrokeView : UIView {
    struct {
        unsigned int numberOfStrokes;
    } _flag;
}

@property (nonatomic, weak)   MKMapView                       *mapView;
@property (nonatomic, weak)   id<EFMapStrokeViewDataSource>   dataSource;
@property (nonatomic, assign) BOOL                            drawWhenPointOut;     // Default as NO. When the point moves out of screen, stroke will not be drawn.

- (void)reloadData;

@end
