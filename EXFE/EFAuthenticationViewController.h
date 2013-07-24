//
//  EFAuthenticationViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-7-22.
//
//

#import <UIKit/UIKit.h>
#import "OAuthLoginViewController.h"

typedef BOOL (^NextStep)();

@interface EFAuthenticationViewController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, OAuthLoginViewControllerDelegate>

@property (nonatomic, strong) User * user;
@property (nonatomic, copy) NextStep nextStep;

- (id)initWithModel:(EXFEModel*)model;

@end