//
//  EXIconToolBar.h
//  EXFE
//
//  Created by huoju on 7/11/12.
//
//

#import <UIKit/UIKit.h>
#import "EXButton.h"
#import "Util.h"

#define DEFAULT_BUTTON_WIDTH 36
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
- (void) replaceButtonImage:(UIImage*)img title:(NSString*)title target:(id)target action:(SEL)action forname:(NSString*)name;
- (void) updateButtonFrame:(NSString*)name frame:(CGRect)rect;
@end
