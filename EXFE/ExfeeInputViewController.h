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
#import "NewGatherViewController.h"
#import "EXBubbleScrollView.h"
#import "Util.h"
#import "AddressBook.h"
#import "UIBorderView.h"
#import "EXGradientToolbarView.h"
#import "GatherExfeeInputCell.h"
#import <objc/runtime.h>
//#import "LocalContact.h"

#define LOCAL_ADDRESSBOOK 0
#define EXFE_ADDRESSBOOK 1

@interface ExfeeInputViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,EXBubbleScrollViewDelegate,UIScrollViewDelegate>{
    UITextField *exfeeInput;
    EXGradientToolbarView *toolbar;
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
    UIView *expandExfeeViewShadow;
    int addressbookType;
    int selectedRowIndex;
    int expandCellHeight;
    UIButton *btnEXFE;
    UIButton *btnLocal;
    AddressBook *address;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (void) done:(id)sender;
- (void) Close;
- (Identity*) getIdentityFromLocal:(NSString*)input provider:(NSString*)provider;
- (void) addBubbleByIdentity:(Identity*)identity input:(NSString*)input;
- (void) addBubbleByInputString:(NSString*)input name:(NSString*)name provider:(NSString*)provider;

- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)editingDidBegan:(UITextField*)textField;
- (IBAction)editingDidEnd:(UITextField*)textField;
//- (void) addByText;
- (void) addByInputIdentity:(NSString*)input name:(NSString*)name provider:(NSString*)provider dismiss:(BOOL)shoulddismiss;
- (void) loadIdentitiesFromDataStore:(NSString*)input;
- (void) changeLeftIconWhite:(BOOL)iswhite;
- (void) ErrorHint:(BOOL)hidden content:(NSString*)content;
- (BOOL) showErrorHint;
- (void) addExfeeToCross;
- (void) reloadLocalAddressBook;
- (void) reloadExfeAddressBook;
- (void) checkButtonTapped:(id)sender event:(id)event;
- (void) selectidentity:(id)sender;
- (void) copyMoreContactsFromIdx:(int)idx;

@end
