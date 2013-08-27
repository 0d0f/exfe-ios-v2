//
//  CrossGroupViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>
#import "EFViewController.h"
#import "EditCrossDelegate.h"
#import "EXImagesCollectionView.h"
#import "EXRSVPMenuView.h"
#import "EXRSVPStatusView.h"
#import "EFKit.h"
#import "EFCrossTabBarViewController.h"

@class Cross;
@class User;
@class EXLabel;
@class EXRSVPStatusView;

#define kHeaderStyleFull   0
#define kHeaderStyleHalf   1
#define kWidgetCross           1
#define kWidgetConversation    2
#define kWidgetExfee           3

@interface CrossGroupViewController : EFViewController
<
EXImagesCollectionDataSource,
EXImagesCollectionDelegate,
MKMapViewDelegate,
EXRSVPMenuDelegate,
EditCrossDelegate,
UIGestureRecognizerDelegate,
UIAlertViewDelegate,
UIScrollViewDelegate,
EXRSVPStatusViewDelegate,
EFTabBarDataSource
> {
    
    
    CGFloat exfeeSuggestHeight;
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

    UIScrollView* container;
    EXLabel* descView;
    EXImagesCollectionView *exfeeShowview;
    UILabel *timeRelView;
    UILabel *timeAbsView;
    UILabel *timeZoneView;
    UILabel *placeTitleView;
    UILabel *placeDescView;
    MKMapView *mapView;
    UIView *mapShadow;
    
    
    UISwipeGestureRecognizer *swipeRightRecognizer;
    UISwipeGestureRecognizer *swipeLeftRecognizer;
}

// EFTabBarDataSource
@property (nonatomic, strong) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@property (nonatomic, weak) EFCrossTabBarViewController *tabBarViewController;
@property (nonatomic, copy) UIImage *shadowImage;
@property (nonatomic, assign) CGRect initFrame;

- (void)showPopup:(NSInteger)ctrlId;
- (void)removeCrossAndExit;

@end
