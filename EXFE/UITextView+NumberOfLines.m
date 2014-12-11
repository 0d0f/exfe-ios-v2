//
//  UITextView+NumberOfLines.m
//  EXFE
//
//  Created by 0day on 13-8-16.
//
//

#import "UITextView+NumberOfLines.h"

@implementation UITextView (NumberOfLines)

- (NSUInteger)numberOfLines {
    return (NSUInteger)ceil(self.contentSize.height / self.font.lineHeight);
}

- (void)sizeToFit {
    CGRect frame = self.frame;
    UIEdgeInsets inset = self.contentInset;
    frame.size.height = self.contentSize.height + inset.top + inset.bottom;
    self.frame = frame;
}

@end
