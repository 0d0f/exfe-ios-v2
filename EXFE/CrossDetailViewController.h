//
//  CrossDetailViewController.h
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "EXCurveImageView.h"
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "User.h"
#import "Invitation.h"
#import "CrossTime.h"
#import "Place.h"
#import "EXImagesCollectionView.h"
#import "EXRSVPStatusView.h"
#import "EXRSVPMenuView.h"
#import "APICrosses.h"
#import "EXLabel.h"
#import "EXAlertView.h"
#import "EXCurveView.h"
#import "EXWidgetTabBar.h"
#import "EditCrossDelegate.h"
#import "EXTabBar.h"

@interface CrossDetailViewController : UIViewController <EXImagesCollectionDataSource, EXImagesCollectionDelegate, MKMapViewDelegate, EXRSVPMenuDelegate, EditCrossDelegate, UIGestureRecognizerDelegate,UIAlertViewDelegate, UIScrollViewDelegate, RKObjectLoaderDelegate>{

    UIScrollView *container;
    UIImageView *dectorView;
    EXCurveView *headerView;
    UILabel *descView;
    EXImagesCollectionView *exfeeShowview;
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
    EXWidgetTabBar *widgetTabBar;
    EXTabBar *tabBar;
    
    Cross* cross;
    User* default_user;
    
    NSMutableArray *exfeeInvitations;
    EXRSVPStatusView *rsvpstatusview;
    CGFloat exfeeSuggestHeight;
    EXRSVPMenuView *rsvpmenu;
    UIButton *timeEditMenu;
    UIButton *placeEditMenu;
    UIButton *titleAndDescEditMenu;
    
    BOOL layoutDirty;
    NSInteger popupCtrolId;
    CGRect savedFrame;
    BOOL savedScrollEnable;
    
}
@property (retain,nonatomic) Cross* cross;
@property (retain,readonly) NSMutableArray *exfeeIdentities;
@property (retain,nonatomic) User* default_user;


- (void)initUI;
- (void)relayoutUI;
- (void)refreshUI;
- (void)hideMenuWithAnimation:(BOOL)animated;
- (void)hideStatusView;
- (void)reloadStatusview:(Invitation*)_invitation;
- (BOOL) isMe:(Identity*)my_identity;

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated;
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id < MKAnnotation >)annotation;

- (void) showMenu:(Invitation*)_invitation items:(NSArray*)itemslist;

#pragma mark EXRSVPMenuViewDelegate
- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPPendingMenuView:(EXRSVPMenuView *) menu;

#pragma mark EditCrossDelegate
- (void) addExfee:(NSArray*) invitations;
- (Invitation*) getMyInvitation;
- (void) setTitle:(NSString*)title Description:(NSString*)desc;
- (void) setTime:(CrossTime*)time;
- (void) setPlace:(Place*)place;

- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation;

- (void) toConversationAnimated:(BOOL)isAnimated;
- (void)saveCrossUpdate;
@end
