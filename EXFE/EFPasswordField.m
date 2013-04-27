//
//  EFPasswordField.m
//  EXFE
//
//  Created by Stony Wang on 13-4-16.
//
//

#import "EFPasswordField.h"

@interface EFPasswordField (){
    double down;
    
}
@end

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
        self.leftViewMode = UITextFieldViewModeAlways;
        [imageView release];
        
        UIButton *btnS = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        btnS.backgroundColor = [UIColor clearColor];
        [btnS addTarget:self action:@selector(touchdown:) forControlEvents:UIControlEventTouchDown];
        [btnS addTarget:self action:@selector(touchup:) forControlEvents:UIControlEventTouchUpInside];
        [btnS addTarget:self action:@selector(touchup:) forControlEvents:UIControlEventTouchUpOutside];
        [btnS setImage:[UIImage imageNamed:@"pass_show.png"] forState:UIControlStateNormal];
        btnS.imageView.contentMode = UIViewContentModeCenter;
        self.eye = btnS;
        [btnS release];
        
        UIButton *btnf = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        btnf.backgroundColor = [UIColor clearColor];
        [btnf setImage:[UIImage imageNamed:@"pass_question.png"] forState:UIControlStateNormal];
        btnf.imageView.contentMode = UIViewContentModeCenter;
        self.btnForgot = btnf;
        [btnf release];
        
        self.rightView = self.btnForgot;
        self.rightViewMode = UITextFieldViewModeAlways;
        
        [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)touchup:(id)target
{
    double now = CACurrentMediaTime();
    if (now - down < 300) {
        [self performSelector:@selector(protectText) withObject:nil afterDelay:0.3];
    } else {
        [self protectText];
    }
}

- (void)touchdown:(id)target
{
    down = CACurrentMediaTime();
    [self showText];
}

- (void)showText
{
    self.secureTextEntry = NO;
}

- (void)protectText
{
    BOOL flag = [self isFirstResponder];
    self.enabled = NO;
    self.secureTextEntry = YES;
    self.enabled = YES;
    if (flag) {
        [self becomeFirstResponder];
    }
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

- (void)drawTextInRect:(CGRect)rect
{
    //    NSLog(@"drawTextInRect in %@", NSStringFromCGRect(rect));
    //    UIEdgeInsets insets = {0, 5, 0, 0};
    //
    //    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
    NSLog(@"drawTextInRect %@ ", NSStringFromCGRect(rect));
    return [super drawTextInRect:rect];
}

//- (CGRect)borderRectForBounds:(CGRect)bounds
//{
//    CGRect rect = [super borderRectForBounds:bounds];
//    NSLog(@"borderRectForBounds %@ in %@", NSStringFromCGRect(rect), NSStringFromCGRect(bounds));
//    return rect;
//}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
    UIEdgeInsets insets = {0, 5, 0, 10};
    return UIEdgeInsetsInsetRect(rect, insets);
}

//- (CGRect)placeholderRectForBounds:(CGRect)bounds
//{
//    CGRect rect = [super placeholderRectForBounds:bounds];
//    NSLog(@"placeholderRectForBounds %@ in %@", NSStringFromCGRect(rect), NSStringFromCGRect(bounds));
////    UIEdgeInsets insets = {0, 5, 0, 5};
////    return UIEdgeInsetsInsetRect(rect, insets);
//    return rect;
//}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    UIEdgeInsets insets = {0, 5, 0, 10};
    return UIEdgeInsetsInsetRect(rect, insets);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect rect = [super clearButtonRectForBounds:bounds];
    return CGRectMake(CGRectGetWidth(bounds) - CGRectGetWidth(rect) / 2 - 15 - 5, CGRectGetMidY(bounds) - CGRectGetHeight(rect) / 2, CGRectGetWidth(rect) , CGRectGetHeight(rect));
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super leftViewRectForBounds:bounds];
    return CGRectMake(5, CGRectGetMidY(bounds) - CGRectGetHeight(rect) / 2, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super rightViewRectForBounds:bounds];
    return CGRectMake(CGRectGetWidth(bounds) - CGRectGetWidth(rect) / 2 - 15 - 5, CGRectGetMidY(bounds) - CGRectGetHeight(rect) / 2, CGRectGetWidth(rect) , CGRectGetHeight(rect));
}

@end
