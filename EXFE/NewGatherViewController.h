//
//  NewGatherViewController.h
//  EXFE
//
//  Created by huoju on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
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


@interface NewGatherViewController : UIViewController <EXImagesCollectionGatherDataSource, EXImagesCollectionGatherDelegate, MKMapViewDelegate, EXRSVPMenuDelegate,UIGestureRecognizerDelegate,EditCrossDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate>{
    
    UIScrollView *container;
    EXCurveView *headview;
    UIImageView *dectorView;
    EXLabel *descView;
    EXImagesCollectionGatherView *exfeeShowview;
    //UIView *exfeeShowview;
    UILabel *timeRelView;
    UILabel *timeAbsView;
    UILabel *timeZoneView;
    UILabel *placeTitleView;
    UILabel *placeDescView;
    MKMapView *mapView;
    UIView *mapShadow;
    
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
    UIPickerView *identitypicker;
    UIView *pickertoolbar;
    NSMutableArray *orderedIdentities;
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
- (BOOL) InvitationExist:(Invitation*)invitation;

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated;
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id < MKAnnotation >)annotation;

- (void) showMenu:(Invitation*)_invitation items:(NSArray*)itemslist;

#pragma mark EXRSVPMenuViewDelegate
- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPPendingMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPRemoveMenuView:(EXRSVPMenuView *) menu;

- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation;
- (void) setrsvp:(NSString*)status invitation:(Invitation*)_invitation;
- (void) addDefaultIdentity:(int)idx;
- (void) replaceDefaultIdentity:(int)idx;
- (IBAction) Gather:(id) sender;
- (void) reFormatTitle;
- (BOOL) isMe:(Identity*)my_identity;
- (Invitation*) getMyInvitation;

#pragma mark EditCrossDelegate
- (void) addExfee:(NSArray*) invitations;

- (void) setTitle:(NSString*)title Description:(NSString*)desc;
- (void) setTime:(CrossTime*)time;
- (void) setPlace:(Place*)place;

@end
