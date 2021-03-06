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
#import "Util.h"
#import "NewGatherViewController.h"
#import "SSTextView.h"

@interface TitleDescEditViewController : UIViewController<UITextViewDelegate>{
    EXGradientToolbarView *toolbar;
    EXCurveView *headview;
    UIImageView *dectorView;
    UITextView *titleView;
    SSTextView *descView;
    id delegate;
    float keyboardheight;
    NSString *imgurl;
    NSInteger editFieldHint;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *imgurl;
@property (nonatomic) NSInteger editFieldHint;

- (void) setCrossTitle:(NSString*)title desc:(NSString*)desc;
- (void) done:(id)sender;
- (void) setBackground:(NSString *)_imgurl;

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView;


@end
