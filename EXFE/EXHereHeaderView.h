//
//  EXHereHeaderView.h
//  EXFE
//
//  Created by 0day on 13-3-30.
//
//

#import <UIKit/UIKit.h>

@class EXArrowView;
@interface EXHereHeaderView : UIView

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *gatherButton;
@property (retain, nonatomic) EXArrowView *arrowView;

- (id)init;

@end
