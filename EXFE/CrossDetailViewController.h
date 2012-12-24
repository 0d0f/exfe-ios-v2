//
//  CrossDetailViewController.h
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import <UIKit/UIKit.h>
#import "EXCurveImageView.h"

@interface CrossDetailViewController : UIViewController <UITextViewDelegate>{
    UIScrollView *container;
    EXCurveImageView *dectorView;
    UITextView *descView;
    UIView *exfee_root;
    UITextField *timeRelView;
    UITextField *timeAbsView;
    UITextField *timeZoneView;
    UITextView *placeTitleView;
    UITextView *placeDescView;
    UIImageView *mapView;
}


- (void)initUI;
- (void)relayoutUI;

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView;

@end
