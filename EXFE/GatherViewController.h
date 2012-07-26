//
//  GatherViewController.h
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "CrossesViewController.h"
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "User.h"
#import "Invitation.h"
#import "EXImagesCollectionView.h"
#import "ImgCache.h"
#import "APIProfile.h"
#import "Invitation.h"
#import "ImgCache.h"
#import "PlaceViewController.h"
#import "TimeViewController.h"
#import "ExfeeInputViewController.h"
#import "Place.h"
#import "EXIconToolBar.h"
//#import "EXToolbarItem.h"
#import <MapKit/MapKit.h>
#import "WildcardGestureRecognizer.h"
#import "Util.h"
#import "EXOverlayView.h"

#define VIEW_MARGIN 6
#define INNER_MARGIN 9

@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate,EXImagesCollectionDataSource,UITableViewDataSource,UITableViewDelegate,EXImagesCollectionDelegate,UITextFieldDelegate,MKMapViewDelegate,UITextViewDelegate,UIScrollViewDelegate>{
    IBOutlet UIToolbar *toolbar;
    UITextView *crosstitle;
    UITextField *exfeeInput;
    UILabel *exfeenum;
    EXIconToolBar *rsvptoolbar;
    MKMapView *map;
    UITextView *crossdescription;
    UIView *backgroundview;
    UIScrollView *containview;
    EXOverlayView *containcardview;
    BOOL isExfeeInputShow;
    UITableView *suggestionTable;
    NSMutableArray *suggestIdentities;
    NSMutableArray *exfeeIdentities;
    NSMutableArray *exfeeSelected;
    Place *place;
    CrossTime *datetime;
    int boardoffset;
    EXImagesCollectionView *exfeeShowview;
    UILabel *timetitle;
    UILabel *timedesc;
    UILabel *placetitle;
    UILabel *placedesc;
    int selectedExfeeIndex;

}

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;
- (void) ShowPlaceView;
- (void) ShowTimeView;
- (void) ShowExfeeView;
- (void) ShowRSVPToolBar:(int)exfeeIndex;
- (void) textDidChange:(UITextField*)textField;
- (void) addDefaultIdentity;
- (void) reArrangeViews;
- (NSString*) findProvider:(NSString*)external_id;
- (void) getIdentity:(NSString*)identity_json;
- (void) setPlace:(NSDictionary*)placedict;
- (void) setDateTime:(CrossTime*)crosstime;
- (void) ShowExfeeInput:(BOOL)show;
- (void) setExfeeNum;
- (void) pullPannelDown;
- (void) pullcontainviewDown;
- (void) rsvpaccept;
- (void) rsvpaddmate;
- (void) rsvpsubmate;
- (void) rsvpreset;
- (void) addExfee:(Invitation*) invitation;

- (void)touchesBegan:(UITapGestureRecognizer*)sender;
@end
