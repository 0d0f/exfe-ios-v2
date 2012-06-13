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

@interface CrossesViewController : PullRefreshTableViewController <RKRequestDelegate,RKObjectLoaderDelegate>{
    IBOutlet UITableView* tableView;
    UIBarButtonItem *barButtonItem;
    NSArray* _crosses;
}
   
-(void) refreshCrosses;
- (void)loadObjectsFromDataStore;
- (void)initUI;
- (void)ShowProfileView;
@end
