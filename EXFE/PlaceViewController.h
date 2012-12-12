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

typedef enum {
    EXPlaceViewStyleDefault,
    EXPlaceViewStyleMap,
    EXPlaceViewStyleTableview,
    EXPlaceViewStyleBigTableview,
    EXPlaceViewStyleEdit
} EXPlaceViewStyle;


@interface PlaceViewController : UIViewController <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>{
    CLLocationManager *locationManager;
    UIView *toolbar;
    IBOutlet MKMapView *map;
    UITextField *inputplace;
//    IBOutlet UIBarButtonItem *rightbutton;
    UIButton *rightbutton;
    UIButton *clearbutton;
    UIButton *revert;
    NSArray* _places;
    NSArray* _annotations;
    UITableView* _tableView;
//    NSMutableDictionary* gatherplace;
    Place *place;
    UIViewController *gatherview;
    EXPlaceEditView *placeedit;
    UIActionSheet *actionsheet;
    UIImageView *inputbackgroundImage;
    UIView *backgroundview;
    BOOL isedit;
    BOOL isaddnew;
    BOOL isnotinputplace;
    BOOL showdetailview;
    BOOL showtableview;
    BOOL willUserScroll;
    NSMutableDictionary *originplace;
    
    double editinginterval;

    double lng;
    double lat;
}


@property (nonatomic,retain) UIViewController* gatherview;
@property BOOL showdetailview;
@property BOOL showtableview;
@property BOOL isaddnew;
    
- (IBAction) doRevert:(id) sender;
- (void) PlaceEditClose:(id) sender;
- (void) textDidChange:(NSNotification*)notification;
- (void) editingDidBegan:(NSNotification*)notification;
- (void) reloadPlaceData:(NSArray*)places;
- (void) drawMapAnnontations;
- (void) selectOnMap:(id) sender;
- (void) selectPlace:(int)index editing:(BOOL)editing;
- (void) addPlaceEdit:(Place*)_place;
- (void) getPlace;
- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector;
- (void) done;
- (void) maplongpress:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void) setPlace:(Place*)_place isedit:(BOOL)editstate;
- (void) setViewStyle:(EXPlaceViewStyle)style;
- (void) clearplace;
- (void) initPlaceView;
@end
