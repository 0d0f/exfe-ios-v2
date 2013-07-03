//
//  MapPin.h
//  EXFE
//
//  Created by Stony Wang on 12-12-27.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *__weak title;
    NSString *__weak subTitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (weak, nonatomic, readonly) NSString *title;
@property (weak, nonatomic, readonly) NSString *subTitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;
@end