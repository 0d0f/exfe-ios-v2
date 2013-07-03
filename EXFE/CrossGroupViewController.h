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
#import "EXTabLayer.h"
#import "EXTabWidget.h"
#import "EXRSVPStatusView.h"
#import "EFKit.h"

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
    
//    // Header
//    UILabel* titleView;
    // Content
    //    UIScrollView* xContainer;
    //    UIView* container;
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
//    // WidgetTab
//    EXTabLayer *tabLayer;
//    EXTabWidget* tabWidget;
//    // Navigation
//    UIButton* btnBack;
    
    
//    UIImageView *headerShadow;
    
    
    UISwipeGestureRecognizer *swipeRightRecognizer;
    UISwipeGestureRecognizer *swipeLeftRecognizer;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) Cross* cross;
@property (nonatomic, assign) NSInteger headerStyle;
@property (nonatomic, assign) NSUInteger widgetId;
@property (nonatomic, strong) NSArray *sortedInvitations;

// EFTabBarDataSource
@property (nonatomic, strong) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@property (nonatomic, weak) EFTabBarViewController *tabBarViewController;
@property (nonatomic, copy) UIImage *shadowImage;
@property (nonatomic, assign) CGRect initFrame;

- (void)showPopup:(NSInteger)ctrlId;

@end
