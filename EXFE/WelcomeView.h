//
//  WelcomeView.h
//  EXFE
//
//  Created by huoju on 9/4/12.
//
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "CrossesViewController.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@interface WelcomeView : UIView{
    UIButton *gobutton;
    UIButton *closebutton;
    NSMutableAttributedString *welcome1;
    NSMutableAttributedString *welcome2;
    UIViewController *parent;
    int viewpage;
}
@property (nonatomic,strong) UIViewController *parent;
- (void) drawWelcome1;
- (void) initWelcome1;
- (void) drawWelcome2;
- (void) initWelcome2;
- (void) goNext;
@end
