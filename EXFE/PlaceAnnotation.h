//
//  PlaceAnnotation.h
//  EXFE
//
//  Created by huoju on 6/28/12.
//
//

#import <UIKit/UIKit.h>
#import <Mapkit/MKAnnotation.h>

@interface PlaceAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *place_title;
    NSString *place_description;
    int index;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c withTitle:(NSString*)title description:(NSString*)description;
@property int index;

@end
