//
//  ConversationViewController.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationViewController : UIViewController{
    IBOutlet UITableView* _tableView;
    NSArray* _posts;
}
- (void)loadObjectsFromDataStore;
@end
