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


//typedef NS_ENUM(NSInteger, EXPlaceViewStyle) {
//    EXPlaceViewStyleDefault,
//    EXPlaceViewStyleMap,
//    EXPlaceViewStyleTableview,
//    EXPlaceViewStyleEdit
//};
typedef enum {
    EXPlaceViewStyleDefault,
    EXPlaceViewStyleMap,
    EXPlaceViewStyleTableview,
    EXPlaceViewStyleEdit
} EXPlaceViewStyle;


@interface PlaceViewController : UIViewController <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>{
    CLLocationManager *locationManager;
    IBOutlet MKMapView *map;
    IBOutlet UITextField *inputplace;
    IBOutlet UIBarButtonItem *rightbutton;
    NSArray* _places;
    NSArray* _annotations;
    UITableView* _tableView;
    NSMutableDictionary* gatherplace;
    UIViewController *gatherview;
    EXPlaceEditView *placeedit;
    UIActionSheet *actionsheet;
    BOOL isedit;
    
    double editinginterval;

    double lng;
    double lat;
}


@property (nonatomic,retain) UIViewController* gatherview;
    
- (IBAction) Close:(id) sender;
- (void) PlaceEditClose:(id) sender;
- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (void) reloadPlaceData:(NSArray*)places;
- (void) drawMapAnnontations;
- (void) selectOnMap:(id) sender;
- (void) selectPlace:(int)index;
- (void) addPlaceEdit:(NSDictionary*)place;
- (void) getPlace;
- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector;
- (void) done;
- (void) maplongpress:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void) setPlace:(Place*)_place;
- (void) setViewStyle:(EXPlaceViewStyle)style;
//- (void) addNewPin;
@end
