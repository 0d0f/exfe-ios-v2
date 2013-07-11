//
//  EFChangePasswordViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-7-8.
//
//

#import <UIKit/UIKit.h>
#import "OAuthLoginViewController.h"

@interface EFChangePasswordViewController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, OAuthLoginViewControllerDelegate>

@property (nonatomic, strong) User * user;

- (id)initWithModel:(EXFEModel*)model;

@end
