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
#import "EXCurveView.h"
#import "CustomAttributedTextView.h"
#import "UIUnderlinedButton.h"

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    IBOutlet UIToolbar* toolbar;
    
    
    UIImageView* useravatar;
    UILabel* username;
    EXCurveView *headerView;
    UIButton *btnBack;
    
    IBOutlet UITableView* tableview;
    IBOutlet ProfileCellView *tblCell;
//    BOOL statusBarHidden;
    
    NSMutableArray *identitiesData;
    //UIView *headerView;
    UIView *footerView;
    UIButton *buttonsignout;
    User *user;
    NSString *usernametext;
    UIImage *useravatarimg;
}
- (void)touchesBegan:(UITapGestureRecognizer*)sender;
- (void)loadObjectsFromDataStore;
- (void) Logout;
- (void) refreshIdentities;
- (void) test:(id)sender;
- (void) doVerify:(int)identity_id;
- (Identity*) getIdentityById:(int)identity_id;
- (NSIndexPath*) getIndexById:(int)identity_id;
- (void) deleteIdentity:(int)identity_id;
- (void) deleteIdentityUI:(int)identity_id;
@end
