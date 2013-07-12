//
//  TitleDescEditViewController.m
//  EXFE
//
//  Created by huoju on 1/7/13.
//
//

#import "TitleDescEditViewController.h"
#import "EFKit.h"
#import "TTTAttributedLabel.h"

#define LARGE_SLOT                       (16)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (88)
#define DECTOR_HEIGHT_EXTRA              (LARGE_SLOT)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define TITLE_HORIZON_MARGIN             (SMALL_SLOT)
#define TITLE_VERTICAL_MARGIN            (18)

@interface TitleDescEditViewController ()

@end

@implementation TitleDescEditViewController
@synthesize delegate;
@synthesize imgurl;
@synthesize editFieldHint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"EDIT_TITLE_DESCRIPTION"];
    CGRect b = self.view.bounds;
    //CGRect a = [UIScreen mainScreen].applicationFrame;
    
    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [self.view addSubview:toolbar];
    
    TTTAttributedLabel *viewtitle=[[TTTAttributedLabel alloc] initWithFrame:CGRectMake(60, (44-30)/2, self.view.frame.size.width-60-60, 30)];
    viewtitle.backgroundColor = [UIColor clearColor];
    viewtitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    viewtitle.textAlignment = NSTextAlignmentCenter;
    viewtitle.textColor = FONT_COLOR_51;
    viewtitle.text = NSLocalizedString(@"Title & Description", nil);
    [self.view addSubview:viewtitle];
    
    UIButton *btncancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btncancel setFrame:CGRectMake(0, 0, 20, 44)];
    btncancel.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btncancel setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btncancel setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btncancel addTarget:self action:@selector(Close) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit];
    
    [toolbar addSubview:btncancel];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    doneButton.frame = CGRectMake(255+5+5, 7, 50, 30);
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0,5)] forState:UIControlStateNormal];
    
    [toolbar addSubview:doneButton];
//    [toolbar setHidden:YES];
    
    descView = [[SSTextView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(toolbar.frame) + DECTOR_HEIGHT, self.view.frame.size.width-20, self.view.frame.size.height - DECTOR_HEIGHT - CGRectGetHeight(toolbar.frame))];
    descView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    descView.backgroundColor = [UIColor clearColor];
    descView.textAlignment = NSTextAlignmentLeft;
    descView.backgroundColor=[UIColor whiteColor];
    descView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    descView.placeholder = NSLocalizedString(@"Take some notes", nil);
    [self.view addSubview:descView];

    headview = [[EXCurveView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, self.view.frame.size.width, DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA) withCurveFrame:CGRectMake(CGRectGetWidth(b) - 122,  DECTOR_HEIGHT, 122, DECTOR_HEIGHT_EXTRA) ];
    headview.backgroundColor=[UIColor grayColor];
    {
        CGFloat scale = CGRectGetWidth(headview.bounds) / HEADER_BACKGROUND_WIDTH;
        CGFloat startY = 0 - HEADER_BACKGROUND_Y_OFFSET * scale;
        dectorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, startY, HEADER_BACKGROUND_WIDTH * scale, HEADER_BACKGFOUND_HEIGHT * scale)];
        //dectorView=[[UIImageView alloc] initWithFrame:headview.bounds];
        dectorView.image=[UIImage imageNamed:@"x_titlebg_default.jpg"];
        [headview addSubview:dectorView];
        
        UIView* dectorMask = [[UIView alloc] initWithFrame:headview.bounds];
        dectorMask.backgroundColor = [UIColor COLOR_WA(0x00, 0x55)];
        [headview addSubview:dectorMask];
    }
    [self.view addSubview:headview];
    
//    UIImageView *imageback=[[UIImageView alloc] initWithFrame:CGRectMake(25.5,20.5,263,47)];
//    imageback.image=[[UIImage imageNamed:@"xedit_textfield.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4)];
//    [headview addSubview:imageback];
//    [imageback release];

    UIView *titleBg = [[UIView alloc] initWithFrame:CGRectMake(25, 15, 290, 55)];
    titleBg.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.75];
    titleBg.layer.cornerRadius = 1.5;
    [headview addSubview:titleBg];
    
    titleView = [[UITextView alloc] initWithFrame:CGRectMake(20,15,300,55)];
    titleView.textColor = FONT_COLOR_FA;
    titleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.contentInset = UIEdgeInsetsMake(-8, 0, -8, 0);
    titleView.delegate = self;
    [self textViewDidChange:titleView];
    [headview addSubview:titleView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif

    [self setBackground:imgurl];
    
    if (editFieldHint == 1) {
        // Edit title
        [titleView becomeFirstResponder];
    }else{
        // Assume default is edit Description
        [descView becomeFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
//	CGRect frame = self.inputToolbar.frame;
    keyboardheight=keyboardEndFrame.size.height;
    
//    descView = [[UITextView alloc] initWithFrame:CGRectMake(0, dectorView.frame.origin.y+dectorView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(dectorView.frame.origin.y+dectorView.frame.size.height))];
//    [self.view addSubview:descView];
    CGRect rect = descView.frame;
    rect.size.height=self.view.frame.size.height-(dectorView.frame.origin.y+dectorView.frame.size.height)-keyboardheight-toolbar.frame.size.height;
    [descView setFrame:rect];
    if([descView.text isEqualToString:NSLocalizedString(@"Take some notes", nil)])
        descView.text=@"";
    
//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//        frame.origin.y = self.view.frame.size.height - frame.size.height - keyboardEndFrame.size.height;
//        if(_tableView.contentSize.height>_tableView.frame.size.height)
//        {
//            CGRect _tableviewrect=_tableView.frame;
//            _tableviewrect.origin.y=-keyboardEndFrame.size.height;
//            [_tableView setFrame:_tableviewrect];
//        }
        
//    }
//    else {
//        frame.origin.y = self.view.frame.size.width - frame.size.height - keyboardEndFrame.size.height - kStatusBarHeight;
//        
//    }
//	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    /* Move the toolbar back to bottom of the screen */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    
//	CGRect frame = self.inputToolbar.frame;
//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//        frame.origin.y = self.view.frame.size.height - frame.size.height;
//        if(_tableView.contentSize.height>_tableView.frame.size.height){
//            CGRect _tableviewrect=_tableView.frame;
//            _tableviewrect.origin.y=0;
//            [_tableView setFrame:_tableviewrect];
//        }
//        
//    }
//    else {
//        frame.origin.y = self.view.frame.size.width - frame.size.height;
//    }
    keyboardheight=0;
    CGRect rect = descView.frame;
    rect.size.height=self.view.frame.size.height-(dectorView.frame.origin.y+dectorView.frame.size.height);
    [descView setFrame:rect];
    
    
//	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
    //    keyboardIsVisible = NO;
}

- (void)setBackground:(NSString *)_imgurl {
    if (_imgurl!=nil && ![_imgurl isEqualToString:@""]) {
        NSString *imageKey = _imgurl;
        UIImage *defaultImage = nil;
        
        if (!imageKey) {
            dectorView.image = defaultImage;
        } else {
            if ([[EFDataManager imageManager] isImageCachedInMemoryForKey:imageKey]) {
                dectorView.image = [[EFDataManager imageManager] cachedImageInMemoryForKey:imageKey];
            } else {
                dectorView.image = defaultImage;
                [[EFDataManager imageManager] cachedImageForKey:imageKey
                                                completeHandler:^(UIImage *image){
                                                    if (image) {
                                                        dectorView.image = image;
                                                    }
                                                }];
            }
        }
    }
}


- (void) Close{
    [self dismissModalViewControllerAnimated:YES];
}
- (void) done:(id)sender{
    [delegate setTitle:titleView.text Description:descView.text];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) setCrossTitle:(NSString*)title desc:(NSString*)desc{
    titleView.text = title;
    [self textViewDidChange:titleView];
    
    if(desc!=nil && desc.length>0){
        descView.text=desc;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.contentSize.height <= 26 + 8 * 2) {
        textView.contentOffset = CGPointMake(0, -8);
    }
}

@end
