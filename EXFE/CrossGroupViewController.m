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
#import "ImgCache.h"
#import "Cross.h"


#define DECTOR_HEIGHT                    (88)

#define kViewTagBack                     (0140000)

@interface CrossGroupViewController ()

- (void) changeHeaderStyle:(NSInteger)style;

@end

@implementation CrossGroupViewController
@synthesize cross = _cross;
@synthesize currentViewController = _currentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        headerStyle = kHeaderStyleFull;
    }
    return self;
}

#pragma mark ViewController life cycle & callbacks
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect b = self.view.bounds;
    CGRect a = [UIScreen mainScreen].applicationFrame;
    self.view.backgroundColor = [UIColor grayColor];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 88 + 20)];
    {
        CGFloat scale = CGRectGetWidth(headerView.bounds) / HEADER_BACKGROUND_WIDTH;
        CGFloat startY = 0 - HEADER_BACKGROUND_Y_OFFSET * scale;
        dectorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, startY, HEADER_BACKGROUND_WIDTH * scale, HEADER_BACKGFOUND_HEIGHT * scale)];
        [headerView addSubview:dectorView];
        
        UIView* dectorMask = [[UIView alloc] initWithFrame:headerView.bounds];
        dectorMask.backgroundColor = [UIColor COLOR_WA(0x00, 0x55)];
        [headerView addSubview:dectorMask];
        [dectorMask release];
        
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(25, 19, 290, 50)];
        titleView.textColor = [UIColor COLOR_RGB(0xFE, 0xFF,0xFF)];
        titleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.lineBreakMode = UILineBreakModeWordWrap;
        titleView.numberOfLines = 2;
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.shadowColor = [UIColor blackColor];
        titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [headerView addSubview:titleView];
    }
    [self.view addSubview:headerView];
    
    container = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 88, 320, CGRectGetHeight(a) - 88)];
    container.alwaysBounceVertical = YES;
    container.backgroundColor = [UIColor clearColor];
    {
        UIView* sample = [[UIView alloc] initWithFrame:container.bounds];
        sample.backgroundColor = [UIColor redColor];
        [container addSubview:sample];
        [sample release];
    }
    [self.view addSubview:container];
    
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.tag = kViewTagBack;
    [self.view  addSubview:btnBack];
    
    [self changeHeaderStyle:headerStyle];
    
    [self refreshUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [titleView release];
    [dectorView release];
    [headerView release];
    
    [container release];
    
    [super dealloc];
}

#pragma mark == Update UI Views

- (void)refreshUI{
    [self fillCross:self.cross];
}

- (void)fillCross:(Cross*) x{
    if (x != nil){
        [self fillTitle:x];
        [self fillBackground:x.widget];
    }
}

- (void) fillTitle:(Cross*)x{
    [titleView setText:x.title];
}

- (void) fillBackground:(NSArray*)widgets{
    BOOL flag = NO;
    for(NSDictionary *widget in widgets) {
        if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            NSString* url = [widget objectForKey:@"image"];
            if (url && url.length > 0) {
                NSString *imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
                UIImage *backimg = [[ImgCache sharedManager] getImgFromCache:imgurl];
                if(backimg == nil || [backimg isEqual:[NSNull null]]){
                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                    dispatch_async(imgQueue, ^{
                        dectorView.image = [UIImage imageNamed:@"x_titlebg_default.jpg"];
                        UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(backimg!=nil && ![backimg isEqual:[NSNull null]]){
                                dectorView.image = backimg;
                            }
                        });
                    });
                    dispatch_release(imgQueue);
                }else{
                    dectorView.image = backimg;
                }
                flag = YES;
                break;
            }
        }
    }
    if (flag == NO){
        dectorView.image = [UIImage imageNamed:@"x_titlebg_default.jpg"];
    }
}


#pragma mark == selector/delegate from UI Views
- (void)gotoBack:(id)sender{
    [self goBack];
}

#pragma mark == ViewController Navigation
- (void) goBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark == Helper methods for Header
- (void) changeHeaderStyle:(NSInteger)style{
    CGRect a = [UIScreen mainScreen].applicationFrame;
    switch (style) {
        case kHeaderStyleHalf:
            [titleView setFrame:CGRectMake(25, 0, 290, 50)];
            titleView.lineBreakMode = UILineBreakModeTailTruncation;
            titleView.numberOfLines = 1;
            [btnBack setFrame:CGRectMake(0, 0, 20, 44)];
            [container setFrame:CGRectMake(0, 44, 320, CGRectGetHeight(a) - 44)];
            break;
            
        default:
            [titleView setFrame:CGRectMake(25, 19, 290, 50)];
            titleView.lineBreakMode = UILineBreakModeWordWrap;
            titleView.numberOfLines = 2;
            [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44)];
            [container setFrame:CGRectMake(0, 88, 320, CGRectGetHeight(a) - 88)];
            break;
    }
}

#pragma mark == Helper methods for Content
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
