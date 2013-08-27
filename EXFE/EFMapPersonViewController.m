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
#import "EFLocation.h"
#import "NSDate+RouteXDateFormater.h"
#import "EFMarauderMapDataSource.h"

#define kDefaultWidth       (200.0f)
#define kDistanceWidth      (150.0f)
#define kDistanceInfoWidth  (50.0f)

@interface EFMapPersonViewController ()

@property (nonatomic, strong) UIControl         *baseView;
@property (nonatomic, strong) CALayer           *shadowLayer;
@property (nonatomic, strong) EFGradientView    *backgroundView;
@property (nonatomic, strong) UIView            *lineView;

@property (nonatomic, strong) UILabel           *nameLabel;
@property (nonatomic, strong) UILabel           *personInfoLabel;
@property (nonatomic, strong) UILabel           *destDistanceLabel;
@property (nonatomic, strong) UILabel           *destDistanceInfoLabel;
@property (nonatomic, strong) UILabel           *meDistanceLabel;
@property (nonatomic, strong) UILabel           *meDistanceInfoLabel;
@property (nonatomic, strong) UIButton          *requestButton;
@property (nonatomic, strong) UIImageView       *destHeadingView;
@property (nonatomic, strong) UIImageView       *meHeadingView;

@end

@interface EFMapPersonViewController (Private)

- (void)_initLabels;
- (void)_personDidChange;

@end

@implementation EFMapPersonViewController (Private)

- (void)_initLabels {
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {200.0f, 25.0f}}];
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    nameLabel.textColor = [UIColor COLOR_BLACK_19];
    nameLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    nameLabel.shadowOffset = (CGSize){0.0f, 0.5f};
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *personInfoLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {200.0f, 10.0f}}];
    personInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
    personInfoLabel.textColor = [UIColor COLOR_CARBON];
    personInfoLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    personInfoLabel.shadowOffset = (CGSize){0.0f, 0.5f};
    personInfoLabel.backgroundColor = [UIColor clearColor];
    personInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:personInfoLabel];
    self.personInfoLabel = personInfoLabel;
    
    UILabel *destDistanceLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {kDistanceWidth, 17.0f}}];
    destDistanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    destDistanceLabel.textColor = [UIColor COLOR_BLACK_19];
    destDistanceLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    destDistanceLabel.shadowOffset = (CGSize){0.0f, 0.5f};
    destDistanceLabel.backgroundColor = [UIColor clearColor];
    destDistanceLabel.textAlignment = NSTextAlignmentRight;
    destDistanceLabel.text = NSLocalizedString(@"至目的地", nil);
    [self.view addSubview:destDistanceLabel];
    self.destDistanceLabel = destDistanceLabel;
    
    UILabel *destDistanceInfoLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {kDistanceInfoWidth, 17.0f}}];;
    destDistanceInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    destDistanceInfoLabel.textColor = [UIColor COLOR_BLACK_19];
    destDistanceInfoLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    destDistanceInfoLabel.shadowOffset = (CGSize){0.0f, 0.5f};
    destDistanceInfoLabel.backgroundColor = [UIColor clearColor];
    destDistanceInfoLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:destDistanceInfoLabel];
    self.destDistanceInfoLabel = destDistanceInfoLabel;
    
    UIImageView *destHeadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_14g5.png"]];
    [self.view addSubview:destHeadingView];
    self.destHeadingView = destHeadingView;
    
    UILabel *meDistanceLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {kDistanceWidth, 17.0f}}];
    meDistanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    meDistanceLabel.textColor = [UIColor COLOR_BLACK_19];
    meDistanceLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    meDistanceLabel.shadowOffset = (CGSize){0.0f, 0.5f};
    meDistanceLabel.backgroundColor = [UIColor clearColor];
    meDistanceLabel.textAlignment = NSTextAlignmentRight;
    meDistanceLabel.text = NSLocalizedString(@"距您的位置", nil);
    [self.view addSubview:meDistanceLabel];
    self.meDistanceLabel = meDistanceLabel;
    
    UILabel *meDistanceInfoLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {kDistanceInfoWidth, 17.0f}}];
    meDistanceInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    meDistanceInfoLabel.textColor = [UIColor COLOR_BLACK_19];
    meDistanceInfoLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    meDistanceInfoLabel.shadowOffset = (CGSize){0.0f, 0.5f};
    meDistanceInfoLabel.backgroundColor = [UIColor clearColor];
    meDistanceInfoLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:meDistanceInfoLabel];
    self.meDistanceInfoLabel = meDistanceInfoLabel;
    
    UIImageView *meHeadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_14g5.png"]];
    [self.view addSubview:meHeadingView];
    self.meHeadingView = meHeadingView;
    
    UIButton *requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [requestButton setTitle:NSLocalizedString(@"请对方更新方位", nil) forState:UIControlStateNormal];
    [requestButton setTitleColor:[UIColor COLOR_RGB(0x00, 0x7C, 0xFF)] forState:UIControlStateNormal];
    requestButton.frame = (CGRect){CGPointZero, {200.0f, 50.0f}};
    [requestButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.75f] forState:UIControlStateNormal];
    [requestButton addTarget:self
                      action:@selector(sendRequestButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestButton];
    self.requestButton = requestButton;
}

- (void)_personDidChange {
    CGFloat height = 0.0f;
    
    // update name
    self.nameLabel.text = self.person.name;
    
    height += CGRectGetHeight(self.nameLabel.frame);
    CGFloat offsetY = -6.0f;
    
    self.nameLabel.center = (CGPoint){kDefaultWidth * 0.5f, height + offsetY};
    
    NSString *personInfo = nil;
    NSString *destDistanceInfo = nil;
    NSString *meDistanceInfo = nil;
    CGFloat destRadian = 0.0f;
    CGFloat meRadian = 0.0f;
    
    EFRouteLocation *destination = self.mapDataSource.destinationLocation;
    
    if (self.person.lastLocation) {
        // update person info
        if (kEFMapPersonConnectStateOnline == self.person.connectState) {
            personInfo = NSLocalizedString(@"当前所处方位", nil);
        } else {
            NSString *timeInterval = [self.person.lastLocation.timestamp formatedTimeIntervalFromNow];
            personInfo = [NSString stringWithFormat:NSLocalizedString(@"%@所处方位", nil), timeInterval];
        }
        
        // update destination distance info
        if (destination) {
            CLLocationDistance distanceFromDest = ceil([[self.mapDataSource me].lastLocation distanceFromRouteLocation:destination]);
            NSString *unit = NSLocalizedString(@"米", nil);
            
            if (distanceFromDest > 1000.0f) {
                distanceFromDest = ceil(distanceFromDest / 1000.0f);
                unit = NSLocalizedString(@"公里", nil);
            }
            destDistanceInfo = [NSString stringWithFormat:@"%ld%@", (long)distanceFromDest, unit];
            
            destRadian = HeadingInRadian(destination.coordinate, self.person.lastLocation.coordinate);
        }
        
        // update me distance info
        if ([self.mapDataSource me].lastLocation) {
            CLLocationDistance distanceFromMe = ceil([self.person.lastLocation distanceFromLocation:[self.mapDataSource me].lastLocation]);
            NSString *unit = NSLocalizedString(@"米", nil);
            
            if (distanceFromMe > 1000.0f) {
                distanceFromMe = ceil(distanceFromMe / 1000.0f);
                unit = NSLocalizedString(@"公里", nil);
            }
            meDistanceInfo = [NSString stringWithFormat:@"%ld%@", (long)distanceFromMe, unit];
            
            meRadian = HeadingInRadian([self.mapDataSource me].lastLocation.coordinate, self.person.lastLocation.coordinate);
        }
    } else {
        personInfo = NSLocalizedString(@"方位未知", nil);
    }
    
    self.personInfoLabel.text = personInfo;
    height += CGRectGetHeight(self.personInfoLabel.frame);
    self.personInfoLabel.center = (CGPoint){kDefaultWidth * 0.5f, height + 0.74f * CGRectGetHeight(self.personInfoLabel.frame) + offsetY};
    
    height += 7.0f;
    
    if (destDistanceInfo) {
        height += CGRectGetHeight(self.destDistanceLabel.frame);
        self.destDistanceLabel.center = (CGPoint){kDistanceWidth * 0.2f, height + offsetY};
        self.destDistanceLabel.hidden = NO;
        
        self.destDistanceInfoLabel.text = destDistanceInfo;
        [self.destDistanceInfoLabel sizeToFit];
        self.destDistanceInfoLabel.center = (CGPoint){CGRectGetMaxX(self.destDistanceLabel.frame) + CGRectGetWidth(self.destDistanceInfoLabel.frame) * 0.5f + 4.0f, height + offsetY};
        self.destDistanceInfoLabel.hidden = NO;
        
        self.destHeadingView.center = (CGPoint){CGRectGetMaxX(self.destDistanceInfoLabel.frame) + 6.0f, height + offsetY};
        self.destHeadingView.layer.transform = CATransform3DMakeRotation(destRadian, 0.0f, 0.0f, 1.0f);
        self.destHeadingView.hidden = NO;
    } else {
        self.destDistanceLabel.hidden = YES;
        self.destDistanceInfoLabel.hidden = YES;
        self.destHeadingView.hidden = YES;
    }
    
    if (meDistanceInfo) {
        height += CGRectGetHeight(self.meDistanceLabel.frame);
        self.meDistanceLabel.center = (CGPoint){kDistanceWidth * 0.2f, height + offsetY};
        self.meDistanceLabel.hidden = NO;
        
        self.meDistanceInfoLabel.text = meDistanceInfo;
        [self.meDistanceInfoLabel sizeToFit];
        self.meDistanceInfoLabel.center = (CGPoint){CGRectGetMaxX(self.meDistanceLabel.frame) + CGRectGetWidth(self.meDistanceInfoLabel.frame) * 0.5f + 4.0f, height + offsetY};
        self.meDistanceInfoLabel.hidden = NO;
        
        self.meHeadingView.center = (CGPoint){CGRectGetMaxX(self.meDistanceInfoLabel.frame) + 6.0f, height + offsetY};
        self.meHeadingView.layer.transform = CATransform3DMakeRotation(meRadian, 0.0f, 0.0f, 1.0f);
        self.meHeadingView.hidden = NO;
    } else {
        self.meDistanceLabel.hidden = YES;
        self.meDistanceInfoLabel.hidden = YES;
        self.meHeadingView.hidden = YES;
    }
    
    if (kEFMapPersonConnectStateOnline == self.person.connectState) {
        height += CGRectGetHeight(self.meDistanceLabel.frame) * 0.5f;
        self.requestButton.hidden = YES;
        self.lineView.hidden = YES;
    } else {
        height += CGRectGetHeight(self.requestButton.frame);
        self.requestButton.center = (CGPoint){kDefaultWidth * 0.5f, height - CGRectGetHeight(self.requestButton.frame) * 0.45f};
        self.requestButton.hidden = NO;
        
        self.lineView.center = (CGPoint){kDefaultWidth * 0.5f, height - CGRectGetHeight(self.requestButton.frame) * 0.9f};
        self.lineView.hidden = NO;
    }
    
    CGRect frame = (CGRect){CGPointZero, {kDefaultWidth, height}};
    self.view.frame = frame;
    
    self.backgroundView.frame = frame;
    [self.backgroundView setNeedsDisplay];
}

@end

@implementation EFMapPersonViewController

- (id)initWithDataSource:(EFMarauderMapDataSource *)dataSource person:(EFMapPerson *)person {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
        [self _initLabels];
        
        self.mapDataSource = dataSource;
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
    
    self.view.layer.cornerRadius = 4.0f;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderColor = [UIColor whiteColor].CGColor;
    self.view.layer.borderWidth = 0.5f;
    
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.backgroundColor = [UIColor grayColor].CGColor;
    shadowLayer.cornerRadius = 4.0f;
    shadowLayer.masksToBounds = NO;
    shadowLayer.bounds = self.view.bounds;
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOffset = (CGSize){0.0f, 1.0f};
    shadowLayer.shadowOpacity = 0.66f;
    shadowLayer.shadowRadius = 2.0f;
    self.shadowLayer = shadowLayer;
}

#pragma mark - Property Accosser

- (void)setPerson:(EFMapPerson *)person {
    [self willChangeValueForKey:@"person"];
    
    _person = person;
    [self _personDidChange];
    
    [self didChangeValueForKey:@"person"];
}

#pragma mark - Touch Event Handler

- (void)handleTouchDownEvent:(id)sender {
    [self dismissAnimated:YES];
}

- (void)sendRequestButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mapPersonViewControllerRequestButtonPressed:)]) {
        [self.delegate mapPersonViewControllerRequestButtonPressed:self];
    }
}

#pragma mark - Public

- (void)presentFromViewController:(UIViewController *)controller location:(CGPoint)location animated:(BOOL)animated {
    self.fromController = controller;
    self.location = location;
    
    // base view
    CGRect frame = [controller.view.window convertRect:controller.view.frame fromView:controller.view.superview];
    UIControl *baseView = [[UIControl alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self
                 action:@selector(handleTouchDownEvent:)
       forControlEvents:UIControlEventTouchDown];
    
    [controller.view.window addSubview:baseView];
    
    self.baseView = baseView;
    
    self.shadowLayer.position = location;
    self.shadowLayer.bounds = self.view.bounds;
    [self.baseView.layer addSublayer:self.shadowLayer];
    
    self.view.center = location;
    [self.baseView addSubview:self.view];

}

- (void)dismissAnimated:(BOOL)animated {
    [self.shadowLayer removeFromSuperlayer];
    self.shadowLayer = nil;
    [self.baseView removeFromSuperview];
    self.baseView = nil;
    [self.view removeFromSuperview];
}

@end
