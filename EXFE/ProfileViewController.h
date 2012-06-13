//
//  ProfileViewController.h
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ProfileCell.h"
#import "ProfileCellView.h"
#import "User.h"

@interface ProfileViewController : UIViewController{
    IBOutlet UIToolbar* toolbar;
    IBOutlet UIImageView* useravatar;
    IBOutlet UILabel* username;
    IBOutlet UITableView* tabview;
    IBOutlet ProfileCellView *tblCell;

    NSMutableArray *identitiesData;
    UIView *footerView;
    User *user;
}
- (void)loadObjectsFromDataStore;
@end
