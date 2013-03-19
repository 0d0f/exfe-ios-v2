//
//  WidgetExfeeViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//

#import <UIKit/UIKit.h>
#import "EXAttributedLabel.h"
#import "Invitation+EXFE.h"
#import "Identity+EXFE.h"
#import "Exfee.h"

typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface WidgetExfeeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    
    UIView *invContent;
    UILabel *invName;
    UIImageView *invHostFlag;
    UILabel *invHostText;
    UIImageView *invRsvpImage;
    EXAttributedLabel *invRsvpLabel;
    UILabel *invRsvpAltLabel;
    UIImageView *identityProvider;
    UIImageView *identityWaring;
    UILabel *identityName;
    UIButton *ActionMenu;
    
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
}

@property (nonatomic, retain) Exfee *exfee;

@end
