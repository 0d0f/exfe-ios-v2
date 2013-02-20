//
//  CrossGroupViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import "CrossGroupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "Cross.h"


#define DECTOR_HEIGHT                    (88)

#define kViewTagBack                     (0140000)

@interface CrossGroupViewController ()

@end

@implementation CrossGroupViewController
@synthesize cross = _cross;
@synthesize currentViewController = _currentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect b = self.view.bounds;
    
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88)];
    header.backgroundColor = [UIColor grayColor];
    [self.view addSubview:header];
    [header release];
    
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 88, 320, CGRectGetHeight(b) - 88)];
    container.backgroundColor = [UIColor lightGrayColor];
    CGRect bounds = container.bounds;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *curvePath = [UIBezierPath bezierPath];
    [curvePath moveToPoint:CGPointMake(0, 0)];
    [curvePath addLineToPoint:CGPointMake(0, CGRectGetMaxY(bounds))];
    [curvePath addLineToPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))];
    [curvePath addLineToPoint:CGPointMake(CGRectGetMaxX(bounds), 15)];
    [curvePath addLineToPoint:CGPointMake(CGRectGetMaxX(bounds) - 12, 15)];
    [curvePath addCurveToPoint:CGPointMake(CGRectGetMaxX(bounds) - 90, 0) controlPoint1:CGPointMake(CGRectGetMaxX(bounds) - 90 + 32, 15) controlPoint2:CGPointMake(CGRectGetMaxX(bounds) - 12 - 32, 0)];
    //[curvePath addLineToPoint:CGPointMake(CGRectGetMaxX(bounds) - 90, 0)];
    [curvePath closePath];
    maskLayer.path = [curvePath CGPath];
    container.layer.mask = maskLayer;
    container.layer.masksToBounds = YES;
    [self.view addSubview:container];
    [container release];
    
    UIButton* btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_GR(0x33)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.tag = kViewTagBack;
    [self.view  addSubview:btnBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Navigation
- (void) goBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark selector for button
- (void)gotoBack:(id)sender{
    [self goBack];
}

-(void)swapViewControllers:childViewController{
    //UIViewController *aNewViewController = [[UIViewController alloc] initWithNibName:@"childViewController" bundle:nil] ;
    
    
    //[aNewViewController.view layoutIfNeeded];
    // Custom new view controller UI;
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:childViewController];
    
    __weak __block CrossGroupViewController *weakSelf=self;
    [self transitionFromViewController:self.currentViewController
                      toViewController:childViewController
                              duration:1.0
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:nil
                            completion:^(BOOL finished) {
                                
                                [weakSelf.currentViewController removeFromParentViewController];
                                [childViewController didMoveToParentViewController:weakSelf];
                                
                                weakSelf.currentViewController = [childViewController autorelease];
                            }];
}

@end
