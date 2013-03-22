//
//  ProfileViewController.h
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ProfileCellView.h"
#import "User.h"
#import "Util.h"
#import "FullScreenViewController.h"
#import "AddIdentityViewController.h"
#import "CustomAttributedTextView.h"
#import "UIUnderlinedButton.h"

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
//    IBOutlet UIToolbar* toolbar;
    
    UIImageView* useravatar;
    UILabel* username;
    UIView *headerView;
    UIButton *btnBack;
    
    IBOutlet UITableView* tableview;
    IBOutlet ProfileCellView *tblCell;
    
    NSArray * _identitiesData;
    UIView *footerView;
    UIButton *buttonsignout;
}

@property (nonatomic, retain) User *user;

- (void) touchesBegan:(UITapGestureRecognizer*)sender;
- (void) Logout;
- (void) syncUser;
- (void) doVerify:(int)identity_id;
- (NSIndexPath*) getIndexById:(int)identity_id;
- (void) deleteIdentity:(int)identity_id;
- (void) deleteIdentityUI:(int)identity_id;

- (void) showRome;
@end
