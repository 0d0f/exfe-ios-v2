//
//  ProfileViewController.h
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileCell.h"

@interface ProfileViewController : UIViewController{
    IBOutlet UIToolbar* toolbar;
    IBOutlet UIImageView* useravatar;
    IBOutlet UILabel* username;
    IBOutlet UITableView* tabview;
    NSMutableArray *identitiesData;
    IBOutlet ProfileCell *tblCell;
    UIView *footerView;
}

@end
