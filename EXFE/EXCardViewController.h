//
//  EXCardViewController.h
//  EXFE
//
//  Created by 0day on 13-3-31.
//
//

#import <UIKit/UIKit.h>

@class User;
@class EXCardViewController;

@protocol EXCardViewControllerDelegate <NSObject>
@optional
- (void)cardViewControllerWillFinish:(EXCardViewController *)controller;
- (void)cardViewControllerDidFinish:(EXCardViewController *)controller;
@end

@interface EXCardViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate
>

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) User *user;
@property (nonatomic, assign) id<EXCardViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *identityPrivacyDict;

- (void)presentFromViewController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))handler;
- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))handler;

@end
