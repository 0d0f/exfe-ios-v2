//
//  EFEditProfile.m
//  EXFE
//
//  Created by Stony Wang on 13-7-8.
//
//

#import "EFEditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/BlocksKit.h>
#import "EFModel.h"
#import "Util.h"
#import "EXGradientToolbarView.h"

@interface EFEditProfileViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UITextField *bio;

// name
// bio
// external_id
// provider
// avatar_filename
// provider

@end

@implementation EFEditProfileViewController


#pragma mark - Getter/Setter
- (BOOL)isEditUser
{
    return self.user != nil;
}

#pragma mark - View Controller Live cycle
- (id)initWithModel:(EXFEModel*)model
{
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor COLOR_SNOW];
    self.view = contentView;
    
    UIImageView *fullScreen = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:fullScreen];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 80)];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20,  CGRectGetHeight(header.bounds))];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnBack];
    
    UITextField *fullName = [[UITextField alloc] initWithFrame:CGRectMake(30, 15, 260, 50)];
    
    [header addSubview:fullName];
    
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(270, 25, 30, 30)];
    [camera addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:camera];
    
    [self.view addSubview:header];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark KVO methods

#pragma mark - UI Refresh

#pragma mark - UI Events

#pragma mark UIButton action
- (void)goBack:(id)view
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)takePicture:(UIControl*)view
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:NSLocalizedString(@"Choose your action:", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"Take a photo", nil) handler:^{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:picker animated:YES];
        }else{
            // Simulator
//            NSLog(@"");
        }
        
    }];
    [sheet addButtonWithTitle:NSLocalizedString(@"Pick a photo from Library", nil) handler:^{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
    }];
//    [sheet setCancelButtonWithTitle:nil handler:^{ NSLog(@"Never mind, then!"); }];
    [sheet showInView:self.view];

}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    NSLog(@"didFinishPickingMediaWithInfo");
    
    /*
     NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
     
     NSData *data;
     
     if ([mediaType isEqualToString:@"public.image"]){
     
     //切忌不可直接使用originImage，因为这是没有经过格式化的图片数据，可能会导致选择的图片颠倒或是失真等现象的发生，从UIImagePickerControllerOriginalImage中的Origin可以看出，很原始，哈哈
     UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
     
     //图片压缩，因为原图都是很大的，不必要传原图
     UIImage *scaleImage = [self scaleImage:originImage toScale:0.3];
     
     //以下这两步都是比较耗时的操作，最好开一个HUD提示用户，这样体验会好些，不至于阻塞界面
     if (UIImagePNGRepresentation(scaleImage) == nil) {
     //将图片转换为JPG格式的二进制数据
     data = UIImageJPEGRepresentation(scaleImage, 1);
     } else {
     //将图片转换为PNG格式的二进制数据
     data = UIImagePNGRepresentation(scaleImage);
     }
     
     //将二进制数据生成UIImage
     UIImage *image = [UIImage imageWithData:data];
     
     //将图片传递给截取界面进行截取并设置回调方法（协议）
     CaptureViewController *captureView = [[CaptureViewController alloc] init];
     captureView.delegate = self;
     captureView.image = image;
     //隐藏UIImagePickerController本身的导航栏
     picker.navigationBar.hidden = YES;
     [picker pushViewController:captureView animated:YES];
     
     }
     */
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
//    NSLog(@"imagePickerControllerDidCancel");
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
@end
