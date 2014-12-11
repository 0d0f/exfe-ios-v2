//
//  EFRouteXAccessViewController.m
//  EXFE
//
//  Created by 0day on 13-8-30.
//
//

#import "EFRouteXAccessViewController.h"

@interface EFRouteXAccessViewController ()

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, assign) CGRect    viewFrame;
@property (nonatomic, strong) UILabel   *titleLabel;
@property (nonatomic, strong) UILabel   *para1Label;
@property (nonatomic, strong) UILabel   *para2Label;
@property (nonatomic, strong) UILabel   *buttonTipLabel;
@property (nonatomic, strong) UIButton  *button;

@end

@implementation EFRouteXAccessViewController

- (void)_initSubviews {
    CGRect viewBounds = self.viewFrame;
    
    CGRect scrollViewFrame = (CGRect){CGPointZero, viewBounds.size};
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    scrollView.contentSize = (CGSize){CGRectGetWidth(scrollViewFrame), 488.0f};
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 35.0f}, {CGRectGetWidth(viewBounds), 27.0f}}];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
    titleLabel.shadowOffset = (CGSize){0.0f, 1.0f};
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = NSLocalizedString(@"It’s all about privacy", nil);
    [scrollView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *para1Label = [[UILabel alloc] initWithFrame:(CGRect){{20.0f, 80.0f}, {CGRectGetWidth(viewBounds) - 40.0f, 160.0f}}];
    para1Label.textAlignment = NSTextAlignmentLeft;
    para1Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    para1Label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
    para1Label.shadowOffset = (CGSize){0.0f, 1.0f};
    para1Label.backgroundColor = [UIColor clearColor];
    para1Label.textColor = [UIColor whiteColor];
    para1Label.numberOfLines = 7;
    para1Label.text = [NSString stringWithFormat:NSLocalizedString(@"You just rejected the RouteX page: %@. It will NOT reveal your location, nor you could see others’. While those pages you have open and agreed still do. Every RouteX page follows your location privacy setting individually.", nil), self.crossTitle];
    [scrollView addSubview:para1Label];
    self.para1Label = para1Label;
    
    UILabel *para2Label = [[UILabel alloc] initWithFrame:(CGRect){{20.0f, 240.0f}, {CGRectGetWidth(viewBounds) - 40.0f, 100.0f}}];
    para2Label.textAlignment = NSTextAlignmentLeft;
    para2Label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    para2Label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
    para2Label.shadowOffset = (CGSize){0.0f, 1.0f};
    para2Label.backgroundColor = [UIColor clearColor];
    para2Label.textColor = [UIColor whiteColor];
    para2Label.numberOfLines = 3;
    para2Label.text = NSLocalizedString(@"Utilities know your location like RouteX should respect the strictest standard of privacy and security. We care and pay much attention to it.", nil);
    [scrollView addSubview:para2Label];
    self.para2Label = para2Label;
    
    UILabel *buttonTipLabel = [[UILabel alloc] initWithFrame:(CGRect){{20.0f, 374.0f}, {CGRectGetWidth(viewBounds) - 40.0f, 27.0f}}];
    buttonTipLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    buttonTipLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
    buttonTipLabel.shadowOffset = (CGSize){0.0f, 1.0f};
    buttonTipLabel.backgroundColor = [UIColor clearColor];
    buttonTipLabel.textColor = [UIColor whiteColor];
    buttonTipLabel.text = NSLocalizedString(@"Want to see location with friends?", nil);
    [scrollView addSubview:buttonTipLabel];
    self.buttonTipLabel = buttonTipLabel;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){{20.0f, 400.0f}, {CGRectGetWidth(viewBounds) - 40.0f, 48.0f}};
    UIImage *backgroundImage = [UIImage imageNamed:@"btn_white_44.png"];
    backgroundImage = [backgroundImage resizableImageWithCapInsets:(UIEdgeInsets){0.0f, 10.0f, 0.0f, 10.0f}];
    [button setTitle:NSLocalizedString(@"Open this RouteX page", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.66f] forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button];
    self.button = button;
}

- (id)initWithViewFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.viewFrame = frame;
        self.view.frame = frame;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.85f];
    [self _initSubviews];
}

#pragma mark -
#pragma mark Property Accessor

- (void)setCrossTitle:(NSString *)crossTitle {
    [self willChangeValueForKey:@"crossTitle"];
    
    _crossTitle = crossTitle;
    self.para1Label.text = [NSString stringWithFormat:NSLocalizedString(@"You just rejected the RouteX page: %@. It will NOT reveal your location, nor you could see others’. While those pages you have open and agreed still do. Every RouteX page follows your location privacy setting individually.", nil), crossTitle];
    
    [self didChangeValueForKey:@"crossTitle"];
}

#pragma mark -
#pragma mark Action

- (void)buttonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(routeXAccessViewControllerButtonPressed:)]) {
        [self.delegate routeXAccessViewControllerButtonPressed:self];
    }
}

@end
