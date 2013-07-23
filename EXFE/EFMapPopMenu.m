//
//  EFMapPopMenu.m
//  EXFE
//
//  Created by 0day on 13-7-23.
//
//

#import "EFMapPopMenu.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@interface EFMapPopMenu ()

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *stateLabel;
@property (nonatomic, weak) UILabel *destinationDistanceLabel;
@property (nonatomic, weak) UILabel *yourDistanceLabel;
@property (nonatomic, weak) UIButton *requestButton;

@property (nonatomic, weak) UIView  *baseView;

@end

@implementation EFMapPopMenu

- (id)initWithName:(NSString *)name
     pressedHanler:(ButtonPressedHandler)handler {
    self = [super init];
    if (self) {
        self.frame = (CGRect){CGPointZero, {200.0f, 125.0f}};
        self.backgroundColor = [UIColor COLOR_RGB(0xEA, 0xEA, 0xEA)];
        self.layer.cornerRadius = 4.0f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOpacity = 0.6f;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(id)[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)].CGColor,
                                 (id)[UIColor COLOR_RGB(0xEA, 0xEA, 0xEA)].CGColor];
        gradientLayer.cornerRadius = 4.0f;
        gradientLayer.frame = self.layer.bounds;
        [self.layer addSublayer:gradientLayer];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {200.0f, 60}}];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.shadowColor = [UIColor whiteColor];
        nameLabel.shadowOffset = (CGSize){0.0f, 1.0f};
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        self.nameLabel.text = name;
        
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 80.0f}, {200.0f, 0.5f}}];
        lineView.backgroundColor = [UIColor COLOR_RGB(0xCC, 0xCC, 0xCC)];
        lineView.layer.shadowColor = [UIColor whiteColor].CGColor;
        lineView.layer.shadowOffset = (CGSize){0.0f, 0.5f};
        [self addSubview:lineView];
        
        self.requestButtonPressedHandler = handler;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"请对方更新方位" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor COLOR_RGB(0, 0x7C, 0xFF)] forState:UIControlStateNormal];
        button.frame = (CGRect){{0.0f, 80.0f}, {200.0f, 45.0f}};
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.requestButton = button;
    }
    
    return self;
}

- (void)buttonPressed:(id)sender {
    if (_requestButtonPressedHandler) {
        self.requestButtonPressedHandler(self);
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    [self dismiss];
}

- (void)show {
    if (!self.baseView) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        UIView *baseView = [[UIView alloc] initWithFrame:rootView.bounds];
        [baseView addGestureRecognizer:tap];
        baseView.backgroundColor = [UIColor clearColor];
        [rootView addSubview:baseView];
        self.baseView = baseView;
    }
    self.center = (CGPoint){CGRectGetMidX(self.baseView.frame), CGRectGetMidY(self.baseView.frame)};
    
    [self.baseView addSubview:self];
}

- (void)dismiss {
    [self.baseView removeFromSuperview];
    self.baseView = nil;
    
    [self removeFromSuperview];
}

@end
