//
//  EFPasswordField.m
//  EXFE
//
//  Created by Stony Wang on 13-4-16.
//
//

#import "EFPasswordField.h"

@implementation EFPasswordField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.secureTextEntry = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        imageView.frame = CGRectMake(0, 0, 40, 40);
        imageView.image = [UIImage imageNamed:@"lock_18.png"];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.backgroundColor = [UIColor clearColor];
        self.icon = imageView;
        self.leftView = self.icon;
        [imageView release];
        
        UIButton *btnS = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        btnS.backgroundColor = [UIColor clearColor];
        [btnS addTarget:self action:@selector(touchdown:) forControlEvents:UIControlEventTouchDown];
        [btnS addTarget:self action:@selector(touchup:) forControlEvents:UIControlEventTouchUpInside];
        [btnS addTarget:self action:@selector(touchup:) forControlEvents:UIControlEventTouchUpOutside];
        [btnS setImage:[UIImage imageNamed:@"pass_show.png"] forState:UIControlStateNormal];
        btnS.imageView.contentMode = UIViewContentModeCenter;
        self.eye = btnS;
        [btnS release];
        
        UIButton *btnf = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        btnf.backgroundColor = [UIColor clearColor];
        [btnf setImage:[UIImage imageNamed:@"pass_question.png"] forState:UIControlStateNormal];
        btnf.imageView.contentMode = UIViewContentModeCenter;
        self.btnForgot = btnf;
        [btnf release];
        
        
        self.leftViewMode = UITextFieldViewModeAlways;
        self.rightView = self.btnForgot;
        self.rightViewMode = UITextFieldViewModeAlways;
        
        [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)touchup:(id)target
{
    BOOL flag = [self isFirstResponder];
    self.enabled = NO;
    self.secureTextEntry = YES;
    self.enabled = YES;
    if (flag) {
        [self becomeFirstResponder];
    }
}

- (void)touchdown:(id)target
{
    self.secureTextEntry = NO;
}

- (void)textFieldDidChange:(id)sender
{
    if (self.text.length == 0) {
        self.rightView = self.btnForgot;
    } else {
        if (self.rightView != self.eye) {
            self.rightView = self.eye;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
