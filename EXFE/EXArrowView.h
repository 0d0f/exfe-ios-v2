//
//  EXArrowView.h
//  EXFE
//
//  Created by 0day on 13-4-8.
//
//

#import <UIKit/UIKit.h>

typedef enum  {
    kEXArrowDirectionUp = 1UL << 0,
    kEXArrowDirectionDown = 1UL << 1,
    kEXArrowDirectionLeft = 1UL << 2,
    kEXArrowDirectionRight = 1UL << 3,
    kEXArrowDirectionAny = kEXArrowDirectionUp | kEXArrowDirectionDown | kEXArrowDirectionLeft | kEXArrowDirectionRight,
} EXArrowDirection;

@interface EXArrowView : UIView

@property (nonatomic, assign) CGFloat cornerRadius; // default as 8.0f
@property (nonatomic, copy) UIColor *strokeColor;   // default as black
@property (nonatomic, assign) CGFloat strokeWidth;  // default as 1

@property (nonatomic, assign) EXArrowDirection arrowDirection; // must be one of Up, Down, Left, Right.
@property (nonatomic, assign) CGPoint pointPosition;    // won't draw arrow when equal to {0, 0}, set after setting arrowDirection
@property (nonatomic, copy) NSArray *gradientColors; // array of CGColor, default as nil

- (void)setPointPosition:(CGPoint)pointPosition andArrowDirection:(EXArrowDirection)arrowDirection;

@end
