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
#import "CustomStatusBar.h"
#import "WelcomeView.h"
#import "EXSpinView.h"
#import "MBProgressHUD.h"
#import "ProfileCard.h"
#import "CrossCard.h"

@interface CrossesViewController : PullRefreshTableViewController <RKRequestDelegate,RKObjectLoaderDelegate,UIAlertViewDelegate, CrossCardDelegate>
{
    IBOutlet UITableView* tableView;
    UIBarButtonItem *profileButtonItem;
    UIBarButtonItem *gatherButtonItem;
    NSArray* _crosses;
    BOOL logoutflag;
    BOOL alertShowflag;
    int current_cellrow;
    NSMutableArray *cellDateTime;
    CustomStatusBar *customStatusBar;
    NSMutableAttributedString *gatherax;
    MBProgressHUD *hud;
    EXInnerButton *settingButton;
    ProfileCard *headerView;
}
- (void) refreshCell;
- (void) refreshCrosses:(NSString*)source;
- (void) refreshCrosses:(NSString*)source withCrossId:(int)cross_id;
- (void) loadObjectsFromDataStore;
- (void) initUI;
- (void) emptyView;
- (void) ShowProfileView;
- (void) ShowGatherView;
- (Cross*) crossWithId:(int)cross_id;
- (void) refreshTableViewWithCrossId:(int)cross_id;
- (void) showWelcome;
- (void) closeWelcome;
- (void) alertsignout;
- (BOOL) isIdentityBelongsMe:(int)identity_id;
- (void) refreshPortrait;
- (BOOL) PushToCross:(int)cross_id;
- (BOOL) PushToConversation:(int)cross_id;
- (void) onClickConversation:(UIView*)card;
@end
