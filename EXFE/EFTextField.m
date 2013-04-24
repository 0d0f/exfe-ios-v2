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

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    UIEdgeInsets insets = {5, 5, 5, 5};
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)];
//    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    UIEdgeInsets insets = {10, 10, 0, 10};
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)];
//    return CGRectInset( bounds , 10 , 10 );
}

@end
