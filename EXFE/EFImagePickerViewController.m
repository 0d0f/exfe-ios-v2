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
#import "AMBlurView.h"

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
    CGFloat x = 10.0f + index * (22.0f + 4.0f);
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
        
        UIView *operationBaseView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, floor(CGRectGetMaxY(viewFrame) - kOperationViewHeight)}, {CGRectGetWidth(viewFrame), kOperationViewHeight}}];
        operationBaseView.backgroundColor = [UIColor clearColor];
        [transitionView.superview addSubview:operationBaseView];
        self.operationBaseView = operationBaseView;
        
        AMBlurView *blurView = [[AMBlurView alloc] init];
        CGRect blurViewFrame = operationBaseView.bounds;
        blurViewFrame.origin.y = 1.0f;
        blurView.frame = blurViewFrame;
        blurView.blurTintColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
        [operationBaseView addSubview:blurView];
        
        EFGradientView *backgroundView = [[EFGradientView alloc] initWithFrame:operationBaseView.bounds];
        backgroundView.colors = @[[UIColor COLOR_RGB(0x4C, 0x4C, 0x4C)],
                                  [UIColor COLOR_RGB(0x19, 0x19, 0x19)]];
        backgroundView.alpha = 0.88f;
        [operationBaseView addSubview:backgroundView];
        
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        okButton.frame = (CGRect){{CGRectGetWidth(operationBaseView.frame) - kButtonWidth, 0.0f}, {kButtonWidth, kOperationViewHeight}};
        okButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [okButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor COLOR_RGB(0x00, 0x78, 0xFF)] forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor COLOR_RGBA(0x00, 0x78, 0xFF, 0.3f * 0xFF)] forState:UIControlStateHighlighted];
        [okButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateNormal];
        okButton.titleLabel.shadowOffset = (CGSize){0.0f, 0.5f};
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
    if (self.imageDicts.count) {
        EFImageComposerViewController *composerViewController = [[EFImageComposerViewController alloc] init];
        composerViewController.delegate = self;
        
        __block NSMutableArray *newImageDicts = [[NSMutableArray alloc] init];
        dispatch_semaphore_t enumerateSemaphore = dispatch_semaphore_create(0);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            for (NSDictionary *imageDict in self.imageDicts) {
                @autoreleasepool {
                    NSURL *imageURL = [imageDict valueForKey:UIImagePickerControllerReferenceURL];
                    if (imageURL) {
                        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                        
                        [library assetForURL:imageURL
                                 resultBlock:^(ALAsset *asset){
                                     ALAssetRepresentation *representation = [asset defaultRepresentation];
                                     
                                     NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
                                     UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                                     
                                     CGFloat imageScale = image.scale;
                                     CGSize imageSize = image.size;
                                     CGFloat imageWidth = MIN(imageSize.width, imageSize.height);
                                     CGRect imageRect = (CGRect){CGPointZero, {imageWidth, imageWidth}};
                                     imageRect.origin = (CGPoint){((imageSize.width - imageWidth) * 0.5f) < 0.0f ? 0.0f : ((imageSize.width - imageWidth) * 0.5f),
                                                                ((imageSize.height - imageWidth) * 0.5f) < 0.0f ? : (imageSize.height - imageWidth) * 0.5f};
                                     
                                     CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
                                     UIImage *result = [UIImage imageWithCGImage:imageRef scale:imageScale orientation:image.imageOrientation];
                                     CGImageRelease(imageRef);
                                     
                                     [imageDict setValue:result forKey:@"image"];
                                     
                                     // create a buffer to hold image data
                                     uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t) * (long)representation.size);
                                     NSUInteger length = [representation getBytes:buffer fromOffset: 0.0  length:(long)representation.size error:nil];
                                     
                                     if (length != 0)  {
                                         // buffer -> NSData object; free buffer afterwards
                                         NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:(long)representation.size freeWhenDone:YES];
                                         
                                         // identify image type (jpeg, png, RAW file, ...) using UTI hint
                                         NSDictionary* sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[representation UTI] ,kCGImageSourceTypeIdentifierHint,nil];
                                         
                                         // create CGImageSource with NSData
                                         CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef) adata,  (__bridge CFDictionaryRef) sourceOptionsDict);
                                         
                                         // get imagePropertiesDictionary
                                         CFDictionaryRef imagePropertiesDictionary;
                                         imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(sourceRef,0, NULL);
                                         
                                         // get gps data
                                         CFDictionaryRef gpsInfo = (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyGPSDictionary);
                                         NSDictionary *gpsDict = (__bridge NSDictionary *)gpsInfo;
                                         
                                         if ([gpsDict valueForKey:@"Latitude"] && [gpsDict valueForKey:@"Longitude"]) {
                                             CGFloat latitude = [[gpsDict valueForKey:@"Latitude"] doubleValue];
                                             CGFloat longitude = [[gpsDict valueForKey:@"Longitude"] doubleValue];
                                             latitude += self.offset.x;
                                             longitude += self.offset.y;
                                             
                                             [imageDict setValue:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
                                             [imageDict setValue:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
                                         }
                                         
                                         // clean up
                                         CFRelease(imagePropertiesDictionary);
                                         CFRelease(sourceRef);
                                     } else {
                                         NSLog(@"image_representation buffer length == 0");
                                     }
                                     
                                     if (result) {
                                         [newImageDicts addObject:imageDict];
                                     }
                                     
                                     dispatch_semaphore_signal(sema);
                                 }
                                failureBlock:^(NSError *error){
                                    dispatch_semaphore_signal(sema);
                                }];
                        
                        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                    }
                }
            }
            
            dispatch_semaphore_signal(enumerateSemaphore);
        });
        
        dispatch_semaphore_wait(enumerateSemaphore, DISPATCH_TIME_FOREVER);
        
        [composerViewController customWithImageDicts:newImageDicts
                                            geomarks:self.geomarks
                                                path:nil
                                             mapRect:self.initMapRect];
        
        [self presentViewController:composerViewController
                           animated:YES
                         completion:nil];
    }
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

#pragma mark - EFImageComposerViewControllerDelegate

- (void)imageComposerViewControllerShareButtonPressed:(EFImageComposerViewController *)viewController whithImage:(UIImage *)image {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.4f);
        
        CGSize imageSize = image.size;
        imageSize.width *= 0.3f;
        imageSize.height *= 0.3f;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        WXImageObject *imageObject = [WXImageObject object];
        imageObject.imageData = imageData;
        
        WXMediaMessage *mediaMessage = [WXMediaMessage message];
        [mediaMessage setThumbImage:thumbImage];
        mediaMessage.mediaObject = imageObject;
        
        SendMessageToWXReq *requestMessage = [[SendMessageToWXReq alloc] init];
        requestMessage.bText = NO;
        requestMessage.scene = WXSceneTimeline;
        requestMessage.message = mediaMessage;
        
        [WXApi sendReq:requestMessage];
    }
}

- (void)imageComposerViewControllerCancelButtonPressed:(EFImageComposerViewController *)viewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
