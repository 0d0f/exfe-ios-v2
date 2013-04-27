//
//  EFIdentityTextField.m
//  EXFE
//
//  Created by Stony Wang on 13-4-27.
//
//

#import "EFIdentityTextField.h"

@implementation EFIdentityTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
    UIEdgeInsets insets = {0, 10, 0, 10};
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
    UIEdgeInsets insets = {0, 10, 0, 10};
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
