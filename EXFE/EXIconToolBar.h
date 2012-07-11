//
//  EXIconToolBar.h
//  EXFE
//
//  Created by huoju on 7/11/12.
//
//

#import <UIKit/UIKit.h>
#import "EXButton.h"

#define DEFAULT_BUTTON_WIDTH 30
#define DEFAULT_BUTTON_HEIGHT 30
@interface EXIconToolBar : UIView{
    float button_width;
    float button_height;
    id _delegate;
    int itemIndex;
}
- (void)setDelegate:(id)delegate;
- (id)initWithPoint:(CGPoint)point buttonsize:(CGSize)buttonsize delegate:(id)delegate;
- (void) drawButton:(NSArray*)buttons;
- (void) setItemIndex:(int)index;
@end
