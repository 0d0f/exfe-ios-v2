//
//  EFTimestampAnnotation.h
//  EXFE
//
//  Created by 0day on 13-8-12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface EFTimestampAnnotation : NSObject
<
MKAnnotation
>

@property (nonatomic, strong) NSDate    *timestamp;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
               timestamp:(NSDate *)timestamp;

@end
