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
#import "FullScreenViewController.h"

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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)loadObjectsFromDataStore;
@end
