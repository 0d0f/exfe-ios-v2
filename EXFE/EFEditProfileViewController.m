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
#import "Avatar.h"

#define kModelKeyName       @"name"
#define kModelKeyBio        @"bio"
#define kModelKeyOriginal   @"original"
#define kModelKeyImageDirty @"dirty"

#define kKeyImageFull      @"full"
#define kKeyImageLarge     @"large"



#define kTagName          233
#define kTagBio           234
#define kTagZoom          100

#define ZOOM_STEP 1.5

#pragma mark -
#pragma mark - Private Interface
@interface EFEditProfileViewController ()

#pragma mark Gloabel Application Model
@property (nonatomic, weak) EXFEModel *model;
#pragma mark Private ViewController Model
@property (nonatomic, strong) NSMutableDictionary *data;

#pragma mark Quick Access to UI Elements
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *identityId;
@property (nonatomic, strong) SSTextView *inputName;
@property (nonatomic, strong) UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIView *imageScrollRange;
@property (nonatomic, strong) SSTextView *bio;

@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *footer;

@property (nonatomic, strong) UIView *activeInputView;

@property (nonatomic, strong) UIImageView *preview;
@property (nonatomic, strong) UIImageView *previewTh;

@end

#pragma mark -
#pragma mark -
@implementation EFEditProfileViewController

#pragma mark Getter/Setter
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

#pragma mark View Controller Life cycle
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
    // root view
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor COLOR_BLACK];
    contentView.scrollEnabled = NO;
    self.view = contentView;
    

    // Lower layer
    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    imageScrollView.delegate = self;
    
    
    UIView * imageScrollRange = [[UIView alloc] initWithFrame:CGRectZero];
    [imageScrollView addSubview:imageScrollRange];
    self.imageScrollRange = imageScrollRange;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    imageView.tag = kTagZoom;
    [imageScrollRange addSubview:imageView];
    self.avatar = imageView;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
//    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [imageView addGestureRecognizer:singleTap];
    [imageView addGestureRecognizer:doubleTap];
//    [imageView addGestureRecognizer:twoFingerTap];
    
    [self.view addSubview:imageScrollView];
    self.imageScrollView = imageScrollView;

    
    // View port layer
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
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190, 97)];
    name.backgroundColor = [UIColor clearColor];
    name.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21];
    name.textColor = [UIColor whiteColor];
    name.textAlignment = NSTextAlignmentCenter;
    name.center = header.center;
    name.numberOfLines = 2;
    name.lineBreakMode = NSLineBreakByTruncatingTail;
    [header addSubview:name];
    self.name = name;
    UITapGestureRecognizer *tap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (state == UIGestureRecognizerStateEnded) {
            if (self.name.hidden == NO) {
                self.name.hidden = YES;
                self.identityId.hidden = YES;
                NSString *dataName = [self.data valueForKey:kModelKeyName];
                if (dataName) {
                    self.inputName.text = dataName;
                } else {
                    if (self.isEditUser) {
                        self.inputName.text = self.user.name;
                    } else {
                        self.inputName.text = self.identity.name;
                    }
                }
                CGSize size = [self.inputName sizeThatFits:CGSizeMake(CGRectGetWidth(self.inputName.bounds), MAXFLOAT)];
                NSLog(@"size %@ for %@", NSStringFromCGSize(size), self.inputName.text);
                if (size.height > 70) {
                    size.height = 70;
                }
                self.inputName.bounds = (CGRect){CGPointZero, {190 + 8 * 2, size.height}};
                self.inputName.center = self.header.center;
                self.inputName.hidden = NO;
                [self.inputName becomeFirstResponder];
            }
        }
    }];
    name.userInteractionEnabled = YES;
    [name addGestureRecognizer:tap];
    
    UILabel *identityId = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(header.bounds) / 2, 260, 30)];
    identityId.backgroundColor = [UIColor clearColor];
    identityId.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14];
    identityId.textColor = [UIColor whiteColor];
    identityId.textAlignment = NSTextAlignmentCenter;
    [header addSubview:identityId];
    self.identityId = identityId;
    
    SSTextView *inputName = [[SSTextView alloc] initWithFrame:CGRectMake(0, 0, 190 + 8 * 2, 70 + 8 * 2)];
    inputName.backgroundColor = [UIColor clearColor];
    inputName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21];
    inputName.returnKeyType = UIReturnKeyDone;
    inputName.textColor = [UIColor whiteColor];
    inputName.textAlignment = NSTextAlignmentCenter;
    inputName.delegate = self;
    inputName.center = header.center;
    inputName.tag = kTagName;
    inputName.hidden = YES;
    [header addSubview:inputName];
    self.inputName = inputName;
    
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeCustom];
    camera.frame = CGRectMake(280, CGRectGetHeight(header.bounds) / 2  - 30 / 2, 30, 30);
    [camera addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [camera setBackgroundImage:[UIImage imageNamed:@"camera_30.png"] forState:UIControlStateNormal];
    [header addSubview:camera];
    
    [self.view addSubview:header];
    self.header = header;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight + CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - headerHeight - CGRectGetWidth(self.view.bounds))];
    footer.backgroundColor = [UIColor COLOR_WA(0x00, 0xA9)];
//    footer.backgroundColor = [UIColor COLOR_WA(0xFF, 0xFF)];
    
    UILabel *bioTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, CGRectGetWidth(footer.bounds) - 15 * 2, 30)];
    bioTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    bioTitle.text = NSLocalizedString(@"Bio:", nil);
    bioTitle.backgroundColor = [UIColor clearColor];
    bioTitle.textColor = [UIColor COLOR_WHITE];
    [bioTitle sizeToFit];
    [footer addSubview:bioTitle];
    
    CGFloat hintHeight = 0;
    CGFloat marginBottom = 10;
    if ([UIScreen mainScreen].ratio == UIScreenRatioLong) {
        UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(footer.bounds) - 15 * 2, hintHeight)];
        hint.text = NSLocalizedString(@"Cropped area displays as portrait.", nil);
        hint.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        hint.textColor = [UIColor COLOR_WA(0xCC, 0xFF)];
        hint.backgroundColor = [UIColor clearColor];
        [hint sizeToFit];
        hintHeight = CGRectGetHeight(hint.bounds);
        hint.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) - marginBottom - CGRectGetHeight(hint.bounds) / 2);
        [self.view addSubview:hint];
    }
    
    SSTextView *bio = [[SSTextView alloc] initWithFrame:CGRectMake(20 - 8, CGRectGetMaxY(bioTitle.frame), CGRectGetWidth(footer.bounds) - (20 - 8) * 2, CGRectGetHeight(footer.bounds) - CGRectGetMaxY(bioTitle.frame) - hintHeight - marginBottom)];
    bio.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    bio.placeholder = NSLocalizedString(@"Bio is empty, yet.", nil);
    bio.placeholderTextColor = [UIColor COLOR_ALUMINUM];
    bio.textColor = [UIColor whiteColor];
    bio.backgroundColor = [UIColor clearColor];
    bio.delegate = self;
    bio.tag = kTagBio;
    [footer insertSubview:bio belowSubview:bioTitle];
    self.bio = bio;
    
    [self.view addSubview:footer];
    self.footer = footer;
    
#ifdef DEBUG
    UIImageView *preview = [[UIImageView alloc] initWithFrame:CGRectMake(100, 5, 80, 80 / CGRectGetWidth(self.view.bounds) * CGRectGetHeight(self.view.bounds))];
    preview.backgroundColor = [UIColor whiteColor];
    preview.contentMode = UIViewContentModeScaleAspectFit;
    [footer addSubview:preview];
    self.preview = preview;
    
    UIImageView *previewTh = [[UIImageView alloc] initWithFrame:CGRectMake(200, 5 + CGRectGetHeight(self.header.bounds) * 80 / CGRectGetWidth(self.view.bounds), 80, 80 )];
    previewTh.backgroundColor = [UIColor whiteColor];
    previewTh.contentMode = UIViewContentModeScaleAspectFit;
    [footer addSubview:previewTh];
    self.previewTh = previewTh;
    
#endif
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self fillUI];
    [self fillAvatar];
    [self registerAsObserver];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
-(BOOL)canBecomeFirstResponder
{
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
- (void)registerAsObserver
{
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

- (void)unregisterForChangeNotification
{
    [self.data removeObserver:self forKeyPath:kModelKeyOriginal];
    [self.data removeObserver:self forKeyPath:kModelKeyName];
    [self.data removeObserver:self forKeyPath:kModelKeyBio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    if ([keyPath isEqual:kModelKeyOriginal]) {
//        UIImage * image = [change objectForKey:NSKeyValueChangeNewKey];
        [self fillAvatar];
    } else if ([keyPath isEqual:kModelKeyName]) {
        [self fillUI];
    } else if ([keyPath isEqual:kModelKeyBio]) {
        [self fillUI];
    } else {
        // fallback
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
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

// For performance issue. move fillAvater out of fillUI
- (void)fillAvatar
{
    UIImage *original = [self.data valueForKey:kModelKeyOriginal];
    if (original) {
        [self fillAvatar:original];
    } else {
        NSString *imageKey = nil;
        if (self.isEditUser) {
            imageKey = self.user.avatar.original;
        } else {
            imageKey = self.identity.avatar.original;
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
    self.name.center = CGPointMake(self.header.center.x, self.header.center.y - offset);
    self.identityId.center = CGPointMake(self.header.center.x, CGRectGetMaxY(self.name.frame) + CGRectGetHeight(self.identityId.bounds) / 2);
    
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
    CGSize size = [self.name sizeThatFits:CGSizeMake(190, 50)];
    CGPoint p = self.header.center;
    self.name.frame = (CGRect){{p.x - 190 / 2, p.y - size.height / 2},{190, size.height}};
}

- (void)fillIdentityDisplayName:(NSString *)displayName
{
    self.identityId.text = displayName;
    CGSize size = [self.identityId sizeThatFits:CGSizeMake(260, 50)];
    CGPoint p = self.header.center;
    self.identityId.frame = (CGRect){{p.x - 190 / 2, p.y + size.height / 2},{190, size.height}};
}

- (void)fillAvatar:(UIImage *)image
{
    float paddingRatio = 0.5;
    
    [self.imageScrollView setMinimumZoomScale:1.0];
    [self.imageScrollView setMaximumZoomScale:1.0];
    [self.imageScrollView setZoomScale:1.0];
    
    CGSize imageSize = image.size;
    
    CGSize size = CGSizeZero;
    
    CGFloat ratio = 1.0;
    
    // Enhance content range
    size.width = imageSize.width * (1 + paddingRatio * 2);
    if (size.width >= 320) {
        NSLog(@"imageSize %@", NSStringFromCGSize(imageSize));
        // Large
        size.height = size.width / CGRectGetWidth(self.view.bounds) * CGRectGetHeight(self.view.bounds);
        NSLog(@"contentSize calculated %@", NSStringFromCGSize(size));
        BOOL widthFillFlag = YES;
        CGPoint center = CGPointZero;
        if (imageSize.height > size.height) {
            // fix for long long vertical pic
            size.height = imageSize.height;
            // resign width
            size.width = size.height / CGRectGetHeight(self.view.bounds) * CGRectGetWidth(self.view.bounds);
            widthFillFlag = NO;
            NSLog(@"contentSize fixed %@", NSStringFromCGSize(size));
            center = CGPointMake(size.width / (1 + paddingRatio * 2), size.height / 2);
        } else {
            center = CGPointMake(size.width / (1 + paddingRatio * 2), size.height * ((CGRectGetHeight(self.header.bounds) + 320 / 2) /  CGRectGetHeight(self.view.bounds)));
        }
        self.imageScrollRange.frame = (CGRect){CGPointZero, size};
        self.imageScrollRange.backgroundColor = [UIColor lightGrayColor];
        self.avatar.frame = (CGRect){CGPointZero, imageSize};
        self.avatar.center = center;
        self.avatar.image = image;
        
        if (widthFillFlag) {
            ratio = CGRectGetWidth(self.imageScrollView.bounds) / (size.width / (1 + paddingRatio * 2));
        } else {
            ratio = CGRectGetHeight(self.imageScrollView.bounds) / size.height ;
        }
        NSLog(@"ratio: %f", ratio);
    } else {
        NSLog(@"imageSize %@", NSStringFromCGSize(imageSize));
        // small
        size.width = 320;
        size.height = size.width / CGRectGetWidth(self.view.bounds) * CGRectGetHeight(self.view.bounds);
        
        CGPoint center = CGPointZero;
        
        center = CGPointMake(size.width / (1 + paddingRatio * 2), size.height * ((CGRectGetHeight(self.header.bounds) + 320 / 2) /  CGRectGetHeight(self.view.bounds)));
        
        self.imageScrollRange.frame = (CGRect){CGPointZero, size};
        self.imageScrollRange.backgroundColor = [UIColor lightGrayColor];
        self.avatar.frame = (CGRect){CGPointZero, imageSize};
        self.avatar.center = center;
        self.avatar.image = image;
        
        ratio = CGRectGetWidth(self.imageScrollView.bounds) / (size.width / (1 + paddingRatio * 2));
        
    }
    
    CGFloat scale = ratio;
    [self.imageScrollView setMinimumZoomScale:scale / (1 + paddingRatio * 2)];
    [self.imageScrollView setMaximumZoomScale:scale * 8];
    [self.imageScrollView setZoomScale:scale];
    
    
    CGPoint p = self.imageScrollView.contentOffset;
    CGSize s = self.imageScrollView.contentSize;
    NSLog(@"scaled params: %@, %@ at scale %f", NSStringFromCGPoint(p), NSStringFromCGSize(s), scale);
    
    self.imageScrollView.contentOffset = CGPointMake(self.imageScrollView.contentSize.width / 2 - 160, (CGRectGetHeight(self.header.bounds) + 160));
    
    [self.data removeObjectForKey:kModelKeyImageDirty];
}

- (void)fillBio:(NSString *)bio
{
    self.bio.text = bio;
}

#pragma mark - UI Events

#pragma mark Gesutre
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.activeInputView) {
        switch (self.activeInputView.tag) {
            case kTagName:
                [self.activeInputView resignFirstResponder];
                break;
            case kTagBio:
                [self.activeInputView resignFirstResponder];
                break;
            default:
                break;
        }
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
//    // double tap zooms in
//    float newScale = [self.imageScrollView zoomScale] * ZOOM_STEP;
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
//    [self.imageScrollView zoomToRect:zoomRect animated:YES];
    if (self.imageScrollView.zoomScale != self.imageScrollView.minimumZoomScale) {
        float f = self.imageScrollView.zoomScale;
        CGRect r = CGRectMake(0, 0, self.imageScrollView.contentSize.width / f, self.imageScrollView.contentSize.height / f);
        [self.imageScrollView zoomToRect:r animated:YES];
    } else {
        float f = self.imageScrollView.zoomScale;
        CGRect r = CGRectMake(self.imageScrollView.contentSize.width / f / 2 / 2, CGRectGetHeight(self.header.bounds) + 160, self.imageScrollView.contentSize.width / f / 2, self.imageScrollView.contentSize.height / f / 2);
        [self.imageScrollView zoomToRect:r animated:YES];
        
//         self.imageScrollView.zoomScale = self.imageScrollView.minimumZoomScale * 2;
    }
    
    
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
    
    
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
{
    // two-finger tap zooms out
    float newScale = [self.imageScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.imageScrollView zoomToRect:zoomRect animated:YES];
    
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
}

#pragma mark Keyboard
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIScrollView *scrollView = (UIScrollView *)self.view;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.bounds;
    aRect.size.height -= kbSize.height;
    CGPoint origin = [self.view convertPoint:self.activeInputView.frame.origin fromView:self.activeInputView.superview];
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIScrollView *scrollView = (UIScrollView *)self.view;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark UIButton action
- (void)goBack:(id)view
{
    if ([self.name isFirstResponder]) {
        [self textViewDidEndEditing:self.inputName];
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
        UIImage *full = [dict valueForKey:kKeyImageFull];
        UIImage *large = [dict valueForKey:kKeyImageLarge];
        
        if (full) {
//            if (self.isEditUser) {
//                [self.model updateUserAvatar:full withLarge:large withSmall:nil];
//            } else {
//                [self.model updateIdentity:self.identity withAvatar:full withLarge:large withSmall:nil];
//            }
        }
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    [sheet setCancelButtonWithTitle:nil handler:nil];
    [sheet showInView:self.view];

}

#pragma mark - Delegate
#pragma mark UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    switch (textView.tag) {
        case kTagName:
            self.activeInputView = nil;
            textView.hidden = YES;
            self.name.hidden = NO;
            self.identityId.hidden = YES;
            [self.data setValue:textView.text forKey:kModelKeyName];
            break;
        case kTagBio:
            self.activeInputView = nil;
            [self.data setValue:textView.text forKey:kModelKeyBio];
            break;
            
        default:
            break;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    switch (textView.tag) {
        case kTagName:
            self.activeInputView = textView;
            break;
        case kTagBio:
            self.activeInputView = textView;
            break;
            
        default:
            break;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    switch (textView.tag) {
        case kTagName:{
            if ([@"\n" isEqualToString:text]) {
                [textView resignFirstResponder];
                return NO;
            }
            NSString *original = textView.text;
            NSMutableString *newText = [NSMutableString stringWithString:text];
            [newText replaceOccurrencesOfString:@"\n" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
            NSString *result = [NSString stringWithFormat:@"%@%@%@", [original substringToIndex:range.location], text, [original substringFromIndex:(range.location + range.length) ]];
            if (result) {
                NSData *asciiData = [result dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                if (asciiData.length > 40) {
                    return NO;
                }
            }
        }  break;
        case kTagBio:
            break;
            
        default:
            break;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    switch (textView.tag) {
        case kTagName:{
            CGSize size = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.bounds), MAXFLOAT)];
            NSLog(@"size %@ for %@", NSStringFromCGSize(size), textView.text);
            if (size.height > 70) {
                size.height = 70;
            }
            textView.bounds = (CGRect){CGPointZero, {190 + 8 * 2, size.height}};
            textView.center = self.header.center;
            textView.contentOffset = CGPointZero;
        }   break;
        case kTagBio:
            break;
            
        default:
            break;
    }
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
//    return [scrollView viewWithTag:kTagZoom];
    return self.imageScrollRange;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGPoint p = self.imageScrollView.contentOffset;
    CGSize s = self.imageScrollView.contentSize;
    NSLog(@"scrollViewDidScroll content offset size params: %@, %@", NSStringFromCGPoint(p), NSStringFromCGSize(s));
    
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
    
    if (self.preview) {
        NSDictionary *dict = [self cropedImages];
        self.preview.image = [dict valueForKey:kKeyImageFull];
        self.previewTh.image = [dict valueForKey:kKeyImageLarge];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    id num = [self.data valueForKey:kModelKeyImageDirty];
    if (!num) {
        [self.data setValue:[NSNumber numberWithBool:YES] forKey:kModelKeyImageDirty];
    }
    
    if (self.preview) {
        NSDictionary *dict = [self cropedImages];
        self.preview.image = [dict valueForKey:kKeyImageFull];
        self.previewTh.image = [dict valueForKey:kKeyImageLarge];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.data setValue:image forKey:kModelKeyOriginal];
        
        picker.navigationBar.hidden = YES;
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (UIImage*) getSubImageFrom: (UIImage*) img withRect: (CGRect) rect __deprecated
{
    
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
        CGRect fullRect = CGRectMake(self.imageScrollView.contentOffset.x , self.imageScrollView.contentOffset.y , CGRectGetWidth(self.view.bounds) , CGRectGetHeight(self.view.bounds) );
        CGRect largeRect = CGRectMake(self.imageScrollView.contentOffset.x , self.imageScrollView.contentOffset.y + CGRectGetHeight(self.header.bounds), 320, 320);
        
        if (!CGRectIsEmpty(fullRect)) {
            UIImage *img = [self imageFromImageView:self.imageScrollView withCropRect:fullRect];
            [dict setValue:img forKey:kKeyImageFull];
        }
        if (!CGRectIsEmpty(largeRect)) {
            UIImage *img = [self imageFromImageView:self.imageScrollView withCropRect:largeRect];
            [dict setValue:img forKey:kKeyImageLarge];
        }
    }
    return [dict copy];
}

@end
