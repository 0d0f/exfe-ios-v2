//
//  EFImageComposerViewController.m
//  EXFE
//
//  Created by 0day on 13-9-24.
//
//

#import "EFImageComposerViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "AMBlurView.h"

#define kImageSize  (CGSize){75.0f, 75.0f}
#define kImageEdge  (4.0f)
#define kMapSize    (CGSize){320.0f, 320.f}

@interface EFImageComposerViewController (Private)

- (void)_addBlurViews;
- (void)_layoutSubviews;

@end

@implementation EFImageComposerViewController (Private)

- (void)_addBlurViews {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        self.topBaseView.backgroundColor = [UIColor COLOR_RGBA(0xFA, 0xFA, 0xFA, 204.0f)];
        self.bottomBaseView.backgroundColor = [UIColor COLOR_RGBA(0xFA, 0xFA, 0xFA, 204.0f)];
    } else {
        // Load resources for iOS 7 or later
        AMBlurView *topBlurView = [[AMBlurView alloc] init];
        topBlurView.frame = self.topBaseView.bounds;
        topBlurView.tag = 1024;
        topBlurView.blurTintColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        [self.topBaseView insertSubview:topBlurView atIndex:0];
        
        AMBlurView *bottomBlurView = [[AMBlurView alloc] init];
        bottomBlurView.frame = self.bottomBaseView.bounds;
        bottomBlurView.tag = 1024;
        bottomBlurView.blurTintColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        [self.bottomBaseView insertSubview:bottomBlurView atIndex:0];
    }
}

- (void)_layoutSubviews {
    NSUInteger count = self.imageDicts.count;
    NSUInteger row = count / 4 + ((count % 4) ? 1 : 0);
    CGRect topBaseViewFrame = self.topBaseView.frame;
    CGFloat topBaseViewHeight = row * kImageSize.height + kImageEdge;
    topBaseViewFrame.size.height = topBaseViewHeight;
    self.topBaseView.frame = topBaseViewFrame;
    
    CGRect topShadowFrame = self.topShadowView.frame;
    topShadowFrame.origin.y = CGRectGetHeight(topBaseViewFrame) - 3.0f;
    self.topShadowView.frame = topShadowFrame;
    
    CGFloat bottomBaseViewOriginY = topBaseViewHeight + kMapSize.height;
    CGFloat bottomBaseViewHeight = CGRectGetHeight(self.baseView.frame) - bottomBaseViewOriginY;
    CGRect bottomBaseViewFrame = self.bottomBaseView.frame;
    bottomBaseViewFrame.origin.y = bottomBaseViewOriginY;
    bottomBaseViewFrame.size.height = bottomBaseViewHeight;
    self.bottomBaseView.frame = bottomBaseViewFrame;
    
    CGRect bottomShadowFrame = self.bottomShadowView.frame;
    bottomShadowFrame.origin.y = 0.0f;
    self.bottomShadowView.frame = bottomShadowFrame;
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.hidden = YES;
    }
    
    for (int i = 0; i < self.imageDicts.count; i++) {
        NSDictionary *imageDict = self.imageDicts[i];
        UIImageView *imageView = self.imageViews[i];
        imageView.hidden = NO;
        
        UIImage *image = [imageDict valueForKey:@"image"];
        imageView.image = image;
    }
}

@end

@implementation EFImageComposerViewController

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
	// Do any additional setup after loading the view.
    
    [self _addBlurViews];
    
    self.topShadowView.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    for (UIImageView *imageView in self.imageViews) {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 1.0f;
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderColor = [UIColor COLOR_RGB(0xE6, 0xE6, 0xE6)].CGColor;
        imageView.layer.borderWidth = 0.5f;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = (CGSize){0.0f, 0.0f};
        imageView.layer.shadowOpacity = 0.25f;
        imageView.layer.shadowRadius = 2.0f;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _layoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageComposerViewControllerShareButtonPressed:whithImage:)]) {
        UIGraphicsBeginImageContextWithOptions(self.baseView.frame.size, NO, [UIScreen mainScreen].scale);
        [self.baseView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.delegate imageComposerViewControllerShareButtonPressed:self whithImage:image];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageComposerViewControllerCancelButtonPressed:)]) {
        [self.delegate imageComposerViewControllerCancelButtonPressed:self];
    }
}

- (void)customWithImageDicts:(NSArray *)imageDicts geomarks:(NSArray *)geomarks path:(NSArray *)path {
    self.imageDicts = imageDicts;
    self.geomarks = geomarks;
    self.path = path;
}

#pragma mark -

- (void)setImageDicts:(NSArray *)imageDicts {
    [self willChangeValueForKey:@"imageDicts"];
    
    _imageDicts = imageDicts;
    
    [self _layoutSubviews];
    
    [self didChangeValueForKey:@"imageDicts"];
}

@end
