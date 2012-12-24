//
//  EXCurveImageView.h
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import <UIKit/UIKit.h>

@interface EXCurveImageView : UIImageView{
    CGRect CurveFrame;
}

@property CGRect CurveFrame;

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame;

@end
