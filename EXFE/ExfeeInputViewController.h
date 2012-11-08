//
//  ExfeeInputViewController.h
//  EXFE
//
//  Created by huoju on 7/25/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "APIProfile.h"
#import "Identity.h"
#import "Invitation.h"
#import "GatherViewController.h"
#import "EXBubbleScrollView.h"
#import "Util.h"

@interface ExfeeInputViewController : UIViewController <UITextFieldDelegate,RKObjectLoaderDelegate,UITableViewDelegate,UITableViewDataSource,EXBubbleScrollViewDelegate,UIScrollViewDelegate>{
    UITextField *exfeeInput;
    UIView *toolbar;
    NSMutableArray *suggestIdentities;
    UIViewController *gatherview;
    UITableView *suggestionTable;
    UIImageView *inputframeview;
    BOOL showInputinSuggestion;
    EXBubbleScrollView *exfeeList;
    UIImageView *inputlefticon;
    UIImageView *inputleftmask;
    UIView *errorHint;
    UIImageView *errorHinticon;
    UILabel *errorHintLabel;
    BOOL ifAddExfeeSend;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (void) done:(id)sender;
- (IBAction) Close:(id) sender;
- (Identity*) getIdentityFromLocal:(NSString*)input;
- (void) addBubbleByIdentity:(Identity*)identity input:(NSString*)input;
- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (IBAction)editingDidEnd:(UITextField*)textField;
//- (void) addByText;
- (void) addByInputIdentity:(NSString*)input dismiss:(BOOL)shoulddismiss;
- (void) loadIdentitiesFromDataStore:(NSString*)input;
- (void) changeLeftIconWhite:(BOOL)iswhite;
- (void) ErrorHint:(BOOL)hidden content:(NSString*)content;
- (BOOL) showErrorHint;
- (void) addExfeeToCross;
@end
