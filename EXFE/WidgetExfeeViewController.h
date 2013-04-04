//
//  WidgetExfeeViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//
#import "EXAttributedLabel.h"
#import "PSTCollectionView.h"
#import "EXBasicMenu.h"
#import "UIBorderLabel.h"

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface WidgetExfeeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, EXBasicMenuDelegate,UIActionSheetDelegate, UIAlertViewDelegate>{
    
    UIScrollView *invContent;
    UILabel *invName;
    UIImageView *invHostFlag;
    UILabel *invHostText;
    UIImageView *invRsvpImage;
    EXAttributedLabel *invRsvpLabel;
    UILabel *invRsvpAltLabel;
    UIImageView *identityProvider;
    UIImageView *identityWaring;
    UIBorderLabel *identityName;
    UILabel *bioTitle;
    UILabel *bioContent;
    UIButton *ActionMenu;
    UIButton *RemoveButton;
    
    PSTCollectionViewFlowLayout *flowLayout;
    
    EXBasicMenu *rsvpMenu;
    
    CALayer *layer1;
    CALayer *layer2;
    CALayer *layer3;
    CALayer *layer4;
    
//    UITableView* invTable;
//    ExfeeRsvpCell *tableHeader;
//    ABTableViewCell *tableFooter;
    PSTCollectionView *exfeeContainer;
    
    
    Invitation* selected_invitation;
    CGPoint _lastContentOffset;
    CGSize _floatingOffset;
    NSUInteger layoutLevel;
    
    NSDictionary *rsvpDict;
    NSDictionary *myRsvpDict;
}

@property (nonatomic, retain) Exfee *exfee;
@property (nonatomic, retain) NSArray *sortedInvitations;
@property (nonatomic, copy) id onExitBlock;

@end
