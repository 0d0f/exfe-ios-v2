//
//  SinginIconToolbarView.h
//  EXFE
//
//  Created by huoju on 8/24/12.
//
//

#import <UIKit/UIKit.h>
#import "Util.h"
@interface SigninIconToolbarView : UIView{
    UIButton *signinbutton;
    UIButton *twitterbutton;
}
- (id)initWithFrame:(CGRect)frame style:(NSString*)style delegate:(id)delegate;
@end
