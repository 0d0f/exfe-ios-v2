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
    NSMutableArray *suggestIdentities;
//    NSMutableArray *selectedIdentities;
    UIViewController *gatherview;
    UITableView *suggestionTable;
    BOOL showInputinSuggestion;
    
    EXBubbleScrollView *exfeeList;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (IBAction) Close:(id) sender;
- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (IBAction)editingDidEnd:(UITextField*)textField;
- (void) addByText;
- (void) getIdentity:(NSString*)identity_json;
@end
