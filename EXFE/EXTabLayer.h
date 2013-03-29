//
//  EXTabLayer.h
//  EXFE
//
//  Created by Stony Wang on 13-2-28.
//
//

#import <QuartzCore/QuartzCore.h>

@interface EXTabLayer : CALayer{
    CALayer *_sublayer;
    CALayer *_imglayer;
}

@property (nonatomic, assign) CGPoint curveParamBase;
@property (nonatomic, assign) CGRect curveParamControl1;
@property (nonatomic, assign) CGRect curveParamControl2;
@property (nonatomic, assign) CGPoint maskPosition;

- (void) setimage:(UIImage*)image;
- (void) updateCurvePath:(UIBezierPath*)path;

@end
