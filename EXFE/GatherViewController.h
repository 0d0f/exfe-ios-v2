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
#import "APIProfile.h"
#import "Invitation.h"
#import "ImgCache.h"
#import "PlaceViewController.h"

#define AVATAR_API @"http://api.0d0f.com/v2/avatar/default?name="
@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate,EXImagesCollectionDataSource,UITableViewDataSource,UITableViewDelegate,EXImagesCollectionDelegate,UITextFieldDelegate>{
    IBOutlet UITextField *crosstitle;
    IBOutlet UITextField *ExfeeInput;
    UITableView *suggestionTable;
    NSMutableArray *suggestIdentities;
    NSMutableArray *exfeeIdentities;
    IBOutlet EXImagesCollectionView *exfeeShowview;
}

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;
- (IBAction) ShowPlaceView:(id) sender;

- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)textEditBegin:(id)textField;
- (void) addDefaultIdentity;
- (NSString*) findProvider:(NSString*)external_id;
- (void) getIdentity:(NSString*)identity_json;
@end
