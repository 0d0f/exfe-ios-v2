//
//  UICurveView.h
//  EXFE
//
//  Created by Stony Wang on 13-1-10.
//
//

#import <UIKit/UIKit.h>

@interface EXCurveView : UIView{
    CGRect CurveFrame;
}

@property (nonatomic) CGRect CurveFrame;

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame;

@end
