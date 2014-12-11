//
//  EFArrowView.h
//  EXFE
//
//  Created by 0day on 13-4-8.
//
//

#import <UIKit/UIKit.h>

typedef enum  {
    kEFArrowDirectionUp = 1UL << 0,
    kEFArrowDirectionDown = 1UL << 1,
    kEFArrowDirectionLeft = 1UL << 2,
    kEFArrowDirectionRight = 1UL << 3,
    kEFArrowDirectionAny = kEFArrowDirectionUp | kEFArrowDirectionDown | kEFArrowDirectionLeft | kEFArrowDirectionRight,
    kEFArrowDirectionUnknow = NSUIntegerMax,
} EFArrowDirection;

@interface EFArrowView : UIView

@property (nonatomic, assign) CGFloat cornerRadius; // default as 4.0f
@property (nonatomic, copy) UIColor *strokeColor;   // default as black
@property (nonatomic, assign) CGFloat strokeWidth;  // default as 1

@property (nonatomic, assign) EFArrowDirection arrowDirection; // must be one of Up, Down, Left, Right.
@property (nonatomic, assign) CGPoint pointPosition;    // won't draw arrow when equal to {0, 0}, set after setting arrowDirection
@property (nonatomic, copy) NSArray *gradientColors; // array of CGColor, default as nil

- (void)setPointPosition:(CGPoint)pointPosition andArrowDirection:(EFArrowDirection)arrowDirection;

@end
