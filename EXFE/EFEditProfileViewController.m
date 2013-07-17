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
#import "EFCache.h"
#import "Util.h"
#import "EXGradientToolbarView.h"
#import "UIScreen+EXFE.h"
#import "SSTextView.h"

#define kModelKeyName     @"name"
#define kModelKeyBio      @"bio"
#define kModelKeyOriginal @"original"
#define kModelKeyAvatar   @"avatar"

#define kTagName          233
#define kTagBio           234

@interface EFEditProfileViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) SSTextView *bio;
@property (nonatomic, strong) UILabel *identityId;

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *footer;

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
        self.data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor COLOR_BLACK];
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
    
    CGFloat headerHeight = 80;
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
    fullName.backgroundColor = [UIColor clearColor];
    fullName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21];
    fullName.returnKeyType = UIReturnKeyDone;
    fullName.textColor = [UIColor whiteColor];
    fullName.textAlignment = NSTextAlignmentCenter;
    fullName.delegate = self;
    fullName.tag = kTagName;
    [header addSubview:fullName];
    self.name = fullName;
    
    UILabel *identityId = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(header.bounds) / 2, 260, 30)];
    identityId.backgroundColor = [UIColor clearColor];
    identityId.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14];
    identityId.textColor = [UIColor whiteColor];
    identityId.textAlignment = NSTextAlignmentCenter;
    [header addSubview:identityId];
    self.identityId = identityId;
    
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeCustom];
    camera.frame = CGRectMake(280, CGRectGetHeight(header.bounds) / 2  - 30 / 2, 30, 30);
    [camera addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [camera setBackgroundImage:[UIImage imageNamed:@"camera_30.png"] forState:UIControlStateNormal];
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
    bio.tag = kTagBio;
    [footer addSubview:bio];
    self.bio = bio;
    
    [self.view addSubview:footer];
    self.footer = footer;
    
    if ([UIScreen mainScreen].ratio == UIScreenRatioLong) {
        UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(footer.bounds) - 15 * 2, 30)];
        hint.text = NSLocalizedString(@"Cropped area displays as portrait.", nil);
        hint.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        hint.textColor = [UIColor COLOR_WA(0xCC, 0xFF)];
        hint.backgroundColor = [UIColor clearColor];
        [hint sizeToFit];
        hint.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) - 10 - CGRectGetHeight(hint.bounds) / 2);
        [self.view addSubview:hint];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self fillUI];
    [self fillAvatar];
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
        if (self.data.count > 0) {
            
            UIAlertView *alertView = [UIAlertView alertViewWithTitle:NSLocalizedString(@"Revert editing", nil) message:NSLocalizedString(@"Confirm reverting portrait or anything changed?", nil)];
            [alertView addButtonWithTitle:NSLocalizedString(@"Revert", nil) handler:^{
                [_data removeAllObjects];
                [self fillUI];
            }];
            [alertView setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) handler:nil];
            [alertView show];
        }
    }
}

#pragma mark KVO methods
- (void)registerAsObserver {
    /*
     Register 'inspector' to receive change notifications for the "openingBalance" property of
     the 'account' object and specify that both the old and new values of "openingBalance"
     should be provided in the observe… method.
     */
    [self.data addObserver:self
           forKeyPath:kModelKeyOriginal
              options:(NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld)
              context:NULL];
    
    [self.data addObserver:self
           forKeyPath:kModelKeyName
              options:(NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld)
              context:NULL];
    
    [self.data addObserver:self
           forKeyPath:kModelKeyBio
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
    [self.data removeObserver:self forKeyPath:kModelKeyOriginal];
    [self.data removeObserver:self forKeyPath:kModelKeyName];
    [self.data removeObserver:self forKeyPath:kModelKeyBio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:kModelKeyOriginal]) {
//        UIImage * image = [change objectForKey:NSKeyValueChangeNewKey];
        [self avatar];
    } else if ([keyPath isEqual:kModelKeyName]) {
        [self fillUI];
    } else if ([keyPath isEqual:kModelKeyBio]) {
        [self fillUI];
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
- (void)fillUI
{
    if (self.isEditUser) {
        [self fillUser:self.user];
    } else {
        [self fillIdentity:self.identity];
    }
}

- (void)fillUser:(User *)user
{
    NSString *dataName = [self.data valueForKey:kModelKeyName];
    if (dataName) {
        [self fillName:dataName];
    } else {
        [self fillName:user.name];
    }
    if (self.identityId.hidden == NO) {
        self.identityId.hidden = YES;
        self.identityId.text = nil;
    }
    
    NSString *dataBio = [self.data valueForKey:kModelKeyBio];
    if (dataBio) {
        [self fillBio:dataBio];
    } else {
        [self fillBio:user.bio];
    }
}

- (void)fillIdentity:(Identity *)identity
{
    
    NSString *dataName = [self.data valueForKey:kModelKeyName];
    if (dataName) {
        [self fillName:dataName];
    } else {
        [self fillName:identity.name];
    }
    [self fillIdentityDisplayName:[identity getDisplayIdentity]];
    
    if (self.identityId.hidden == YES) {
        self.identityId.hidden = NO;
    }
    
    CGFloat offset = CGRectGetHeight(self.name.bounds) / 2 - CGRectGetHeight(self.identityId.bounds) / 2;
    self.name.frame = CGRectOffset(self.name.frame, 0, -offset);
    self.identityId.frame = CGRectOffset(self.identityId.frame, 0, -offset + 2);
    
    NSString *dataBio = [self.data valueForKey:kModelKeyBio];
    if (dataBio) {
        [self fillBio:dataBio];
    } else {
        [self fillBio:identity.bio];
    }
}

- (void)fillName:(NSString *)name
{
    self.name.text = name;
    CGSize size = [self.name sizeThatFits:CGSizeMake(260, 50)];
    CGPoint p = self.header.center;
    self.name.frame = (CGRect){{p.x - 260 / 2, p.y - size.height / 2},{260, size.height}};
}

- (void)fillIdentityDisplayName:(NSString *)displayName
{
    self.identityId.text = displayName;
    CGSize size = [self.identityId sizeThatFits:CGSizeMake(260, 50)];
    CGPoint p = self.header.center;
    self.identityId.frame = (CGRect){{p.x - 260 / 2, p.y + size.height / 2},{260, size.height}};
}

- (void)fillAvatar
{
    UIImage *original = [self.data valueForKey:kModelKeyOriginal];
    if (original) {
        [self fillAvatar:original];
    } else {
        NSString *imageKey = nil;
        if (self.isEditUser) {
           imageKey = self.user.avatar_filename;
        } else {
            imageKey = self.identity.avatar_filename;
        }
        
        if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
            [self fillAvatar:[[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey]];
        } else {
            [[EFDataManager imageManager] cachedImageForKey:imageKey
                                            completeHandler:^(UIImage *image){
                                                if (image) {
                                                    [self fillAvatar:image];
                                                }
                                            }];
        }
    }
}

- (void)fillAvatar:(UIImage *)image
{
    self.avatar.contentMode = UIViewContentModeScaleAspectFill;
    self.avatar.image = image;
    self.avatar.frame = self.avatar.bounds;
}

- (void)fillBio:(NSString *)bio
{
    self.bio.text = bio;
}

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
    if ([self.name isFirstResponder]) {
        [self textFieldDidEndEditing:self.name];
    }
    
    if ([self.bio isFirstResponder]) {
        [self textViewDidEndEditing:self.bio];
    }
    
    if (self.data.count > 0) {
        NSString * name = [self.data valueForKey:kModelKeyName];
        NSString * bio = [self.data valueForKey:kModelKeyBio];
        if (name.length > 0 && bio.length > 0) {
            if (self.isEditUser) {
                [self.model updateUserName:name withBio:bio];
            } else {
                [self.model updateIdentity:self.identity withName:name withBio:bio];
            }
        }
        
        UIImage *original = [self.data valueForKey:kModelKeyOriginal];
        if (original) {
            CGRect avatar_frame = CGRectFromString([self.data valueForKey:kModelKeyAvatar]);
            UIImage *avatar = nil;
            
            
            if (self.isEditUser) {
                [self.model updateUserAvatar:original withLarge:avatar withSmall:nil];
            } else {
                [self.model updateIdentity:self.identity withAvatar:original withLarge:avatar withSmall:nil];
            }
        }
    }
    
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
    switch (textView.tag) {
        case kTagBio:
            [self.data setValue:textView.text forKey:kModelKeyBio];
            break;
            
        default:
            break;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.returnKeyType = UIReturnKeyDefault;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSUInteger length = textView.text.length;
        if (range.length == 0 && range.location == length) {
            // append e enter
            if ([textView.text hasSuffix:@"\n"]) {
                
                textView.text = [textView.text substringToIndex:length - 1];
                [textView resignFirstResponder];
                return NO;
                
            } else {
                textView.returnKeyType = UIReturnKeyDone;
                return YES;
            }
        }
    }
    return YES;
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kTagName:
            if (!self.isEditUser) {
                if (self.identityId.hidden == NO) {
                    
                    [UIView animateWithDuration:0.4
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.identityId.alpha = 0;
                                         self.identityId.hidden = YES;
                                     }
                                     completion:^(BOOL finished) {
                                         self.identityId.alpha = 100;
                                     }];
                    
                }
            }
            break;
            
        default:
            break;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case kTagName:
            if (!self.isEditUser) {
                if (self.identityId.hidden == YES) {
                    self.identityId.alpha = 0;
                    self.identityId.hidden = NO;
                    [UIView animateWithDuration:0.4
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.identityId.alpha = 100;
                                     }
                                     completion:nil];
                }
            }
            [self.data setValue:textField.text forKey:kModelKeyName];
            break;
            
        default:
            break;
    }
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
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.data setValue:image forKey:kModelKeyOriginal];
        
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
