//
//  EFIdentityBar.h
//  EXFE
//
//  Created by Stony Wang on 13-7-23.
//
//

#import <UIKit/UIKit.h>
#import "Identity+EXFE.h"

@interface EFIdentityBar : UIView

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;

@property (nonatomic, strong) Identity *identity;

@end
