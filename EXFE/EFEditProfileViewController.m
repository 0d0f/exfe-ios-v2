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

#define kModelKeyName       @"name"
#define kModelKeyBio        @"bio"
#define kModelKeyOriginal   @"original"
#define kModelKeyImageDirty @"dirty"
//#define kModelKeyAvatar     @"avatar"

#define kTagName          233
#define kTagBio           234
#define kTagZoom          100

#define ZOOM_STEP 1.5

@interface EFEditProfileViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong) NSMutableDictionary *data;

@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) SSTextView *bio;
@property (nonatomic, strong) UILabel *identityId;

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *footer;

//@property (nonatomic, strong) UIImageView *preview;
//@property (nonatomic, strong) UIImageView *previewth;

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
    
    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    imageScrollView.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    imageView.tag = kTagZoom;
    [imageScrollView addSubview:imageView];
    self.avatar = imageView;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
    [imageView addGestureRecognizer:twoFingerTap];
//    [imageView addGestureRecognizer:panGesture];
    
    [self.view addSubview:imageScrollView];
    self.imageScrollView = imageScrollView;

    
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
    bioTitle.textColor = [UIColor COLOR_WHITE];
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
    
//    CGFloat hh = CGRectGetHeight(self.footer.bounds) - 20;
//    CGFloat ww = hh / CGRectGetHeight(self.view.bounds) * CGRectGetWidth(self.view.bounds);
//    UIImageView *preview = [[UIImageView alloc] initWithFrame:CGRectMake(160, 10, ww, hh)];
//    preview.backgroundColor = [UIColor whiteColor];
//    preview.contentMode = UIViewContentModeScaleAspectFit;
//    [self.footer addSubview:preview];
//    self.preview = preview;
//    
//    UIImageView *preview2 = [[UIImageView alloc] initWithFrame:CGRectMake(160 + 10 + CGRectGetWidth(preview.bounds), 10 + ww / CGRectGetWidth(self.view.bounds) * CGRectGetHeight(self.header.bounds), ww, ww)];
//    preview2.backgroundColor = [UIColor whiteColor];
//    preview2.contentMode = UIViewContentModeScaleAspectFit;
//    [self.footer addSubview:preview2];
//    self.previewth = preview2;
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
        [self fillAvatar];
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
    [self.imageScrollView setMinimumZoomScale:1.0];
    [self.imageScrollView setMaximumZoomScale:1.0];
    [self.imageScrollView setZoomScale:1.0];
    
    CGSize imageSize = image.size;
    self.avatar.frame = (CGRect){{0, 0}, imageSize};
    
    CGFloat scale = 1.0;
    CGSize frameSize = self.imageScrollView.frame.size;
    if (imageSize.width / imageSize.height > frameSize.width / frameSize.height) {
        scale = frameSize.height / imageSize.height;
    } else {
        scale = frameSize.width / imageSize.width;
    }
    self.avatar.image = image;
    
    [self.imageScrollView setMinimumZoomScale:scale];
    [self.imageScrollView setMaximumZoomScale:scale * 8];
    [self.imageScrollView setZoomScale:scale];
    
    CGPoint p = self.imageScrollView.contentOffset;
    p.x = p.x / 2;
    self.imageScrollView.contentOffset = p;
    
    [self.data removeObjectForKey:kModelKeyImageDirty];
}

- (void)fillBio:(NSString *)bio
{
    self.bio.text = bio;
}

#pragma mark - UI Events


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = [self.imageScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.imageScrollView zoomToRect:zoomRect animated:YES];
    
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
//    [self showPreview];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [self.imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.imageScrollView zoomToRect:zoomRect animated:YES];
    
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
//    [self showPreview];
}

//- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
//    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
//    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
//                                         recognizer.view.center.y + translation.y);
//    [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view.superview];
//}


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
        if (name || bio) {
            if (self.isEditUser) {
                [self.model updateUserName:name withBio:bio];
            } else {
                [self.model updateIdentity:self.identity withName:name withBio:bio];
            }
        }
        
        NSDictionary *dict = [self cropedImages];
        UIImage *full = [dict valueForKey:@"original"];
        UIImage *large = [dict valueForKey:@"large"];
        
        if (full) {
            if (self.isEditUser) {
                [self.model updateUserAvatar:full withLarge:large withSmall:nil];
            } else {
                [self.model updateIdentity:self.identity withAvatar:full withLarge:large withSmall:nil];
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

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:kTagZoom];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
//    [self showPreview];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
//    [self showPreview];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
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

//- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
//{
//    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
//    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
//    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return scaledImage;
//}
//

#pragma mark private
- (UIImage*) getSubImageFrom: (UIImage*) img withRect: (CGRect) rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

- (UIImage *)imageFromImageView:(UIScrollView *)view withCropRect:(CGRect)cropRect
{
    UIGraphicsBeginImageContextWithOptions(view.contentSize, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * largeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect newCropRect = CGRectMake(CGRectGetMinX(cropRect) * scale, CGRectGetMinY(cropRect) * scale, CGRectGetWidth(cropRect) * scale, CGRectGetHeight(cropRect) * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], newCropRect);
    UIImage* img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [self.imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

//- (void)showPreview
//{
//    NSArray *array = [self cropedImages];
//    UIImage *full = nil;
//    UIImage *large = nil;
//    if (array.count > 0) {
//        id v = [array objectAtIndex:0];
//        if (nil != v && [NSNull null] != v) {
//            full = v;
//        }
//    }
//    if (array.count > 1) {
//        id v = [array objectAtIndex:1];
//        if (nil != v && [NSNull null] != v) {
//            large = v;
//        }
//    }
//    
//    self.preview.image = full;
//    self.previewth.image = large;
//}

- (NSDictionary *)cropedImages
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    UIImage *original = [self.data valueForKey:kModelKeyOriginal];
    if (!original) {
        NSNumber *dirty = [self.data valueForKey:kModelKeyImageDirty];
        if (dirty && [dirty boolValue]) {
            NSString *imageKey = nil;
            if (self.isEditUser) {
                imageKey = self.user.avatar_filename;
            } else {
                imageKey = self.identity.avatar_filename;
            }
            
            if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
                original = [[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey];
            }
        }
    }
    if (original) {
        NSLog(@"avata frame: %@", NSStringFromCGRect(self.avatar.frame));
        NSLog(@"Contenoffset %@", NSStringFromCGPoint(self.imageScrollView.contentOffset));
        NSLog(@"Scale %f", self.imageScrollView.zoomScale);
        
        CGRect fullRect = CGRectMake(self.imageScrollView.contentOffset.x , self.imageScrollView.contentOffset.y , CGRectGetWidth(self.view.bounds) , CGRectGetHeight(self.view.bounds) );
        CGRect largeRect = CGRectMake(self.imageScrollView.contentOffset.x , self.imageScrollView.contentOffset.y + CGRectGetHeight(self.header.bounds), 320, 320);
        NSLog(@"corp frame: %@,  %@", NSStringFromCGRect(fullRect), NSStringFromCGRect(largeRect));
        
        
        if (!CGRectIsEmpty(fullRect)) {
            UIImage *img = [self imageFromImageView:self.imageScrollView withCropRect:fullRect];
            [dict setValue:img forKey:@"original"];
        }
        if (!CGRectIsEmpty(largeRect)) {
            UIImage *img = [self imageFromImageView:self.imageScrollView withCropRect:largeRect];
            [dict setValue:img forKey:@"large"];
        }
    }
    return [dict copy];
}

@end
