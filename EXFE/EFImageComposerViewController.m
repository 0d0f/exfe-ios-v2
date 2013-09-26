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
#import "EFAnnotationDataDefines.h"
#import "EFGradientView.h"

#define kImageSize  (CGSize){75.0f, 75.0f}
#define kImageEdge  (4.0f)
#define kMapSize    (CGSize){320.0f, 320.f}
#define kMapEdgePadding (60.0f)


@interface EFImageComposerViewController ()

@property (nonatomic, strong) NSMutableArray *photoCooridinates;

@end

@interface EFImageComposerViewController (Private)

- (void)_addBlurViews;
- (void)_layoutSubviews;
- (void)_initMapRect;
- (void)_initGeomarks;

- (void)_initPhotoGeomarks;
- (void)_resizeMap;

@end

@implementation EFImageComposerViewController (Private)

- (void)_addBlurViews {
    EFGradientView *backgroundView = [[EFGradientView alloc] initWithFrame:self.barView.bounds];
    backgroundView.colors = @[[UIColor COLOR_RGB(0x4C, 0x4C, 0x4C)],
                              [UIColor COLOR_RGB(0x19, 0x19, 0x19)]];
    backgroundView.alpha = 0.88f;
    [self.barView insertSubview:backgroundView atIndex:0];
    
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
        CGRect bottomBlurViewFrame = self.bottomBaseView.bounds;
        bottomBlurViewFrame.origin.y = 1.0f;
        bottomBlurView.frame = bottomBlurViewFrame;
        bottomBlurView.tag = 1024;
        bottomBlurView.blurTintColor = [UIColor blackColor];
        [self.bottomBaseView insertSubview:bottomBlurView atIndex:0];
        
        AMBlurView *blurView = [[AMBlurView alloc] init];
        CGRect blurViewFrame = self.barView.bounds;
        blurViewFrame.origin.y = 1.0f;
        blurView.frame = blurViewFrame;
        blurView.blurTintColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        [self.barView insertSubview:blurView atIndex:0];
    }
}

- (void)_layoutSubviews {
    NSUInteger count = self.imageDicts.count;
    NSUInteger row = count / 4 + ((count % 4) ? 1 : 0);
    CGRect topBaseViewFrame = self.topBaseView.frame;
    CGFloat topBaseViewHeight = row * (kImageSize.height + kImageEdge);
    topBaseViewFrame.size.height = topBaseViewHeight;
    self.topBaseView.frame = topBaseViewFrame;
    
    CGRect topShadowFrame = self.topShadowView.frame;
    topShadowFrame.origin.y = CGRectGetHeight(topBaseViewFrame) - 4.0f;
    self.topShadowView.frame = topShadowFrame;
    
    CGFloat bottomBaseViewOriginY = ceil(topBaseViewHeight + kMapSize.height);
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

- (void)_initMapRect {
    [self.mapView setVisibleMapRect:self.mapRect];
}

- (void)_initGeomarks {
    [self.mapView addAnnotations:self.geomarks];
    [self.mapView addAnnotations:self.photoGeomarks];
}

- (void)_initPhotoGeomarks {
    if (self.photoGeomarks) {
        [self.photoGeomarks removeAllObjects];
    } else {
        self.photoGeomarks = [[NSMutableArray alloc] init];
    }
    
    self.photoCooridinates = [[NSMutableArray alloc] init];
    
    int i = 1;
    for (NSDictionary *imageDict in self.imageDicts) {
        if ([imageDict valueForKey:@"longitude"] && [imageDict valueForKey:@"latitude"]) {
            CGFloat longtitude = [[imageDict valueForKey:@"longitude"] doubleValue];
            CGFloat latitude = [[imageDict valueForKey:@"latitude"] doubleValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longtitude);
            
            [self.photoCooridinates addObject:[NSValue valueWithMKCoordinate:coordinate]];
            
            EFAnnotation *annotation = [[EFAnnotation alloc] initWithStyle:kEFAnnotationStyleMarkRed
                                                                coordinate:coordinate
                                                                     title:nil
                                                               description:nil];
            annotation.markTitle = [NSString stringWithFormat:@"%d", i];
            [self.photoGeomarks addObject:annotation];
        }
        
        ++i;
    }
}

- (void)_resizeMap {
    if (1 == self.photoCooridinates.count) {
        CLLocationCoordinate2D coordinate = [self.photoCooridinates[0] MKCoordinateValue];
        [self.mapView setCenterCoordinate:coordinate];
    } else if (self.photoCooridinates.count > 1) {
        CGFloat minX = CGFLOAT_MAX, minY = CGFLOAT_MAX, maxX = CGFLOAT_MIN, maxY = CGFLOAT_MIN;
        
        for (NSValue *value in self.photoCooridinates) {
            CLLocationCoordinate2D coordinate = [value MKCoordinateValue];
            
            MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
            
            minX = MIN(minX, mapPoint.x);
            minY = MIN(minY, mapPoint.y);
            maxX = MAX(maxX, mapPoint.x);
            maxY = MAX(maxY, mapPoint.y);
        }
        
        MKMapRect mapRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
        
        UIEdgeInsets edgePadding = (UIEdgeInsets){CGRectGetHeight(self.topBaseView.frame) + kMapEdgePadding, kMapEdgePadding, CGRectGetHeight(self.bottomBaseView.frame) + kMapEdgePadding, kMapEdgePadding};
        [self.mapView setVisibleMapRect:mapRect edgePadding:edgePadding animated:YES];
    }
}

@end

@implementation EFImageComposerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self _addBlurViews];
    
    self.bottomShadowView.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderColor = [UIColor COLOR_RGBA(0xE6, 0xE6, 0xE6, 0.66f * 0xFF)].CGColor;
        imageView.layer.borderWidth = 0.5f;
        
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = (CGSize){0.0f, 0.0f};
        imageView.layer.shadowOpacity = 0.25f;
        imageView.layer.shadowRadius = 2.0f;
        
        imageView.clipsToBounds = NO;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _layoutSubviews];
    [self _initMapRect];
    [self _initGeomarks];
    [self _resizeMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Action

- (IBAction)shareButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageComposerViewControllerShareButtonPressed:whithImage:)]) {
        UIGraphicsBeginImageContextWithOptions(self.baseView.bounds.size, NO, [UIScreen mainScreen].scale);
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [self.baseView.layer renderInContext:UIGraphicsGetCurrentContext()];
        } else {
            [self.baseView drawViewHierarchyInRect:self.baseView.bounds afterScreenUpdates:YES];
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect snapshotFrame = self.baseView.bounds;
        snapshotFrame.size.height = CGRectGetMaxY(self.topBaseView.frame) + kMapSize.height;
        CGFloat scale = image.scale;
        
        snapshotFrame.size.width *= scale;
        snapshotFrame.size.height *= scale;
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, snapshotFrame);
        UIImage *result = [UIImage imageWithCGImage:imageRef scale:scale orientation:image.imageOrientation];
        CGImageRelease(imageRef);
        
        UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil);
        
        [self.delegate imageComposerViewControllerShareButtonPressed:self whithImage:result];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageComposerViewControllerCancelButtonPressed:)]) {
        [self.delegate imageComposerViewControllerCancelButtonPressed:self];
    }
}

- (void)customWithImageDicts:(NSArray *)imageDicts geomarks:(NSArray *)geomarks path:(NSArray *)path mapRect:(MKMapRect)mapRect {
    self.imageDicts = imageDicts;
    self.geomarks = geomarks;
    self.path = path;
    self.mapRect = mapRect;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[EFAnnotation class]]) {
        static NSString *Identifier = @"Location";
        
        EFAnnotationView *annotationView = (EFAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
        if (nil == annotationView) {
            annotationView = [[EFAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
            annotationView.canShowCallout = NO;
            annotationView.mapView = self.mapView;
            annotationView.draggable = NO;
        }
        
        [annotationView reloadWithAnnotation:annotation];
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark -

- (void)setImageDicts:(NSArray *)imageDicts {
    [self willChangeValueForKey:@"imageDicts"];
    
    _imageDicts = imageDicts;
    
    [self _initPhotoGeomarks];
    [self _layoutSubviews];
    
    [self didChangeValueForKey:@"imageDicts"];
}

@end
