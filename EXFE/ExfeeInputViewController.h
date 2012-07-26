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

@interface ExfeeInputViewController : UIViewController <UITextFieldDelegate,RKObjectLoaderDelegate>{
    IBOutlet UITextField *exfeeInput;
    NSMutableArray *suggestIdentities;
    UIViewController *gatherview;
    IBOutlet UITableView *suggestionTable;
    BOOL showInputinSuggestion;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (IBAction) Close:(id) sender;
- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (IBAction)editingDidEnd:(UITextField*)textField;
- (void) addByText;
- (void) getIdentity:(NSString*)identity_json;
@end
