//
//  TitleDescEditViewController.h
//  EXFE
//
//  Created by huoju on 1/7/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EXGradientToolbarView.h"
#import "EXCurveImageView.h"
#import "ImgCache.h"
#import "Util.h"
#import "NewGatherViewController.h"

@interface TitleDescEditViewController : UIViewController{
    EXGradientToolbarView *toolbar;
    EXCurveImageView *dectorView;
    UITextView *titleView;
    UITextView *descView;
    UIViewController *gatherview;
    float keyboardheight;
}

@property (nonatomic,retain) UIViewController* gatherview;

- (void) done:(id)sender;
- (void) setBackground:(NSString *)imgurl;
@end
