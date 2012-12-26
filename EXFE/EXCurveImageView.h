//
//  EXCurveImageView.h
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import <UIKit/UIKit.h>

@interface EXCurveImageView : UIView{
    CGRect CurveFrame;
    UIImage *image;
}

@property CGRect CurveFrame;
@property (nonatomic,retain) UIImage * image;

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame;

@end
