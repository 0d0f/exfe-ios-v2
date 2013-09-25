//
//  EFImagePickerViewController.h
//  EXFE
//
//  Created by 0day on 13-9-23.
//
//

#import <UIKit/UIKit.h>

#import "EFImageComposerViewController.h"

@class EFImagePickerViewController;
typedef void (^EFImagePickerCancelActionBlock)(EFImagePickerViewController *picker);

@interface EFImagePickerViewController : UIImagePickerController
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
EFImageComposerViewControllerDelegate
>

+ (BOOL)isPhotoLibraryAccessPermissionDetermined;
+ (BOOL)isPhotoLibraryAccessAviliable;

@property (nonatomic, strong) EFImagePickerCancelActionBlock    cancelActionHandler;

@property (nonatomic, strong) NSMutableArray                    *geomarks;
@property (nonatomic, assign) MKMapRect                         initMapRect;
@property (nonatomic, assign) CGPoint                           offset;         // earth -> mars.

@end
