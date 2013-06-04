//
//  EFAddIdentityViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-6-3.
//
//

#import <UIKit/UIKit.h>
#import "OAuthLoginViewController.h"

@interface EFAddIdentityViewController : UIViewController<OAuthLoginViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, copy) id onExitBlock;

@end
