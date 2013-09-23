//
//  EFImagePickerViewController.m
//  EXFE
//
//  Created by 0day on 13-9-23.
//
//

#import "EFImagePickerViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "EFGradientView.h"
#import "Util.h"

#define kOperationViewHeight    (44.0f)
#define kButtonWidth            (80.0f)
#define kMaxImageCount          (8)


@interface EFPickerImageView : UIView

@property (nonatomic, strong) UIImage       *image;
@property (nonatomic, strong) UIImageView   *innerImageView;

@end

@implementation EFPickerImageView

- (id)init {
    self = [super initWithFrame:(CGRect){CGPointZero, 22.0f, 22.0f}];
    if (self) {
        UIImageView *innerImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        innerImageView.layer.cornerRadius = 1.0f;
        innerImageView.layer.masksToBounds = YES;
        innerImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:innerImageView];
        self.innerImageView = innerImageView;
        
        UIImage *maskImage = [UIImage imageNamed:@"portrait_frame_22.png"];
        UIImageView *maskImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        maskImageView.image = maskImage;
        [self addSubview:maskImageView];
    }
    
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.innerImageView.image = image;
}

@end

@interface EFImagePickerViewController ()

@property (nonatomic, assign) BOOL          isInit;
@property (nonatomic, strong) UIView        *operationBaseView;
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) NSMutableArray    *imageDicts;
@property (nonatomic, strong) NSMutableDictionary   *imageURLMap;

@end

@interface EFImagePickerViewController (Private)

- (CGPoint)_imageViewCenterForIndex:(NSUInteger)index;
- (BOOL)_isImageAdded:(NSDictionary *)imageDict;
- (void)_addImage:(NSDictionary *)imageDict;

@end

@implementation EFImagePickerViewController (Private)

- (CGPoint)_imageViewCenterForIndex:(NSUInteger)index {
    CGFloat x = 10.0f + index * (22.0f + 8.0f);
    CGPoint center = (CGPoint){x + 11.0f, CGRectGetMidY(self.operationBaseView.bounds)};
    return center;
}

- (BOOL)_isImageAdded:(NSDictionary *)imageDict {
    return !![self.imageURLMap valueForKey:[[imageDict valueForKey:UIImagePickerControllerReferenceURL] absoluteString]];
}

- (void)_addImage:(NSDictionary *)imageDict {
    [self.imageURLMap setValue:@"YES" forKey:[[imageDict valueForKey:UIImagePickerControllerReferenceURL] absoluteString]];
    [self.imageDicts addObject:imageDict];
    
    EFPickerImageView *imageView = [[EFPickerImageView alloc] init];
    imageView.image = [imageDict valueForKey:UIImagePickerControllerOriginalImage];
    imageView.center = [self _imageViewCenterForIndex:self.imageDicts.count - 1];
    
    [self.scrollView addSubview:imageView];
    
    imageView.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0f, 0.0f, 0.0f)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.duration = 0.233f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    [imageView.layer addAnimation:animation forKey:nil];
    imageView.layer.transform = CATransform3DIdentity;
}

@end

@implementation EFImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isInit = YES;
    
    self.imageDicts = [[NSMutableArray alloc] init];
    self.imageURLMap = [[NSMutableDictionary alloc] init];
    
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isInit) {
        self.isInit = NO;
        
        CGRect viewFrame = CGRectZero;
        UIView *transitionView = nil;
        for (UIView *subView in self.view.subviews) {
            if ([subView isKindOfClass:[NSClassFromString(@"UINavigationTransitionView") class]]) {
                transitionView = subView;
                viewFrame = subView.frame;
                break;
            }
        }
        
        UIView *operationBaseView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, CGRectGetMaxY(viewFrame) - kOperationViewHeight}, {CGRectGetWidth(viewFrame), kOperationViewHeight}}];
        operationBaseView.backgroundColor = [UIColor clearColor];
        [transitionView.superview addSubview:operationBaseView];
        self.operationBaseView = operationBaseView;
        
        EFGradientView *backgroundView = [[EFGradientView alloc] initWithFrame:operationBaseView.bounds];
        backgroundView.colors = @[[UIColor COLOR_RGB(80.0f, 80.0f, 80.0f)],
                                  [UIColor COLOR_RGB(0x19, 0x19, 0x19)]];
        backgroundView.alpha = 0.88f;
        [operationBaseView addSubview:backgroundView];
        
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        okButton.frame = (CGRect){{CGRectGetWidth(operationBaseView.frame) - kButtonWidth, 0.0f}, {kButtonWidth, kOperationViewHeight}};
        [okButton setTitle:NSLocalizedString(@"确认", nil) forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor COLOR_RGB(0x00, 0x78, 0xFF)] forState:UIControlStateNormal];
        [okButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateNormal];
        okButton.titleLabel.shadowOffset = (CGSize){0.0f, 1.0f};
        [okButton addTarget:self
                     action:@selector(okButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
        [self.operationBaseView addSubview:okButton];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {CGRectGetWidth(operationBaseView.frame) - kButtonWidth, kOperationViewHeight}}];
        [operationBaseView addSubview:scrollView];
        self.scrollView = scrollView;
    }
}

#pragma mark - Action

- (void)okButtonPressed:(id)sender {
    
}

#pragma mark - Public

+ (BOOL)isPhotoLibraryAccessPermissionDetermined {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    return (status != ALAuthorizationStatusNotDetermined);
}

+ (BOOL)isPhotoLibraryAccessAviliable {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    return (status != ALAuthorizationStatusAuthorized);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (![self _isImageAdded:info]) {
        if (self.imageDicts.count < kMaxImageCount) {
            [self _addImage:info];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imageDicts removeAllObjects];
    [self.imageURLMap removeAllObjects];
    
    if (self.cancelActionHandler) {
        self.cancelActionHandler(self);
    }
}

@end
