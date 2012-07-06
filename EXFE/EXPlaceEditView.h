//
//  EXPlaceEditView.h
//  EXFE
//
//  Created by huoju on 6/29/12.
//
//

#import <UIKit/UIKit.h>
#import "Util.h"

@interface EXPlaceEditView : UIView <UITextFieldDelegate>{
    UITextField *PlaceTitle;
    UITextView *PlaceDesc;
    UIButton* closeButton;
}
- (void) setPlaceTitle:(NSString*)title;
- (void) setPlaceDesc:(NSString*)desc;

- (NSString*) getPlaceTitle;
- (NSString*) getPlaceDesc;
- (CGRect) getCloseButtonFrame;
@end
