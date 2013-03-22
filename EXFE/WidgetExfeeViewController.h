//
//  WidgetExfeeViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//
#import "EXAttributedLabel.h"
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

@interface WidgetExfeeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, EXBasicMenuDelegate>{
    
    UIView *invContent;
    UILabel *invName;
    UIImageView *invHostFlag;
    UILabel *invHostText;
    UIImageView *invRsvpImage;
    EXAttributedLabel *invRsvpLabel;
    UILabel *invRsvpAltLabel;
    UIImageView *identityProvider;
    UIImageView *identityWaring;
    UIBorderLabel *identityName;
    UIButton *ActionMenu;
    UIButton *RemoveButton;
    
    EXBasicMenu *rsvpMenu;
    
    CALayer *layer1;
    CALayer *layer2;
    CALayer *layer3;
    
//    UITableView* invTable;
//    ExfeeRsvpCell *tableHeader;
//    ABTableViewCell *tableFooter;
    UICollectionView *exfeeContainer;
    
    
    Invitation* selected_invitation;
    CGPoint _lastContentOffset;
    NSUInteger layoutLevel;
    
    NSDictionary *rsvpDict;
    NSDictionary *myRsvpDict;
}

@property (nonatomic, retain) Exfee *exfee;
@property (nonatomic, retain) NSArray *sortedInvitations;

@end
