//
//  EXSpinView.h
//  EXFE
//
//  Created by huoju on 9/9/12.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kEXSpinViewStyleSystem = 0, // Default
    kEXSpinViewStyleEXFE,
} EXSpinViewStyle;

@interface EXSpinView : UIView

@property (nonatomic, readonly) EXSpinViewStyle style;    // Default as kEXSpinViewStyleSystem, set using initWithPoint:size:style:

- (id)initWithPoint:(CGPoint)point size:(int)size;
- (id)initWithPoint:(CGPoint)point size:(int)size style:(EXSpinViewStyle)style;

- (void)startAnimating;
- (void)stopAnimating;

@end
