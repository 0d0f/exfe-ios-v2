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

@property (nonatomic, assign) CGFloat curveBase;
@property (nonatomic, assign) CGPoint curveCenter;
@property (nonatomic, assign) CGSize curveParamRect;
@property (nonatomic, assign) CGSize curveParamControl;

- (void) setimage:(UIImage*)image;
- (void) updateCurvePath:(UIBezierPath*)path;

@end
