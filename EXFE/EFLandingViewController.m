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
    // Do any additional setup after loading the view from its nib.
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.view setFrame:appFrame];
    
    
    UITapGestureRecognizer *tapStart = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        NSLog(@"Click Start");
        [self swapChildViewController:1 param:nil];
    }];
    [_labelStart addGestureRecognizer:tapStart];
    
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
        
        [UIView animateWithDuration:1 delay:0.1 options:UIViewAnimationOptionTransitionNone animations:^{
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
        f.origin.y = CGRectGetMinY(_labelStart.frame);
        newVC.view.frame = f;
    } else {
        
    }
    __weak __block EFLandingViewController *weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        if (weakSelf.currentViewController) {
            weakSelf.currentViewController.view.alpha = 0;
        }
        if (newVC) {
            if (!CGRectIsEmpty(newFrame)) {
                newVC.view.frame = newFrame;
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
                         }
                         
                     }];
}

@end
