//
//  EFImagePickerViewController.h
//  EXFE
//
//  Created by 0day on 13-9-23.
//
//

#import <UIKit/UIKit.h>

@class EFImagePickerViewController;
typedef void (^EFImagePickerCancelActionBlock)(EFImagePickerViewController *picker);
typedef void (^EFImagePickerChooseActionBlock)(EFImagePickerViewController *picker, NSArray *imageDicts);

@interface EFImagePickerViewController : UIImagePickerController
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

+ (BOOL)isPhotoLibraryAccessPermissionDetermined;
+ (BOOL)isPhotoLibraryAccessAviliable;

@property (nonatomic, strong) EFImagePickerCancelActionBlock  cancelActionHandler;
@property (nonatomic, strong) EFImagePickerChooseActionBlock  chooseActionHandler;

@end
