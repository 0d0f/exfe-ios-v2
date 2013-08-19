//
//  EFGeomarkGroupViewController.m
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import "EFGeomarkGroupViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "EFGeomarkLocationCell.h"
#import "EFGeomarkPersonCell.h"
#import "Util.h"

@interface EFGeomarkGoupBackgroundView : UIView

@end

@implementation EFGeomarkGoupBackgroundView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = NULL;
    NSArray *colors = @[(id)[UIColor COLOR_RGB(0xFA, 0xFA, 0xFA)].CGColor,
                        (id)[UIColor COLOR_RGB(0xEA, 0xEA, 0xEA)].CGColor];
    CGFloat gradientLocations[] = {0, 1};
    gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, gradientLocations);
    
    CGContextDrawLinearGradient(context, gradient, (CGPoint){CGRectGetWidth(self.frame) * 0.5f, 0.0f}, (CGPoint){CGRectGetWidth(self.frame) * 0.5f, CGRectGetHeight(self.frame)}, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end

@interface EFGeomarkGroupViewController ()

@property (nonatomic, weak)   UIViewController    *fromViewController;    // rewrite
@property (nonatomic, assign) CGPoint             tapLocation;            // rewrite

@property (nonatomic, strong) UIView              *baseView;
@property (nonatomic, strong) CALayer             *shadowLayer;

@end

@interface EFGeomarkGroupViewController (Private)

- (CGPoint)_fixTapLocation:(CGPoint)location;

@end

@implementation EFGeomarkGroupViewController (Private)

- (CGPoint)_fixTapLocation:(CGPoint)location {
    CGRect baseViewBounds = self.baseView.bounds;
    CGRect viewFrame = self.view.frame;
    CGFloat viewHalfWidth = CGRectGetWidth(viewFrame) * 0.5f;
    CGFloat viewHalfHeight = CGRectGetHeight(viewFrame) * 0.5f;
    
    CGFloat blank = 5.0f;
    
    if (location.x - viewHalfWidth < blank) {
        location.x = viewHalfWidth + blank;
    } else if (location.x + viewHalfWidth > CGRectGetWidth(baseViewBounds)) {
        location.x = CGRectGetWidth(baseViewBounds) - (viewHalfWidth + blank);
    }
    
    if (location .y - viewHalfHeight < blank) {
        location.y = viewHalfHeight + blank;
    } else if (location.y + viewHalfHeight > CGRectGetHeight(baseViewBounds)) {
        location.y = viewHalfHeight + blank;
    }
    
    return location;
}

@end

@implementation EFGeomarkGroupViewController

- (id)initWithGeomarks:(NSArray *)geomarks andPeople:(NSArray *)people {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.geomarks = geomarks;
        self.people = people;
        
        self.view.frame = (CGRect){CGPointZero, {200.0f, 132.0f}};
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EFGeomarkGoupBackgroundView *backgroudnView = [[EFGeomarkGoupBackgroundView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundView = backgroudnView;
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
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

#pragma mark - Public

- (void)presentFromViewController:(UIViewController *)controller tapLocation:(CGPoint)locatoin animated:(BOOL)animated {
    self.fromViewController = controller;
    self.tapLocation = locatoin;
    
    // base view
    CGRect frame = [controller.view.window convertRect:controller.view.frame fromView:controller.view.superview];
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [controller.view.window addSubview:baseView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [baseView addGestureRecognizer:tap];
    
    self.baseView = baseView;
    
    CGPoint fixedLocation = [self _fixTapLocation:locatoin];
    
    self.shadowLayer.position = fixedLocation;
    self.shadowLayer.bounds = self.view.bounds;
    [self.baseView.layer addSublayer:self.shadowLayer];
    
    self.view.center = fixedLocation;
    [self.baseView addSubview:self.view];
}

- (void)dismissAnimated:(BOOL)animated {
    [self.shadowLayer removeFromSuperlayer];
    self.shadowLayer = nil;
    [self.baseView removeFromSuperview];
    self.baseView = nil;
    [self.view removeFromSuperview];
}

#pragma mark - Gesture

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self dismissAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.baseView];
    if (CGRectContainsPoint(self.view.frame, location)) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.section) {
        // route location
        EFRouteLocation *routeLocation = self.geomarks[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(geomarkGroupViewController:didSelectRouteLocation:)]) {
            [self.delegate geomarkGroupViewController:self didSelectRouteLocation:routeLocation];
        }
    } else {
        // person
        EFMapPerson *person = self.people[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(geomarkGroupViewController:didSelectPerson:)]) {
            [self.delegate geomarkGroupViewController:self didSelectPerson:person];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return self.geomarks.count;
    } else {
        return self.people.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        NSString *Identiter = @"GeomarksCell";
        EFGeomarkLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:Identiter];
        if (nil == cell) {
            cell = [[EFGeomarkLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identiter];
        }
        
        EFRouteLocation *location = self.geomarks[indexPath.row];
        cell.routeLocation = location;
        
        return cell;
    } else {
        NSString *Identiter = @"PersonCell";
        EFGeomarkPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:Identiter];
        if (nil == cell) {
            cell = [[EFGeomarkPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identiter];
        }
        
        EFMapPerson *person = self.people[indexPath.row];
        cell.person = person;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

@end
