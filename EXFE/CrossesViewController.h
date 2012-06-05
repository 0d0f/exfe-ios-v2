//
//  CrossesViewController.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APICrosses.h"

@interface CrossesViewController : UIViewController<RKRequestDelegate,RKObjectLoaderDelegate>{
    IBOutlet UITableView* _tableView;
    NSArray* _crosses;
}
   
-(void) refreshCrosses;
- (void)loadObjectsFromDataStore;
@end
