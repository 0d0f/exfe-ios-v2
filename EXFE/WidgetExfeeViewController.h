//
//  WidgetExfeeViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//
#import "EFViewController.h"
#import "PSTCollectionView.h"
#import "EXBasicMenu.h"
#import "UIBorderLabel.h"
#import "EFKit.h"
#import "TTTAttributedLabel.h"

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface WidgetExfeeViewController : EFViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
PSTCollectionViewDataSource,
PSTCollectionViewDelegate,
PSTCollectionViewDelegateFlowLayout,
EXBasicMenuDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
EFTabBarDataSource
> {
    
    UIScrollView *invContent;
    UILabel *invName;
    UIImageView *invHostFlag;
    UILabel *invHostText;
    UIImageView *invRsvpImage;
    TTTAttributedLabel *invRsvpLabel;
    UILabel *invRsvpAltLabel;
    UIButton *RemoveButton;
    
    PSTCollectionViewFlowLayout *flowLayout;
    
    EXBasicMenu *rsvpMenu;
    
//    CALayer *layer1;
//    CALayer *layer2;
//    CALayer *layer3;
//    CALayer *layer4;
    
    UITableView* invTable;
    UITableViewCell *tableHeader;
    UITableViewCell *tableRsvp;
    UITableViewCell *tableFooter;
    PSTCollectionView *exfeeContainer;
    
    CGPoint _lastContentOffset;
    CGSize _floatingOffset;
    NSUInteger layoutLevel;
    
    NSDictionary *rsvpDict;
    NSDictionary *myRsvpDict;
}

@property (nonatomic, strong) Exfee *exfee;
@property (nonatomic, strong) Invitation* selected_invitation;
@property (nonatomic, strong) NSArray *sortedInvitations;
@property (nonatomic, copy) id onExitBlock;

// EFTabBarDataSource
@property (nonatomic, strong) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@property (nonatomic, weak) EFTabBarViewController *tabBarViewController;
@property (nonatomic, copy) UIImage *shadowImage;
@property (nonatomic, assign) CGRect initFrame;

@end
