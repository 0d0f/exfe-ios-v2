//
//  WelcomeView.h
//  EXFE
//
//  Created by huoju on 9/4/12.
//
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import <CoreText/CoreText.h>

@interface WelcomeView : UIView{
    UIButton *gobutton;
    UIButton *closebutton;
    NSMutableAttributedString *welcome1;
}
- (void) drawWelcome1;
- (void) initWelcome1;
@end
