//
//  EFPasswordField.h
//  EXFE
//
//  Created by Stony Wang on 13-4-16.
//
//

#import <UIKit/UIKit.h>

@interface EFPasswordField : UITextField<UITextFieldDelegate>

@property (nonatomic, assign) UIImageView *icon;
@property (nonatomic, retain) UIButton *eye;
@property (nonatomic, retain) UIButton *btnForgot;

@end
