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
#import "NewGatherViewController.h"
#import "EXPlaceEditView.h"
#import "WildcardGestureRecognizer.h"
#import "EXGradientToolbarView.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "EditCrossDelegate.h"

typedef enum {
    EXPlaceViewStyleDefault,
    EXPlaceViewStyleMap,
    EXPlaceViewStyleTableview,
    EXPlaceViewStyleBigTableview,
    EXPlaceViewStyleEdit,
    EXPlaceViewStyleShowPlaceDetail
} EXPlaceViewStyle;


@interface PlaceViewController : UIViewController <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>{
    CLLocationManager *locationManager;
    EXGradientToolbarView *toolbar;
    IBOutlet MKMapView *map;
    UIView *mapShadow;
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
    //UIViewController *gatherview;
    id delegate;
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


//@property (nonatomic,retain) UIViewController* gatherview;
@property (nonatomic,retain) id delegate;
@property BOOL showdetailview;
@property BOOL showtableview;
@property BOOL isaddnew;
    
- (void) PlaceEditClose:(id) sender;
- (void) textDidChange:(NSNotification*)notification;
- (void) editingDidBegan:(NSNotification*)notification;
- (void) reloadPlaceData:(NSArray*)places;
- (void) drawMapAnnontations:(int)idx;

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
- (BOOL) isPlaceNull;
@end
