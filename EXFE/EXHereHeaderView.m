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

@interface EXHereHeaderArrowView : UIView
@end

@implementation EXHereHeaderArrowView

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.212 green: 0.624 blue: 0.914 alpha: 1];
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPath];
    [roundedRectanglePath moveToPoint: CGPointMake(4.11, 7.74)];
    [roundedRectanglePath addLineToPoint: CGPointMake(0, 10.72)];
    [roundedRectanglePath addLineToPoint: CGPointMake(4.11, 13.41)];
    [roundedRectanglePath addLineToPoint: CGPointMake(4.11, 18)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(8.09, 22) controlPoint1: CGPointMake(4.11, 20.21) controlPoint2: CGPointMake(5.89, 22)];
    [roundedRectanglePath addLineToPoint: CGPointMake(22.02, 22)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(26, 18) controlPoint1: CGPointMake(24.22, 22) controlPoint2: CGPointMake(26, 20.21)];
    [roundedRectanglePath addLineToPoint: CGPointMake(26, 4)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(22.02, 0) controlPoint1: CGPointMake(26, 1.79) controlPoint2: CGPointMake(24.22, 0)];
    [roundedRectanglePath addLineToPoint: CGPointMake(8.09, 0)];
    [roundedRectanglePath addCurveToPoint: CGPointMake(4.11, 4) controlPoint1: CGPointMake(5.89, 0) controlPoint2: CGPointMake(4.11, 1.79)];
    [roundedRectanglePath addLineToPoint: CGPointMake(4.11, 7.74)];
    [roundedRectanglePath closePath];
    [color setFill];
    [roundedRectanglePath fill];
    
    CGContextSaveGState(context);
//    CGContextRestoreGState(context);
}

@end

@interface EXHereHeaderView ()
@property (nonatomic, retain) UIView *tipView;
@property (nonatomic, assign) UIWindow *originWindow;
@property (nonatomic, retain) UIWindow *innerWindow;
@property (nonatomic, assign) BOOL isTipViewPresented;
@end

@implementation EXHereHeaderView {
    EXHereHeaderArrowView *_littleArrowView;
}

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXHereHeaderView"
                                           owner:nil
                                         options:nil] lastObject] retain];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // background layer
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[UIColor COLOR_RGBA(0xFF, 0xFF, 0xFF, 51.0f)].CGColor, (id)[UIColor COLOR_RGBA(0xFF, 0xFF, 0xFF, 30.6f)].CGColor];
        [self.layer insertSublayer:gradient atIndex:0];
        
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = [UIColor COLOR_RGBA(0xFF, 0xFF, 0xFF, 64.0f)].CGColor;
        lineLayer.frame = (CGRect){{0, CGRectGetHeight(self.bounds)}, {CGRectGetWidth(self.bounds), 0.5f}};
        [self.layer addSublayer:lineLayer];
        
        // button background
        UIImage *buttonBackgroundImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        if ([buttonBackgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){0, 10, 0, 10}];
        } else {
            buttonBackgroundImage = [buttonBackgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        }
        
        [self.gatherButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        
        _littleArrowView = [[EXHereHeaderArrowView alloc] initWithFrame:(CGRect){{184, 13}, {26, 22}}];
        _littleArrowView.backgroundColor = [UIColor clearColor];
        [self addSubview:_littleArrowView];
        
        // wave animation
        NSMutableArray *animations = [[NSMutableArray alloc] initWithCapacity:100];
        for (int i = 0; i < 100; i++) {
            NSString *imageName = (i / 10) ? [NSString stringWithFormat:@"livewave-%d.png", i > 49 ? 49 : i] : [NSString stringWithFormat:@"livewave-0%d.png", i];
            [animations addObject:[UIImage imageNamed:imageName]];
        }
        self.waveAnimationImageView = [[[UIImageView alloc] initWithFrame:(CGRect){{4, 0}, {22, 22}}] autorelease];
        self.waveAnimationImageView.animationImages = animations;
        self.waveAnimationImageView.animationDuration = 2.0f;
        self.waveAnimationImageView.backgroundColor = [UIColor clearColor];
        self.waveAnimationImageView.layer.cornerRadius = 3.0f;
        self.waveAnimationImageView.layer.masksToBounds = YES;
        [self.waveAnimationImageView startAnimating];
        [animations release];
        
        [_littleArrowView addSubview:self.waveAnimationImageView];
        
        // tipView
        UIView *tipView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, {300, 120}}];
        tipView.backgroundColor = [UIColor clearColor];
        
        CGSize shadowOffset = (CGSize){0, -1};
        UIColor *shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        
        UILabel *tipTitleLabel = [[UILabel alloc] initWithFrame:(CGRect){{0, 10}, {300, 40}}];
        tipTitleLabel.textColor = [UIColor whiteColor];
        tipTitleLabel.textAlignment = NSTextAlignmentCenter;
        tipTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        tipTitleLabel.backgroundColor = [UIColor clearColor];
        tipTitleLabel.shadowOffset = shadowOffset;
        tipTitleLabel.shadowColor = shadowColor;
        tipTitleLabel.text = @"Gather people nearby";
        [tipView addSubview:tipTitleLabel];
        [tipTitleLabel release];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{0, 44}, {300, 21}}];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.shadowOffset = shadowOffset;
        tipLabel.shadowColor = shadowColor;
        tipLabel.text = @"Close two phones together to capture";
        [tipView addSubview:tipLabel];
        [tipLabel release];
        
        tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{0, 62}, {300, 21}}];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.shadowOffset = shadowOffset;
        tipLabel.shadowColor = shadowColor;
        tipLabel.text = @"people using             . For those accessing";
        [tipView addSubview:tipLabel];
        [tipLabel release];
        
        tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{104, 62}, {90, 22}}];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        tipLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.shadowOffset = shadowOffset;
        tipLabel.shadowColor = shadowColor;
        tipLabel.text = @"Live ·X·";
        [tipView addSubview:tipLabel];
        [tipLabel release];
        
        tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{40, 81}, {90, 22}}];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        tipLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.shadowOffset = shadowOffset;
        tipLabel.shadowColor = shadowColor;
        tipLabel.text = @"exfe.com";
        [tipView addSubview:tipLabel];
        [tipLabel release];
        
        tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{26, 80}, {300, 21}}];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"   , max their speaker volume.";
        [tipView addSubview:tipLabel];
        [tipLabel release];
        
        _arrowView = [[EXArrowView alloc] initWithFrame:(CGRect){{10, 38}, {300, 120}}];
        [_arrowView setPointPosition:(CGPoint){CGRectGetMidX(self.bounds) - 10, CGRectGetMidY(self.bounds)} andArrowDirection:kEXArrowDirectionUp];
        _arrowView.gradientColors = @[(id)[UIColor COLOR_RGB(0x36, 0x9F, 0xE9)].CGColor, (id)[UIColor COLOR_RGB(0x23, 0x55, 0x8C)].CGColor];
        _arrowView.strokeColor = [UIColor COLOR_RGBA(0x36, 0x9F, 0xE9, 178.0f)];
        _arrowView.alpha = 0.92f;
        [_arrowView setNeedsDisplay];
        
        [_arrowView addSubview:tipView];
        self.tipView = tipView;
        
        CATransform3D scaleTransform3D = CATransform3DMakeScale(0.073f, 0.25f, 1.0f);
        CATransform3D rotationTransform3D = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
        CATransform3D transform = CATransform3DConcat(scaleTransform3D, rotationTransform3D);
        CATransform3D translateTransform3D = CATransform3DMakeTranslation(37, -64, 0.0f);
        transform = CATransform3DConcat(transform, translateTransform3D);
        _arrowView.layer.transform = transform;
        
        self.tipView.alpha = 0.0f;
        _arrowView.alpha = 0.0f;
        
        [self addSubview:_arrowView];
        
        [self bringSubviewToFront:self.titleControl];
        
        self.isTipViewPresented = NO;
    }
    
    return self;
}

- (void)dealloc {
    [_innerWindow release];
    [_arrowView release];
    [_backButton release];
    [_gatherButton release];
    if (_waveAnimationImageView) {
        [_waveAnimationImageView stopAnimating];
        [_waveAnimationImageView release];
    }
    [_littleArrowView release];
    [_titleControl release];
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
    self.innerWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    [self.innerWindow addGestureRecognizer:tap];
    self.innerWindow.backgroundColor = [UIColor clearColor];
    [tap release];
    
    [self.innerWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.05f
                     animations:^{
                         _littleArrowView.alpha = 0.0f;
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
                                              self.tipView.alpha = 1.0f;
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
                         self.tipView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self.waveAnimationImageView startAnimating];
                         [UIView animateWithDuration:0.05f
                                          animations:^{
                                              _littleArrowView.alpha = 1.0f;
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
