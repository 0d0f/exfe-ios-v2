//
//  ExfeeInputViewController.h
//  EXFE
//
//  Created by huoju on 7/25/12.
//
//

#import <UIKit/UIKit.h>
#import "APIProfile.h"
#import "Identity.h"
#import "Invitation.h"
#import "GatherViewController.h"
#import "EXBubbleScrollView.h"

@interface ExfeeInputViewController : UIViewController <UITextFieldDelegate,RKObjectLoaderDelegate,UITableViewDelegate,UITableViewDataSource,EXBubbleScrollViewDelegate>{
    IBOutlet UITextField *exfeeInput;
    IBOutlet UIToolbar *toolbar;
    NSMutableArray *suggestIdentities;
    UIViewController *gatherview;
    UITableView *suggestionTable;
    UIImageView *inputframeview;
    BOOL showInputinSuggestion;
    EXBubbleScrollView *exfeeList;
    UIImageView *inputlefticon;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (void) done:(id)sender;
- (IBAction) Close:(id) sender;
- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (IBAction)editingDidEnd:(UITextField*)textField;
//- (void) addByText;
- (void) addByInputIdentity:(NSString*)input;
- (void)loadIdentitiesFromDataStore:(NSString*)input;
@end
