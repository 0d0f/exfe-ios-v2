//
//  EXPlaceEditView.h
//  EXFE
//
//  Created by huoju on 6/29/12.
//
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import <QuartzCore/QuartzCore.h>

@interface EXPlaceEditView : UIView <UITextFieldDelegate>{
    UITextField *PlaceTitle;
    UITextView *PlaceDesc;
    UIButton* closeButton;
}

@property (nonatomic,strong) UITextField* PlaceTitle;
@property (nonatomic,strong) UITextView *PlaceDesc;

- (void) setPlaceTitleText:(NSString*)title;
- (void) setPlaceDescText:(NSString*)desc;

- (NSString*) getPlaceTitleText;
- (NSString*) getPlaceDescText;
- (CGRect) getCloseButtonFrame;
@end
