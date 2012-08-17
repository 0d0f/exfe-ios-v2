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
#import <MapKit/MapKit.h>
#import "WildcardGestureRecognizer.h"
#import "Util.h"
#import "EXOverlayView.h"
#import "ConversationViewController.h"
#import "EXQuoteView.h"

#define VIEW_MARGIN 6
#define INNER_MARGIN 9

@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate,EXImagesCollectionDataSource,UITableViewDataSource,UITableViewDelegate,EXImagesCollectionDelegate,UITextFieldDelegate,MKMapViewDelegate,UITextViewDelegate,UIScrollViewDelegate>{
    IBOutlet UIToolbar *toolbar;
    UITextView *crosstitle;
    UIImageView *title_input_img;
    UILabel *crosstitle_view;
    UILabel *exfeenum;
    EXIconToolBar *gathertoolbar;
    EXIconToolBar *rsvptoolbar;
    EXIconToolBar *myrsvptoolbar;
    EXButton *rsvpbutton;
    MKMapView *map;
    UIImageView *mapbox;
    UITextView *crossdescription;
    UIView *crossdescbackimg;
    UIView *backgroundview;
    UIScrollView *containview;
    EXOverlayView *containcardview;
    EXQuoteView *popover;
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
    Cross* cross;
    int selectedExfeeIndex;
    BOOL viewmode;
    ConversationViewController *conversationView;

}
@property (retain,nonatomic) Cross* cross;

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;
- (void) ShowPlaceView;
- (void) ShowTimeView;
- (void) ShowExfeeView;
- (void) ShowGatherToolBar;
- (void) ShowRsvpToolBar;
- (void) ShowMyRsvpToolBar;
- (void) ShowRsvpButton;
- (Invitation*) getMyInvitation;
- (void) addDefaultIdentity;
- (void) reArrangeViews;
- (NSString*) findProvider:(NSString*)external_id;
- (void) setPlace:(NSDictionary*)placedict;
- (void) setDateTime:(CrossTime*)crosstime;
- (void) ShowExfeeInput:(BOOL)show;
- (void) setExfeeNum;
- (void) pullcontainviewDown;
- (void) toconversation;
- (void) rsvpaccept;
- (void) rsvpunaccept;
- (void) rsvpinterested;
- (void) rsvpdeclined;
- (void) rsvpaddmate;
- (void) rsvpsubmate;
- (void) rsvpremove;
- (void) sendrsvp:(NSString*)status;
- (void) setViewMode;
- (void) addExfee:(Invitation*) invitation;
- (void) initData;
- (void) ShowExfeePopOver:(Invitation*) invitation pointTo:(CGPoint)point arrowx:(float)arrowx;
- (void) touchesBegan:(UITapGestureRecognizer*)sender;
@end
