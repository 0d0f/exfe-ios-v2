//
//  NewGatherViewController.h
//  EXFE
//
//  Created by huoju on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "EXCurveView.h"
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "User.h"
#import "Invitation.h"
#import "CrossTime.h"
#import "Place.h"
#import "EXImagesCollectionGatherView.h"
#import "EXRSVPStatusView.h"
#import "EXRSVPMenuView.h"
#import "APICrosses.h"
#import "EXLabel.h"
#import "EXAlertView.h"
#import "ExfeeInputViewController.h"
#import "TitleDescEditViewController.h"
#import "PlaceViewController.h"
#import "TimeViewController.h"
#import "EditCrossDelegate.h"


@interface NewGatherViewController : UIViewController <EXImagesCollectionGatherDataSource, EXImagesCollectionGatherDelegate, MKMapViewDelegate, EXRSVPMenuDelegate,UIGestureRecognizerDelegate, EditCrossDelegate>{
    
    UIScrollView *container;
//    EXCurveImageView *dectorView;
    EXCurveView *headview;
    UIImageView *dectorView;
    UILabel *descView;
    EXImagesCollectionGatherView *exfeeShowview;
    //UIView *exfeeShowview;
    UILabel *timeRelView;
    UILabel *timeAbsView;
    UILabel *timeZoneView;
    UILabel *placeTitleView;
    UILabel *placeDescView;
    MKMapView *mapView;
    
    UIButton *btnBack;
    UILabel *titleView;
    
    Cross* cross;
    User* default_user;
    
    BOOL layoutDirty;
    BOOL title_be_edit;
    NSMutableArray *exfeeInvitations;
    EXRSVPStatusView *rsvpstatusview;
    CGFloat exfeeSuggestHeight;
    EXRSVPMenuView *rsvpmenu;
    UIImageView *pannellight;
}
@property (retain,nonatomic) Cross* cross;
@property (retain,readonly) NSMutableArray *exfeeIdentities;
@property (retain,nonatomic) User* default_user;
@property BOOL title_be_edit;

- (void) initUI;
- (void) initData;
- (void) relayoutUI;
- (void) refreshUI;
- (void) hideMenu;
- (void) hideStatusView;
- (void) reloadStatusview:(Invitation*)_invitation;
- (void) fillTime:(CrossTime*)time;
- (void) fillPlace:(Place*)place;
- (void) ShowPlaceView:(NSString*)status;

- (void) GlassBarlightAnimation;

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated;
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id < MKAnnotation >)annotation;

- (void) showMenu:(Invitation*)_invitation;

#pragma mark EXRSVPMenuViewDelegate
- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPPendinMenuView:(EXRSVPMenuView *) menu;

- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation;

- (void) addDefaultIdentity;
- (IBAction) Gather:(id) sender;

#pragma mark EditCrossDelegate
- (void) addExfee:(NSArray*) invitations;
- (Invitation*) getMyInvitation;
- (void) setTitle:(NSString*)title Description:(NSString*)desc;
- (void) setTime:(CrossTime*)time;
- (void) setPlace:(Place*)place;

@end
