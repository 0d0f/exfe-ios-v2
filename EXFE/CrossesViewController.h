//
//  CrossesViewController.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "EXSpinView.h"

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
    UIImage *default_background;
}

@property (nonatomic, strong) NSArray* crossList;
@property (nonatomic, assign) BOOL needHeaderAnimation;

- (Cross*)crossWithId:(int)cross_id;
- (void)refreshTableViewWithCrossId:(int)cross_id;



#pragma mark navigation
- (void)showProfileViewWithAnimated:(BOOL)animated;
- (void)showGatherViewWithAnimated:(BOOL)animated;
- (BOOL)pushToCross:(int)cross_id;
- (BOOL)pushToConversation:(int)cross_id;
- (BOOL)showCross:(NSInteger)crossId withTabClass:(Class)class animated:(BOOL)animated;

- (void)onClickConversation:(UIView*)card;

@end

@interface CrossesViewController (URLNavigation)

//- (BOOL)needAbc;
- (BOOL)pushTo:(NSArray *)pathComponents animated:(BOOL)animated;

@end
