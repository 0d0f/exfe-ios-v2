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
    CGRect a = [UIScreen mainScreen].applicationFrame;
    
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88 + 20)];
    header.backgroundColor = [UIColor grayColor];
    [self.view addSubview:header];
    [header release];
    
    UIScrollView* container = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 88, 320, CGRectGetHeight(a) - 88)];
    container.alwaysBounceVertical = YES;
    container.backgroundColor = [UIColor clearColor];
    
    UIView* sample = [[UIView alloc] initWithFrame:container.bounds];
    sample.backgroundColor = [UIColor redColor];
    [container addSubview:sample];
    [sample release];
    
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
