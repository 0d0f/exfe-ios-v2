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

#define LARGE_SLOT                       (16)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (88)
#define DECTOR_HEIGHT_EXTRA              (LARGE_SLOT)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define TITLE_HORIZON_MARGIN             (SMALL_SLOT)
#define TITLE_VERTICAL_MARGIN            (18)


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
