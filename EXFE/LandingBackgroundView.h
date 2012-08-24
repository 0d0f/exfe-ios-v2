//
//  LandingBackground.h
//  EXFE
//
//  Created by huoju on 8/22/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "Util.h"

@interface LandingBackgroundView : UIView {
    NSMutableDictionary *circleRects;
    NSMutableAttributedString *titleexfe;
    NSMutableAttributedString *titlethex;
    NSMutableAttributedString *titlesafe;
    NSMutableAttributedString *titlehandy;
    NSMutableAttributedString *titlersvp;
    NSString *bigtitlename;
}
- (void) drawCircle:(CGPoint)center radius:(float)r str:(NSAttributedString*)str isRing:(BOOL)isring;
- (void) initAttributedString;
- (void) drawBigTitle;
- (void) touch_thex;
- (void) touch_rsvp;
- (void) touch_handy;
- (void) touch_safe;
@end
