//
//  EFTextField.m
//  EXFE
//
//  Created by Stony Wang on 13-4-24.
//
//

#import "EFTextField.h"

@implementation EFTextField

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

//- (void)drawTextInRect:(CGRect)rect
//{
//    NSLog(@"drawTextInRect in %@", NSStringFromCGRect(rect));
//    UIEdgeInsets insets = {0, 5, 0, 0};
//    
//    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
//}

//// placeholder position
//- (CGRect)textRectForBounds:(CGRect)bounds
//{
//    UIEdgeInsets insets = {10, 10, 0, 10};
//    CGRect rect = [super textRectForBounds:bounds];
//    return rect;
//}

//// text position
//- (CGRect)editingRectForBounds:(CGRect)bounds
//{
//    CGRect rect = [super editingRectForBounds:bounds];
//    NSLog(@"editingRectForBounds %@ in %@", NSStringFromCGRect(rect), NSStringFromCGRect(bounds));
//    return rect;
////    UIEdgeInsets insets = {10, 10, 0, 10};
////    CGRect rect = [super editingRectForBounds:bounds];
////    return rect;
//}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
//    CGRect rect = [super clearButtonRectForBounds:bounds];
//    NSLog(@"clearButtonRectForBounds %@ in %@", NSStringFromCGRect(rect), NSStringFromCGRect(bounds));
//    return rect;
    return CGRectMake(CGRectGetWidth(bounds) - 40, CGRectGetMidY(bounds) - 20, 40 , 40);
}

//- (CGRect)leftViewRectForBounds:(CGRect)bounds
//{
//    CGRect rect = [super leftViewRectForBounds:bounds];
//    NSLog(@"leftViewRectForBounds %@ in %@", NSStringFromCGRect(rect), NSStringFromCGRect(bounds));
//    return rect;
//}
//
//- (CGRect)rightViewRectForBounds:(CGRect)bounds
//{
//    CGRect rect = [super rightViewRectForBounds:bounds];
//    NSLog(@"rightViewRectForBounds %@ in %@", NSStringFromCGRect(rect), NSStringFromCGRect(bounds));
//    return rect;
//}
@end
