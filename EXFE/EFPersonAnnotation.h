//
//  EFPersonAnnotation.h
//  EXFE
//
//  Created by 0day on 13-7-19.
//
//

#import <MapKit/MapKit.h>

@interface EFPersonAnnotation : NSObject
<
MKAnnotation
>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) BOOL isOnline;

@end
