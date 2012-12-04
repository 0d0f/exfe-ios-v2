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
#import "AddressBook.h"
#import "UIBorderView.h"
#import <objc/runtime.h>

#define LOCAL_ADDRESSBOOK 0
#define EXFE_ADDRESSBOOK 1

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
    NSArray *localcontacts;
    NSArray *filteredlocalcontacts;
    UIView *expandExfeeView;
    int addressbookType;
    int selectedRowIndex;
    int expandCellHeight;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (void) done:(id)sender;
- (IBAction) Close:(id) sender;
- (Identity*) getIdentityFromLocal:(NSString*)input provider:(NSString*)provider;
- (void) addBubbleByIdentity:(Identity*)identity input:(NSString*)input;
- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (IBAction)editingDidEnd:(UITextField*)textField;
//- (void) addByText;
- (void) addByInputIdentity:(NSString*)input provider:(NSString*)provider dismiss:(BOOL)shoulddismiss;
- (void) loadIdentitiesFromDataStore:(NSString*)input;
- (void) changeLeftIconWhite:(BOOL)iswhite;
- (void) ErrorHint:(BOOL)hidden content:(NSString*)content;
- (BOOL) showErrorHint;
- (void) addExfeeToCross;
- (void) reloadLocalAddressBook;
- (void) reloadExfeAddressBook;
- (void) checkButtonTapped:(id)sender event:(id)event;
- (void) selectidentity:(id)sender;

@end
