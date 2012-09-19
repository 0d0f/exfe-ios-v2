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

@interface ProfileViewController : UIViewController{
    IBOutlet UIToolbar* toolbar;
    UIImageView* useravatar;
    UILabel* username;
    IBOutlet UITableView* tableview;
    IBOutlet ProfileCellView *tblCell;
//    BOOL statusBarHidden;
    
    NSMutableArray *identitiesData;
    UIView *headerView;
    UIView *footerView;
    UIButton *buttonsignout;
    User *user;
    NSString *usernametext;
    UIImage *useravatarimg;
}
- (void)touchesBegan:(UITapGestureRecognizer*)sender;
- (void)loadObjectsFromDataStore;
- (void) Logout;
@end
