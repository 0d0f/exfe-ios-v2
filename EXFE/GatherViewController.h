//
//  GatherViewController.h
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import <UIKit/UIKit.h>
//#import "JSONKit.h"
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "CrossesViewController.h"
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "User.h"
#import "Invitation.h"
#import "EXImagesCollectionView.h"
#import "ImgCache.h"

@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate,EXImagesCollectionDataSource,UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITextField *crosstitle;
    IBOutlet UITextField *ExfeeInput;
    UITableView *suggestionTable;
    NSArray *suggestIdentities;
    NSMutableArray *exfeeIdentities;
    IBOutlet EXImagesCollectionView *exfeeShowview;
}

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;

- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)textEditBegin:(id)textField;

- (void) addDefaultIdentity;

@end
