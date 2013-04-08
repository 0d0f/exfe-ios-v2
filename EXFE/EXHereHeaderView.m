//
//  EXHereHeaderView.m
//  EXFE
//
//  Created by 0day on 13-3-30.
//
//

#import "EXHereHeaderView.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "EXArrowView.h"
#import "AppDelegate.h"

@interface EXHereHeaderView ()
@property (nonatomic, retain) UILabel *tipLabel;
@property (nonatomic, assign) UIWindow *originWindow;
@property (nonatomic, retain) UIWindow *innerWindow;
@property (nonatomic, assign) BOOL isTipViewPresented;
@end

@implementation EXHereHeaderView

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXHereHeaderView"
                                           owner:nil
                                         options:nil] lastObject] retain];
    
    if (self) {
        // background layer
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[UIColor COLOR_RGB(0x33, 0x33, 0x33)].CGColor, (id)[UIColor COLOR_RGB(0x22, 0x22, 0x22)].CGColor];
        [self.layer insertSublayer:gradient atIndex:0];
        
        // button background
        UIImage *buttonBackgroundImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        if ([buttonBackgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){0, 10, 0, 10}];
        } else {
            buttonBackgroundImage = [buttonBackgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        }
        
        [self.gatherButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        
        // wave animation
        NSMutableArray *animations = [[NSMutableArray alloc] initWithCapacity:60];
        for (int i = 0; i < 60; i++) {
            NSString *imageName = (i / 10) ? [NSString stringWithFormat:@"liveicon_%d.png", i] : [NSString stringWithFormat:@"liveicon_0%d.png", i];
            [animations addObject:[UIImage imageNamed:imageName]];
        }
        self.waveAnimationImageView.animationImages = animations;
        self.waveAnimationImageView.animationDuration = 1.0f;
        self.waveAnimationImageView.backgroundColor = [UIColor COLOR_BLUE_LAKE];
        self.waveAnimationImageView.layer.cornerRadius = 3.0f;
        self.waveAnimationImageView.layer.masksToBounds = YES;
        [self.waveAnimationImageView startAnimating];
        [animations release];
        
        // tipView
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{15, 10}, {200, 80}}];
        tipLabel.text = @"People accessing exfe.com by your side are shown below. If not found, put two phones together with speaker volume max.";
        tipLabel.numberOfLines = 4;
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        tipLabel.backgroundColor = [UIColor clearColor];
        
        _arrowView = [[EXArrowView alloc] initWithFrame:(CGRect){{10, 38}, {300, 100}}];
        [_arrowView setPointPosition:(CGPoint){CGRectGetMidX(self.bounds) - 10, CGRectGetMidY(self.bounds)} andArrowDirection:kEXArrowDirectionUp];
        _arrowView.gradientColors = @[(id)[UIColor COLOR_RGB(0x36, 0x9F, 0xE9)].CGColor, (id)[UIColor COLOR_RGB(0x23, 0x55, 0x8C)].CGColor];
        _arrowView.strokeColor = [UIColor COLOR_BLUE_LAKE];
        [_arrowView setNeedsDisplay];
        
        [_arrowView addSubview:tipLabel];
        self.tipLabel = tipLabel;
        [tipLabel release];
        
        CATransform3D scaleTransform3D = CATransform3DMakeScale(0.073f, 0.25f, 1.0f);
        CATransform3D rotationTransform3D = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
        CATransform3D transform = CATransform3DConcat(scaleTransform3D, rotationTransform3D);
        CATransform3D translateTransform3D = CATransform3DMakeTranslation(37, -64, 0.0f);
        transform = CATransform3DConcat(transform, translateTransform3D);
        _arrowView.layer.transform = transform;
        
        self.tipLabel.alpha = 0.0f;
        _arrowView.alpha = 0.0f;
        
        [self addSubview:_arrowView];
        
        self.isTipViewPresented = NO;
    }
    
    return self;
}

- (void)dealloc {
    [_waveAnimationImageView release];
    [_innerWindow release];
    [_arrowView release];
    [_backButton release];
    [_gatherButton release];
    [_waveAnimationImageView release];
    [super dealloc];
}

- (IBAction)titleControlPressed:(id)sender {
    if (self.isTipViewPresented) {
        [self dismissTipView];
    } else {
        [self presentTipView];
    }
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    [self dismissTipView];
}

- (void)presentTipView {
    self.originWindow = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    self.innerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    [self.innerWindow addGestureRecognizer:tap];
    self.innerWindow.backgroundColor = [UIColor clearColor];
    [tap release];
    
    [self.innerWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.05f
                     animations:^{
                         self.waveAnimationImageView.alpha = 0.0f;
                         self.arrowView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         [self.waveAnimationImageView stopAnimating];
                         CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
                         animation.values = @[[NSValue valueWithCATransform3D:_arrowView.layer.transform],
                                              [NSValue valueWithCATransform3D:CATransform3DIdentity]];
                         animation.duration = 0.233f;
                         [_arrowView.layer addAnimation:animation forKey:nil];
                         _arrowView.layer.transform = CATransform3DIdentity;
                         
                         [UIView animateWithDuration:0.233f
                                          animations:^{
                                              self.tipLabel.alpha = 1.0f;
                                          }];
                     }];
}

- (void)dismissTipView {
    CATransform3D scaleTransform3D = CATransform3DMakeScale(0.073f, 0.25f, 1.0f);
    CATransform3D rotationTransform3D = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    CATransform3D transform = CATransform3DConcat(scaleTransform3D, rotationTransform3D);
    CATransform3D translateTransform3D = CATransform3DMakeTranslation(37, -64, 0.0f);
    transform = CATransform3DConcat(transform, translateTransform3D);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = @[[NSValue valueWithCATransform3D:_arrowView.layer.transform],
                         [NSValue valueWithCATransform3D:transform]];
    animation.duration = 0.233f;
    [_arrowView.layer addAnimation:animation forKey:nil];
    _arrowView.layer.transform = transform;
    
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.tipLabel.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self.waveAnimationImageView startAnimating];
                         [UIView animateWithDuration:0.05f
                                          animations:^{
                                              self.waveAnimationImageView.alpha = 1.0f;
                                              self.arrowView.alpha = 0.0f;
                                          }
                                          completion:^(BOOL finished){
                                              [self.originWindow makeKeyAndVisible];
                                              self.innerWindow.hidden = YES;
                                              [_innerWindow release];
                                              _innerWindow = nil;
                                          }];
                     }];
}

@end
