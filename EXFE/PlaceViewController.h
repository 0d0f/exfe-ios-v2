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
#import "APIPlace.h"
#import "PlaceAnnotation.h"
#import "GatherViewController.h"
#import "EXPlaceEditView.h"

@interface PlaceViewController : UIViewController <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate>{
    CLLocationManager *locationManager;
    IBOutlet MKMapView *map;
    IBOutlet UITextField *inputplace;
    NSArray* _places;
    UITableView* _tableView;
    UIViewController *gatherview;
    EXPlaceEditView *placeedit;
}
@property (nonatomic,retain) UIViewController* gatherview;
    
- (IBAction) Close:(id) sender;
- (void) reloadPlaceData:(NSArray*)places;
- (void) addPinToMap;
- (void) selectOnMap:(id) sender;
- (void) selectPlace:(int)index;
- (void) addPlaceEdit:(NSDictionary*)place;

@end
