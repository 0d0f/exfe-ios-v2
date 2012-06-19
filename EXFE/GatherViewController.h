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
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "Invitation.h"

@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate>{
    IBOutlet UITextField *crosstitle;
}

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;
@end
