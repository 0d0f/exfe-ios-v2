//
//  CrossGroupViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "EditCrossDelegate.h"
#import "EXImagesCollectionView.h"
#import "EXRSVPMenuView.h"
#import "EXTabLayer.h"
#import "EXTabWidget.h"

@class Cross;
@class User;
@class EXLabel;
@class EXRSVPStatusView;

#define kHeaderStyleFull   0
#define kHeaderStyleHalf   1

#define kWidgetCross           0
#define kWidgetConversation    1
#define kWidgetExfee           2

@interface CrossGroupViewController : UIViewController<EXImagesCollectionDataSource, EXImagesCollectionDelegate, MKMapViewDelegate, EXRSVPMenuDelegate, EditCrossDelegate, EXTabWidgetDelegate, UIGestureRecognizerDelegate,UIAlertViewDelegate, UIScrollViewDelegate, RKObjectLoaderDelegate>{
    
    CGFloat exfeeSuggestHeight;
    NSMutableArray *exfeeInvitations;
    CGFloat head_bg_img_startY;
    CGPoint head_bg_point;
    
    BOOL layoutDirty;
    NSInteger popupCtrolId;
    CGRect savedFrame;
    BOOL savedScrollEnable;
    
    EXRSVPStatusView *rsvpstatusview;
    EXRSVPMenuView *rsvpmenu;
    UIButton *timeEditMenu;
    UIButton *placeEditMenu;
    UIButton *titleAndDescEditMenu;
    
    // Header
    UIView* headerView;
    UIImageView* dectorView;
    UILabel* titleView;
    // Content
    UIScrollView* xContainer;
    UIView* container;
    EXLabel* descView;
    EXImagesCollectionView *exfeeShowview;
    UILabel *timeRelView;
    UILabel *timeAbsView;
    UILabel *timeZoneView;
    UILabel *placeTitleView;
    UILabel *placeDescView;
    MKMapView *mapView;
    UIView *mapShadow;
    // WidgetTab
    EXTabLayer *tabLayer;
    EXTabWidget* tabWidget;
    // Navigation
    UIButton* btnBack;
    
    
    UIImageView *headerShadow;
}

@property (nonatomic,retain) UIViewController *currentViewController;
@property (retain,nonatomic) Cross* cross;
@property (retain,nonatomic) User* default_user;
@property (nonatomic) NSInteger headerStyle;
@property (nonatomic) NSUInteger widgetId;

-(void)swapViewControllers:(UIViewController*)childViewController;

#pragma mark Navigation
- (void) toConversationAnimated:(BOOL)isAnimated;


@end
