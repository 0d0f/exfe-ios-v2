//
//  TitleDescEditViewController.m
//  EXFE
//
//  Created by huoju on 1/7/13.
//
//

#import "TitleDescEditViewController.h"

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
    
    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [self.view addSubview:toolbar];
    
    EXAttributedLabel *viewtitle=[[EXAttributedLabel alloc] initWithFrame:CGRectMake(30, (44-30)/2, self.view.frame.size.width-30-60, 30)];
    viewtitle.backgroundColor=[UIColor clearColor];

    NSMutableAttributedString *titlestr=[[NSMutableAttributedString alloc] initWithString:@"Edit ·X·"];
    
    CTFontRef fontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 20.0, NULL);
    [titlestr addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref range:NSMakeRange(0, 8)];
    [titlestr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_51.CGColor range:NSMakeRange(0,4)];
    [titlestr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(5,3)];

    
    CTTextAlignment alignment = kCTCenterTextAlignment;
    float linespaceing=1;
    float minheight=26;

    CTParagraphStyleSetting paragraphsetting[3] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(paragraphsetting, 3);
    [titlestr addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,8)];
    CFRelease(paragraphstyle);
    CFRelease(fontref);
    viewtitle.attributedText=titlestr;
    [self.view addSubview:viewtitle];
    [titlestr release];
    [viewtitle release];
    UIButton *btncancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btncancel setBackgroundColor:[UIColor colorWithRed:25/255.0f green:25/255.0f blue:25/255.0f alpha:0.5]];
    [btncancel setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btncancel setFrame:CGRectMake(0, 0, 20, 44)];
    [btncancel addTarget:self action:@selector(Close) forControlEvents:UIControlEventTouchUpInside];
    
    [toolbar addSubview:btncancel];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    doneButton.frame = CGRectMake(255+5+5, 7, 50, 30);
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0,5)] forState:UIControlStateNormal];
    
    [toolbar addSubview:doneButton];
//    [toolbar setHidden:YES];

    
    headview = [[EXCurveView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, self.view.frame.size.width, DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA) withCurveFrame:CGRectMake(0+ self.view.frame.size.width * 0.6,  self.view.frame.origin.y +  DECTOR_HEIGHT, 40, DECTOR_HEIGHT_EXTRA) ];

    headview.backgroundColor=[UIColor grayColor];
    
    CGFloat scale = CGRectGetWidth(headview.bounds) / HEADER_BACKGROUND_WIDTH;
    CGFloat startY = 0 - HEADER_BACKGROUND_Y_OFFSET * scale;
    dectorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, startY, HEADER_BACKGROUND_WIDTH * scale, HEADER_BACKGFOUND_HEIGHT * scale)];
    //dectorView=[[UIImageView alloc] initWithFrame:headview.bounds];
    dectorView.image=[UIImage imageNamed:@"x_title_bg.png"];
    
    UIView* dectorMask = [[UIView alloc] initWithFrame:headview.bounds];
    dectorMask.backgroundColor = [UIColor COLOR_WA(0x00, 0x55)];
    [headview addSubview:dectorMask];
    [dectorMask release];
    
    [headview addSubview:dectorView];
    [self.view addSubview:headview];
    
    titleView = [[UITextView alloc] initWithFrame:CGRectMake(25.5,20.5,263,47)];
    titleView.textColor = [UIColor blackColor];
    titleView.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.backgroundColor=[UIColor clearColor];
    [headview addSubview:titleView];
    
//    titleView.layer.shadowColor = [UIColor blackColor].CGColor;
//    titleView.layer.shadowOffset= CGSizeMake(0.0f, 1.0f);
//    titleView.layer.MasksToBounds = false;
    
    UIImageView *imageback=[[UIImageView alloc] initWithFrame:CGRectMake(25.5,20.5,263,47)];
    imageback.image=[[UIImage imageNamed:@"xedit_textfield.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4,4,4,4)];
    [headview addSubview:imageback];
    [imageback release];
    

    descView = [[UITextView alloc] initWithFrame:CGRectMake(0, headview.frame.origin.y+headview.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(headview.frame.origin.y+headview.frame.size.height))];
    descView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    descView.backgroundColor = [UIColor clearColor];
    descView.textAlignment = NSTextAlignmentLeft;
    descView.backgroundColor=[UIColor whiteColor];
    descView.text=@"Take some note";
    
    [self.view addSubview:descView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
    
    // Do any additional setup after loading the view from its nib.
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
    rect.size.height=self.view.frame.size.height-(dectorView.frame.origin.y+dectorView.frame.size.height)-keyboardheight;
    [descView setFrame:rect];
    if([descView.text isEqualToString:@"Take some note"])
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

- (void) setBackground:(NSString *)imgurl{
//    if(imgurl!=nil && ![imgurl isEqualToString:@""]){
//            UIImage *backimg = [[ImgCache sharedManager] getImgFromCache:imgurl];
//            if(backimg == nil || [backimg isEqual:[NSNull null]]){
//                dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
//                dispatch_async(imgQueue, ^{
//                    UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if(backimg!=nil && ![backimg isEqual:[NSNull null]]){
//                            dectorView.image = backimg;
//                            //[self setLayoutDirty];
//                        }
//                    });
//                });
//                dispatch_release(imgQueue);
//            }else{
//                dectorView.image = backimg;
//            }
//    }
}

- (void) dealloc{
    [super dealloc];
    [dectorView release];
    [headview release];
}

- (void) Close{
    [self dismissModalViewControllerAnimated:YES];
}
- (void) done:(id)sender{
    [delegate setTitle:titleView.text Description:descView.text];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) setCrossTitle:(NSString*)title desc:(NSString*)desc{
    titleView.text=title;
    if(desc!=nil && desc.length>0)
        descView.text=desc;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
