//
//  GatherViewController.h
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "RestKit.h"
#import "AppDelegate.h"
#import "CrossesViewController.h"

@interface GatherViewController : UIViewController <RKRequestDelegate>

- (IBAction) Gather:(id) sender;
@end
