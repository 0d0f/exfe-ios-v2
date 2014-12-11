//
//  UITextView+NumberOfLines.h
//  EXFE
//
//  Created by 0day on 13-8-16.
//
//

#import <UIKit/UIKit.h>

@interface UITextView (NumberOfLines)

@property (nonatomic, readonly) NSUInteger numberOfLines;

// Override Method
- (void)sizeToFit;

@end
