//
//  EFMapPersonViewController.m
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import "EFMapPersonViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "EFMapPerson.h"
#import "EFGradientView.h"
#import "Util.h"

@interface EFMapPersonViewController ()

@property (nonatomic, strong) UIControl         *baseView;
@property (nonatomic, strong) EFGradientView    *backgroundView;
@property (nonatomic, strong) UIView            *lineView;

@property (nonatomic, strong) UILabel           *nameLabel;
@property (nonatomic, strong) UILabel           *updateDateLabel;
@property (nonatomic, strong) UILabel           *destDistanceLabel;
@property (nonatomic, strong) UILabel           *meDistanceLabel;

@end

@interface EFMapPersonViewController (Private)

- (void)_initLabels;
- (void)_layoutSubviews;
- (void)_personDidChange;

@end

@implementation EFMapPersonViewController (Private)

- (void)_initLabels {

}

- (void)_layoutSubviews {
    
}

- (void)_personDidChange {
    [self _layoutSubviews];
}

@end

@implementation EFMapPersonViewController

- (id)initWithMe:(EFMapPerson *)me person:(EFMapPerson *)person {
    self = [super init];
    if (self) {
        self.me = me;
        self.person = person;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // background view
    EFGradientView *backgroundView = [[EFGradientView alloc] initWithFrame:self.view.bounds];
    backgroundView.colors = @[[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)],
                              [UIColor COLOR_RGB(0xEA, 0xEA, 0xEA)]];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backgroundView];
    self.backgroundView = backgroundView;
    
    // line
    UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {CGRectGetWidth(self.view.bounds), 0.5f}}];
    lineView.backgroundColor = [UIColor COLOR_RGB(0xCC, 0xCC, 0xCC)];
    lineView.layer.shadowOffset = (CGSize){0.0f, 0.5f};
    lineView.layer.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.66f].CGColor;
    lineView.layer.shadowOpacity = 1.0f;
    lineView.layer.shadowRadius = 1.0f;
    lineView.hidden = YES;
    [self.view addSubview:lineView];
    self.lineView = lineView;
    
    [self _initLabels];
}

#pragma mark - Control

#pragma mark - Public

- (void)presentFromViewController:(UIViewController *)controller location:(CGPoint)location animated:(BOOL)animated {
    self.fromController = controller;
    self.location = location;
}

- (void)dismissAnimated:(BOOL)animated {
    
}

@end
