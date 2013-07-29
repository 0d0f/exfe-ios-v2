//
//  EFAuthenticationViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-7-22.
//
//

#import <UIKit/UIKit.h>

typedef void(^NextStep)(void);

@interface EFAuthenticationViewController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) User * user;
@property (nonatomic, copy) NextStep nextStep;

- (id)initWithModel:(EXFEModel*)model;

@end