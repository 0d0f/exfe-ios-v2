//
//  FullScreenViewController.m
//  EXFE
//
//  Created by huoju on 8/22/12.
//
//

#import "FullScreenViewController.h"

#import "EFKit.h"

@interface FullScreenViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation FullScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [Flurry logEvent:@"FULL_SCREEN"];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    if (self.imageUrl) {
        [[EFDataManager imageManager] loadImageForView:self
                                      setImageSelector:@selector(fillImage:)
                                           placeHolder:self.defaultImage
                                                   key:self.imageUrl
                                       completeHandler:nil];
    } else {
        [self fillImage:self.defaultImage];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)fillImage:(UIImage *)image
{
    if (image){
        if (image.size.width * self.imageView.bounds.size.height >= image.size.height * self.imageView.bounds.size.width) {
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        self.imageView.image = image;
    }
}

@end
