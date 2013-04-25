//
//  EFLandingViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import "EFLandingViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "EFSignInViewController.h"

@interface EFLandingViewController (){

    BOOL firstLoad;
    UIGestureRecognizer * tapBack;
}
@end

@implementation EFLandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        firstLoad = YES;
        self.labelEXFE.hidden = YES;
        self.labelDescription.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // Do any additional setup after loading the view from its nib.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.view setFrame:appFrame];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg.png"]];
    self.labelStart.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bar.png"]];
    self.imgHead.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_bg.png"]];
    
    UITapGestureRecognizer *tapStart = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [self swapChildViewController:1 param:nil];
    }];
    [_labelStart addGestureRecognizer:tapStart];
    
    tapBack = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (self.currentViewController != nil) {
            [self.view endEditing:YES];
            [self performBlock:^(id sender) {
                [self swapChildViewController:0 param:nil];
            } afterDelay:0.233];
        }
    }];
    [self.imgHead addGestureRecognizer:tapBack];
    self.imgHead.hidden = YES;
    self.imgHead.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if (_labelEXFE.hidden) {
        _labelEXFE.hidden = NO;
    }
    if (_labelDescription.hidden) {
        _labelDescription.hidden = NO;
    }
    if (firstLoad) {
        firstLoad = NO;
    
        _labelEXFE.alpha = 0;
        _labelDescription.alpha = 0;
        CGRect frame = self.labelStart.frame;
        CGRect newF = frame;
        newF.origin.y = appFrame.size.height;
        self.labelStart.frame = newF;
        
        CGRect logo_frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) == 568 ? 150 : 110, 320, 300);
        _imgEXFELogo.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) == 568 ? 67 : 64, 320, 300);
        
        [UIView animateWithDuration:1.6 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
            _imgEXFELogo.frame = logo_frame;
        } completion:^(BOOL finished) {
            
        }];
        
        [UIView animateWithDuration:1 delay:0.8 options:UIViewAnimationOptionTransitionNone animations:^{
            _labelEXFE.alpha = 100;
            _labelDescription.alpha = 100;
            _labelStart.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)swapChildViewController:(NSInteger)widget_id param:(NSDictionary*)params{
    
    UIViewController *newVC = nil;
    switch (widget_id) {
        case 1:
        {
            EFSignInViewController *viewController = [[EFSignInViewController alloc] initWithNibName:@"EFSignInViewController" bundle:nil];
            if (params) {
                
            }
            viewController.onExitBlock = ^{
                ;
            };
            
            newVC = viewController;
        }
            
        default:
            
            
            
            break;
    }
    
    CGRect newFrame = CGRectZero;
    
    if (newVC) {
        [self addChildViewController:newVC];
        [self.view insertSubview:newVC.view aboveSubview:_labelStart];
        newFrame = newVC.view.frame;
        CGRect f = newVC.view.frame;
        f.origin.y = CGRectGetMaxY(_labelStart.frame);
        newVC.view.frame = f;
    } else {
        
    }
    
    
    
    __weak __block EFLandingViewController *weakSelf = self;
    [UIView animateWithDuration:0.4
                     animations:^{
                         
                         if (weakSelf.currentViewController) {
                             CGRect frame = weakSelf.currentViewController.view.bounds;
                             weakSelf.currentViewController.view.frame = CGRectOffset(frame, CGRectGetMinX(_labelStart.frame), CGRectGetMaxY(_labelStart.frame));
                         }
                         if (newVC) {
                             if (!CGRectIsEmpty(newFrame)) {
                                 newVC.view.frame = newFrame;
                             }
                             if (_imgEXFELogo) {
                                 _imgEXFELogo.frame = CGRectMake(112, -20, 96, 90);
                             }
                         } else {
                             if (_imgEXFELogo) {
                                 _imgEXFELogo.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) == 568 ? 150 : 110, 320, 300);
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         if (weakSelf.currentViewController) {
                             [weakSelf.currentViewController.view removeFromSuperview];
                             [weakSelf.currentViewController willMoveToParentViewController:nil];
                             [weakSelf.currentViewController removeFromParentViewController];
                             weakSelf.currentViewController = nil;
                         }
                         
                         if (newVC) {
                             [newVC didMoveToParentViewController:weakSelf];
                             weakSelf.currentViewController = [newVC autorelease];
                             self.imgHead.hidden = NO;
                         } else {
                             self.imgHead.hidden = YES;
                         }
                         
                     }];
}

@end
