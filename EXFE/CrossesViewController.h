//
//  CrossesViewController.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "EXInnerButton.h"
#import "EXSpinView.h"
#import "MBProgressHUD.h"
#import "CrossCard.h"
#import "NewGatherViewController.h"
#import "TTTAttributedLabel.h"

#define CARD_VERTICAL_MARGIN      (15)

@interface CrossesViewController : PullRefreshTableViewController
<
UIAlertViewDelegate,
CrossCardDelegate,
UIScrollViewDelegate,
TTTAttributedLabelDelegate
> {
    BOOL alertShowflag;
    NSMutableAttributedString *gatherax;
    MBProgressHUD *hud;
    UIImage *default_background;
}

@property (nonatomic, strong) NSArray* crossList;
@property (nonatomic, strong) id crossChangeObserver;
@property (nonatomic, assign) BOOL needHeaderAnimation;

- (void)refreshCrosses:(NSString*)source;
- (void)refreshCrosses:(NSString*)source withCrossId:(int)cross_id;
- (void)loadObjectsFromDataStore;
- (void)emptyView;
- (void)ShowProfileView;
- (void)ShowGatherView;
- (Cross*)crossWithId:(int)cross_id;
- (void)refreshTableViewWithCrossId:(int)cross_id;
- (BOOL)pushToCross:(int)cross_id;
- (BOOL)pushToConversation:(int)cross_id;
- (void)onClickConversation:(UIView*)card;

@end
