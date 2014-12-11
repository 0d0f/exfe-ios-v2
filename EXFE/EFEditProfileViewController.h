//
//  EFEditProfile.h
//  EXFE
//
//  Created by Stony Wang on 13-7-8.
//
//

#import <UIKit/UIKit.h>
#import "EFViewController.h"
#import "User+EXFE.h"
#import "Identity+EXFE.h"

@interface EFEditProfileViewController : EFViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Identity *identity;
@property (nonatomic, assign, readonly) BOOL isEditUser;
@property (nonatomic, assign) BOOL readonly;

- (id)initWithModel:(EXFEModel*)model;
@end
