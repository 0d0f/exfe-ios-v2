//
//  CrossesViewController.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APICrosses.h"
#import "PullRefreshTableViewController.h"
#import "ImgCache.h"
#import "EXInnerButton.h"
#import "EXSpinView.h"
#import "MBProgressHUD.h"
#import "ProfileCard.h"
#import "CrossCard.h"
#import "NewGatherViewController.h"

#define CARD_VERTICAL_MARGIN      (15)

@interface CrossesViewController : PullRefreshTableViewController <UIAlertViewDelegate, CrossCardDelegate>
{
    IBOutlet UITableView* tableView;
    BOOL logoutflag;
    BOOL alertShowflag;
    int current_cellrow;
    NSMutableAttributedString *gatherax;
    MBProgressHUD *hud;
    UIImage *default_background;
    
    UILabel *label_profile;
    UILabel *label_gather;
    EXAttributedLabel *welcome_exfe;
    UILabel *welcome_more;
}

@property (nonatomic, retain) NSArray* crossList;
@property (nonatomic, retain) id crossChangeObserver;

- (void) refreshCell;
- (void) refreshCrosses:(NSString*)source;
- (void) refreshCrosses:(NSString*)source withCrossId:(int)cross_id;
- (void) loadObjectsFromDataStore;
- (void) emptyView;
- (void) ShowProfileView;
- (void) ShowGatherView;
- (Cross*) crossWithId:(int)cross_id;
- (void) refreshTableViewWithCrossId:(int)cross_id;
- (void) alertsignout;
- (BOOL) PushToCross:(int)cross_id;
- (BOOL) PushToConversation:(int)cross_id;
- (void) onClickConversation:(UIView*)card;
@end
