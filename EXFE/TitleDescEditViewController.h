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
#import "EXAttributedLabel.h"
#import "EXCurveImageView.h"
#import "ImgCache.h"
#import "Util.h"
#import "NewGatherViewController.h"

@interface TitleDescEditViewController : UIViewController{
    EXGradientToolbarView *toolbar;
    EXCurveView *headview;
    UIImageView *dectorView;
    UITextView *titleView;
    UITextView *descView;
    id delegate;
    float keyboardheight;
    NSString *imgurl;
}

@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSString *imgurl;

- (void) setCrossTitle:(NSString*)title desc:(NSString*)desc;
- (void) done:(id)sender;
- (void) setBackground:(NSString *)imgurl;
@end
