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

@interface CrossesViewController : PullRefreshTableViewController <RKRequestDelegate,RKObjectLoaderDelegate>
{
    IBOutlet UITableView* tableView;
    UIBarButtonItem *profileButtonItem;
    UIBarButtonItem *gatherButtonItem;
    NSArray* _crosses;
    BOOL logoutflag;
    int current_cellrow;
    NSArray *cellbackimglist;
    NSArray *cellbackimgblanklist;
    NSMutableArray *cellDateTime;
    CustomStatusBar *customStatusBar;
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
- (void) ShowWelcome;
@end
