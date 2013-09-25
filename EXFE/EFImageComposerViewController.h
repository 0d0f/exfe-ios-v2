//
//  EFImageComposerViewController.h
//  EXFE
//
//  Created by 0day on 13-9-24.
//
//

#import <UIKit/UIKit.h>

@class EFImageComposerViewController;
@protocol EFImageComposerViewControllerDelegate <NSObject>

@optional
- (void)imageComposerViewControllerShareButtonPressed:(EFImageComposerViewController *)viewController whithImage:(UIImage *)image;
- (void)imageComposerViewControllerCancelButtonPressed:(EFImageComposerViewController *)viewController;

@end

@interface EFImageComposerViewController : UIViewController
<
MKMapViewDelegate
>

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *topBaseView;
@property (weak, nonatomic) IBOutlet UIImageView *topShadowView;
@property (weak, nonatomic) IBOutlet UIView *bottomBaseView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomShadowView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@property (nonatomic, strong) NSArray   *imageDicts;
@property (nonatomic, strong) NSArray   *geomarks;
@property (nonatomic, strong) NSArray   *path;
@property (nonatomic, assign) MKMapRect mapRect;
@property (nonatomic, strong) NSMutableArray    *photoGeomarks;

@property (nonatomic, weak) id<EFImageComposerViewControllerDelegate> delegate;

- (IBAction)shareButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

- (void)customWithImageDicts:(NSArray *)imageDicts geomarks:(NSArray *)geomarks path:(NSArray *)path mapRect:(MKMapRect)mapRect;

@end
