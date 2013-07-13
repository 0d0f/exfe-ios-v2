//
//  EFEditProfile.h
//  EXFE
//
//  Created by Stony Wang on 13-7-8.
//
//

#import <UIKit/UIKit.h>
#import "User+EXFE.h"
#import "Identity+EXFE.h"

@interface EFEditProfileViewController : UIViewController < UIImagePickerControllerDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Identity *identity;
@property (nonatomic, assign, readonly) BOOL isEditUser;

- (id)initWithModel:(EXFEModel*)model;
@end
