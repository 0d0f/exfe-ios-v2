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
#import "UIScreen+EXFE.h"
#import "SSTextView.h"

#define kModelKeyName    @"name"
#define kModelKeyBio     @"bio"
#define kModelKeyAvatar  @"avatar"

@interface EFEditProfileViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UITextField *bio;

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *footer;

@property (nonatomic, strong) UIImage *orignalImage;

@end

@implementation EFEditProfileViewController


#pragma mark - Getter/Setter
- (BOOL)isEditUser
{
    return self.user != nil;
}

- (void)setUser:(User *)user
{
    _user = user;
    if (user) {
        self.identity = nil;
    }
}

- (void)setIdentity:(Identity *)identity
{
    _identity = identity;
    if (identity) {
        self.user = nil;
    }
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
    fullScreen.backgroundColor = [UIColor greenColor];
    fullScreen.userInteractionEnabled = YES;
    [self.view addSubview:fullScreen];
    self.avatar = fullScreen;
    UIPanGestureRecognizer *panGesture = [UIPanGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        CGPoint translation = [recognizer translationInView:self.view];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }];
    [self.avatar addGestureRecognizer:panGesture];
    UIPinchGestureRecognizer *pinchGesure = [UIPinchGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPinchGestureRecognizer *recognizer = (UIPinchGestureRecognizer *)sender;
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
        recognizer.scale = 1;
    }];
    [self.avatar addGestureRecognizer:pinchGesure];
    
    CGFloat headerHeight = 60;
    if ([UIScreen mainScreen].ratio == UIScreenRatioLong) {
        headerHeight = 95;
    }
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), headerHeight)];
    header.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = header.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6f] CGColor], (id)[[[UIColor blackColor] colorWithAlphaComponent:0.3f] CGColor], nil];
    [header.layer insertSublayer:gradient atIndex:0];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20,  CGRectGetHeight(header.bounds))];
    btnBack.backgroundColor = [UIColor clearColor];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnBack];
    
    UITextField *fullName = [[UITextField alloc] initWithFrame:CGRectMake(30, 15, 260, 50)];
    fullName.backgroundColor = [UIColor blackColor];
    fullName.returnKeyType = UIReturnKeyDone;
    fullName.delegate = self;
    [header addSubview:fullName];
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(270, 25, 30, 30)];
    [camera addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    camera.backgroundColor = [UIColor brownColor];
    [header addSubview:camera];
    
    [self.view addSubview:header];
    self.header = header;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight + CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - headerHeight - CGRectGetWidth(self.view.bounds))];
    footer.backgroundColor = [UIColor COLOR_WA(0x00, 0xA9)];
    
    UILabel *bioTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, CGRectGetWidth(footer.bounds) - 15 * 2, 30)];
    bioTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    bioTitle.text = NSLocalizedString(@"Bio:", nil);
    bioTitle.backgroundColor = [UIColor clearColor];
    [bioTitle sizeToFit];
    [footer addSubview:bioTitle];
    
    SSTextView *bio = [[SSTextView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(bioTitle.frame) - 5, CGRectGetWidth(footer.bounds) - 15 * 2, CGRectGetHeight(footer.bounds) - 33 - CGRectGetMaxY(bioTitle.frame) + 10)];
    bio.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    bio.placeholder = NSLocalizedString(@"Bio is empty, yet.", nil);
    bio.placeholderTextColor = [UIColor COLOR_ALUMINUM];
    bio.textColor = [UIColor whiteColor];
    bio.backgroundColor = [UIColor clearColor];
    bio.delegate = self;
    [footer addSubview:bio];
    
    [self.view addSubview:footer];
    self.footer = footer;
    
    
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(footer.bounds) - 15 * 2, 30)];
    hint.text = NSLocalizedString(@"Cropped area displays as portrait.", nil);
    hint.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    hint.textColor = [UIColor COLOR_WA(0xCC, 0xFF)];
    hint.backgroundColor = [UIColor clearColor];
    [hint sizeToFit];
    hint.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) - 10 - CGRectGetHeight(hint.bounds) / 2);
    [self.view addSubview:hint];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self registerAsObserver];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self unregisterForChangeNotification];
}

#pragma mark Override
-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"shaked");
    }
}

#pragma mark KVO methods
- (void)registerAsObserver {
    /*
     Register 'inspector' to receive change notifications for the "openingBalance" property of
     the 'account' object and specify that both the old and new values of "openingBalance"
     should be provided in the observe… method.
     */
    [self addObserver:self
           forKeyPath:@"orignalImage"
              options:(NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld)
              context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForChangeNotification {
    [self removeObserver:self forKeyPath:@"orignalImage"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"orignalImage"]) {
        UIImage * image = [change objectForKey:NSKeyValueChangeNewKey];
        [self.avatar setImage:image];
    } else {
        /*
         Be sure to call the superclass's implementation *if it implements it*.
         NSObject does not implement the method.
         */
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    //    NSDictionary* info = [aNotification userInfo];
    //    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat footerHeight = CGRectGetHeight(self.footer.bounds);
    CGFloat y = CGRectGetHeight(self.view.bounds) - kbSize.height - footerHeight;
    
    self.footer.frame = (CGRect){{CGRectGetMinX(self.footer.frame), y}, self.footer.frame.size};
    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
//    
//    // If active text field is hidden by keyboard, scroll it so it's visible
//    // Your application might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
//        [scrollView setContentOffset:scrollPoint animated:YES];
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGFloat footerHeight = CGRectGetHeight(self.footer.bounds);
    CGFloat y = CGRectGetHeight(self.view.bounds) - footerHeight;
    
    self.footer.frame = (CGRect){{CGRectGetMinX(self.footer.frame), y}, self.footer.frame.size};
}

#pragma mark - UI Refresh

#pragma mark - UI Events

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

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
            NSLog(@"");
        }
        
    }];
    [sheet addButtonWithTitle:NSLocalizedString(@"Pick a photo from Library", nil) handler:^{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
    }];
    [sheet setCancelButtonWithTitle:nil handler:^{ NSLog(@"Never mind, then!"); }];
    [sheet showInView:self.view];

}

#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"didFinishPickingMediaWithInfo");
    
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    
    
    if ([mediaType isEqualToString:@"public.image"]){
        
        self.orignalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
//        UIImage *scaleImage = [self scaleImage:originImage toScale:0.3];
//        NSData *data;
//        if (UIImagePNGRepresentation(scaleImage) == nil) {
//            data = UIImageJPEGRepresentation(scaleImage, 1);
//        } else {
//            data = UIImagePNGRepresentation(scaleImage);
//        }
        
//        UIImage *image = [UIImage imageWithData:data];
        
        picker.navigationBar.hidden = YES;
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"imagePickerControllerDidCancel");
    [self dismissModalViewControllerAnimated:YES];
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
