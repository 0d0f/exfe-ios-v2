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
#import "PlaceAnnotation.h"
#import "NewGatherViewController.h"
#import "EXPlaceEditView.h"
#import "WildcardGestureRecognizer.h"
#import "EXGradientToolbarView.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "EditCrossDelegate.h"

typedef NS_ENUM(NSUInteger, EFPlaceUIMode) {
	EFPlaceUIModeSearch,
	EFPlaceUIModeEdit,
	EFPlaceUIModeSearchVenuePopup
};

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
    UIButton *rightbutton;
    UIButton *clearbutton;
    UIButton *revert;
    UITableView* _tableView;
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
    
    double editinginterval;

    double lng;
    double lat;
}


//@property (nonatomic,retain) UIViewController* gatherview;
@property (nonatomic,retain) id delegate;
@property BOOL showdetailview;
@property BOOL showtableview;
@property BOOL isaddnew;

@property (nonatomic, retain) Place *selecetedPlace;
@property (nonatomic, retain) NSMutableDictionary *customPlace;
@property (nonatomic, retain) NSMutableArray *placeResults;
    
//- (void) PlaceEditClose:(id) sender;
//- (void) textDidChange:(NSNotification*)notification;
//- (void) editingDidBegan:(NSNotification*)notification;
//- (void) reloadPlaceData:(NSArray*)places;
//- (void) fillTopPlace:(NSDictionary*)topPlace;
//- (void) drawMapAnnontations:(int)idx;
//
//- (void) selectOnMap:(id) sender;
- (void) selectPlace:(int)index editing:(BOOL)editing;
//- (void) addPlaceEdit:(Place*)_place;
//- (void) getPlace;
//- (void) getPlacefromapi;
//- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector;
//- (void) done;
//- (void) maplongpress:(UILongPressGestureRecognizer *)gestureRecognizer;
//- (void) setPlace:(Place*)_place isedit:(BOOL)editstate;
//- (void) setViewStyle:(EXPlaceViewStyle)style;
//- (void) clearplace;
//- (void) initPlaceView;
//- (BOOL) isPlaceNull;
//- (void) addCustomAnnotation:(CLLocationCoordinate2D)location;
//- (void) saveResultsFromGooglePlaceAPI:(NSArray*)results;
@end
