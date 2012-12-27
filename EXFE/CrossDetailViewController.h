//
//  CrossDetailViewController.h
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
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


@interface CrossDetailViewController : UIViewController <UITextViewDelegate, EXImagesCollectionDataSource, EXImagesCollectionDelegate,EXRSVPMenuDelegate>{
    UIScrollView *container;
    EXCurveImageView *dectorView;
    UITextView *descView;
    EXImagesCollectionView *exfeeShowview;
    //UIView *exfeeShowview;
    UILabel *timeRelView;
    UILabel *timeAbsView;
    UILabel *timeZoneView;
    UILabel *placeTitleView;
    UILabel *placeDescView;
    MKMapView *mapView;
    UIImageView *mapPin;
    
    UIButton *btnBack;
    UILabel *titleView;
    
    Cross* cross;
    User* default_user;
    
    BOOL layoutDirty;
    
    NSArray *exfeeInvitations;
    EXRSVPStatusView *rsvpstatusview;
    CGFloat exfeeSuggestHeight;
    EXRSVPMenuView *rsvpmenu;
}
@property (retain,nonatomic) Cross* cross;
@property (retain,readonly) NSMutableArray *exfeeIdentities;
@property (retain,nonatomic) User* default_user;


- (void)initUI;
- (void)relayoutUI;
- (void)refreshUI;

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView;
- (void) showMenu:(Invitation*)_invitation;

#pragma mark EXRSVPMenuViewDelegate
- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPPendinMenuView:(EXRSVPMenuView *) menu;

@end
