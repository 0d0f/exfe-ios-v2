//
//  PlaceViewController.h
//  EXFE
//
//  Created by huoju on 6/26/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PlaceViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    IBOutlet MKMapView *map;
}
    
- (IBAction) Close:(id) sender;
@end
