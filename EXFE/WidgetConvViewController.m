//
//  WidgetConvViewController.m
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WidgetConvViewController.h"

#import "Util.h"
#import "EFEntity.h"
#import "EFKit.h"
#import "EFModel.h"

#import "EFCrossTabBarViewController.h"

#import "Post.h"
#import "PostCell.h"


#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (15)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (50)
#define DECTOR_HEIGHT_EXTRA              (20)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define OVERLAP                          (DECTOR_HEIGHT)
#define TITLE_HORIZON_MARGIN             (SMALL_SLOT)
#define TITLE_VERTICAL_MARGIN            (9)

@interface WidgetConvViewController ()

@property (nonatomic, strong) NSMutableArray     *posts;
@property (nonatomic, weak, readonly) Exfee      *exfee;
@property (nonatomic, weak, readonly) Invitation *myInvitation;

@property (nonatomic, strong) ConversationTableView  * tableView;

@end

@implementation WidgetConvViewController
{}
#pragma mark Getter/Setter
@synthesize inputToolbar;

- (Exfee *)exfee
{
    return self.tabBarViewController.cross.exfee;
}

- (Invitation *)myInvitation
{
    return [self.tabBarViewController.cross.exfee getMyInvitation];
}

#pragma mark lifecycle
- (id)initWithModel:(EXFEModel *)exfeModel
{
    self = [super initWithModel:exfeModel];
    if (self) {
        // Custom initialization
        self.posts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    CGRect b = self.view.bounds;
    CGRect a = [[UIScreen mainScreen] applicationFrame];
//    CGRect b = self.initFrame;
    
    CGRect frame = (CGRect){{0.0f, 0.0f}, {CGRectGetWidth(a), CGRectGetHeight(a) - DECTOR_HEIGHT}};
    self.view.frame = frame;

    [super viewDidLoad];
    [Flurry logEvent:@"WIDGET_CONVERSATION"];
    
    self.tableView=[[ConversationTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame) - kDefaultToolbarHeight + 2)];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    hintGroup = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(b), 100, CGRectGetWidth(b), CGRectGetHeight(b) - 100 - 42)];
    {
        UILabel *no_posts = [[UILabel alloc] initWithFrame:CGRectMake(50, 60, 260, 51)];
        no_posts.textAlignment = NSTextAlignmentCenter;
        no_posts.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
        no_posts.text = NSLocalizedString(@"No post in conversation,\n yet.", nil);
        no_posts.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
        no_posts.backgroundColor = [UIColor clearColor];
        no_posts.numberOfLines = 2;
        [hintGroup addSubview:no_posts];
    }
    hintGroup.hidden = YES;
    [self.view  addSubview:hintGroup];
    
    CGRect toolbarframe=CGRectMake(0, CGRectGetHeight(frame) - kDefaultToolbarHeight, CGRectGetWidth(frame), kDefaultToolbarHeight);
    
    inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
    inputToolbar.backgroundColor=[UIColor clearColor];
    inputToolbar.delegate = self;
    inputToolbar.textView.delegate=self;
    [inputToolbar.textView setReturnKeyType:UIReturnKeySend];
    [self.view addSubview:inputToolbar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif    
    cellbackground=[UIImage imageNamed:@"conv_bg.png"];
    cellsepator=[UIImage imageNamed:@"conv_line_h.png"];
    avatarframe=[UIImage imageNamed:@"conv_portrait_frame.png"];
    
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:cellbackground];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    istimehidden=YES;
    showTimeMode=0;
    topcellPath=-1;
    showfloattime=YES;
    inputaccessoryview=[[ConversationInputAccessoryView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];
    [inputaccessoryview setBackgroundColor:[UIColor lightGrayColor]];
    [inputaccessoryview setAlpha: 0.8];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self regObserver];
    
    [self refreshConversation];
    [self loadConversation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.tabBarViewController.cross.conversation_count > 0) {
        [self.tabBarViewController setValue:@(0) forKeyPath:@"cross.conversation_count"];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self unregObserver];
    
}

#pragma mark - Notification Handler

- (void)regObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusbarResize) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadConversationSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadConversationFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNamePostConversationSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNamePostConversationFailure
                                               object:nil];
    
    // we may need to reg before appear ...
    [self.tabBarViewController addObserver:self
                                forKeyPath:@"cross.conversation_count"
                                   options:NSKeyValueObservingOptionNew
                                   context:NULL];
}

- (void)unregObserver
{
    [self.tabBarViewController removeObserver:self
                                   forKeyPath:@"cross.conversation_count"
                                      context:NULL];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"cross.conversation_count"]) {
        
        NSNumber *num= [change objectForKey:NSKeyValueChangeNewKey];
        if (num && ![[NSNull null] isEqual:num]) {
            NSUInteger count = [num unsignedIntegerValue];
            if (count) {
                self.customTabBarItem.shouldPop = YES;
                if (count > 55) {
                    self.customTabBarItem.image = [UIImage imageNamed:@"widget_conv_many_30shine.png"];
                    self.customTabBarItem.highlightImage = [UIImage imageNamed:@"widget_conv_many_30shine.png"];
                    self.customTabBarItem.title = nil;
                } else {
                    self.customTabBarItem.image = [UIImage imageNamed:@"widget_conv_30.png"];
                    self.customTabBarItem.highlightImage = [UIImage imageNamed:@"widget_conv_30shine.png"];
                    self.customTabBarItem.title = [NSString stringWithFormat:@"%u", count];
                }
            } else {
                self.customTabBarItem.shouldPop = NO;
                self.customTabBarItem.image = [UIImage imageNamed:@"widget_conv_30.png"];
                self.customTabBarItem.highlightImage = [UIImage imageNamed:@"widget_conv_30shine.png"];
                self.customTabBarItem.title = nil;
            }
        }
    }
}

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    
    if ([name isEqualToString:kEFNotificationNameLoadConversationSuccess]) {
        [self refreshConversation];
    } else if ([name isEqualToString:kEFNotificationNameLoadConversationFailure]) {
        [self showOrHideHint];
    } else if ([name isEqualToString:kEFNotificationNamePostConversationSuccess]) {
        [self refreshConversation];
//            [self loadConversation];
    } else if ([name isEqualToString:kEFNotificationNamePostConversationFailure]) {
        [self showOrHideHint];
    }
}

#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    keyboardheight = keyboardEndFrame.size.height;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.origin.y = self.view.frame.size.height - frame.size.height - keyboardEndFrame.size.height;
        if(self.tableView.contentSize.height>self.tableView.frame.size.height - keyboardEndFrame.size.height)
        {
            CGRect f = self.tableView.frame;
            f.size.height = CGRectGetHeight(self.tableView.superview.frame) - kDefaultToolbarHeight + 2 - keyboardEndFrame.size.height;
            CGPoint offset = self.tableView.contentOffset;
            offset.y = self.tableView.contentSize.height - CGRectGetHeight(f);
            self.tableView.contentOffset = offset;
            self.tableView.frame = f;
        }
    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height - keyboardEndFrame.size.height - kStatusBarHeight;

    }
	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
    /* Move the toolbar back to bottom of the screen */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        if(self.tableView.contentSize.height>self.tableView.frame.size.height){
            CGRect _tableviewrect=self.tableView.frame;
            //_tableviewrect.origin.y=DECTOR_HEIGHT;
            _tableviewrect.origin.y = 0;
            _tableviewrect.size.height = CGRectGetHeight(self.tableView.superview.frame) - kDefaultToolbarHeight + 2;
            [self.tableView setFrame:_tableviewrect];
        }

    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height;
    }
    keyboardheight=0;

	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
//    keyboardIsVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadConversation {
    NSDate *updated_at = nil;
    if ([self.posts count] > 0) {
        Post *post = [self.posts objectAtIndex:0];
        if (post && post.updated_at != nil) {
            updated_at = post.updated_at;
        }
    }
    
    [self.model loadConversationWithExfee:self.exfee updatedTime:updated_at];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [inputToolbar hidekeyboard];
}

- (void)refreshConversation {
    
    NSArray *list = [self.model getConversationOf:self.exfee];
    if (list) {
        [self.posts removeAllObjects];
        [self.posts addObjectsFromArray: list];
        [self.tableView reloadData];
        if(self.tableView.contentSize.height>self.tableView.frame.size.height) {
            CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            showfloattime=NO;
            [self.tableView setContentOffset:bottomOffset animated:NO];
        }
    }
    [self showOrHideHint];
}

- (CGSize)textWidthForHeight:(CGFloat)inHeight withAttributedString:(NSAttributedString *)attributedString {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge  CFAttributedStringRef) attributedString);
    int textLength = [attributedString length];
    CFRange range;
    CGFloat maxWidth  = 200.0f;
    CGFloat maxHeight = 10000.0f;
    CGSize constraint = CGSizeMake(maxWidth, maxHeight);
    
    //  checking frame sizes
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range);
    CFRelease(framesetter);
    return coreTextSize;//CGSizeMake(width, height);
}

- (void) setShowTime:(BOOL)show{
    
}

- (void) hiddenTime{
    CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeoutAnimation.fillMode = kCAFillModeForwards;
    fadeoutAnimation.duration=0.5;
    fadeoutAnimation.removedOnCompletion =NO;
    fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [timetextlayer addAnimation:fadeoutAnimation forKey:@"fadeout"];
    istimehidden=YES;

}
- (void) hiddenTimeNow{
    CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeoutAnimation.fillMode = kCAFillModeForwards;
    fadeoutAnimation.duration=0.2;
    fadeoutAnimation.removedOnCompletion =NO;
    fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [timetextlayer addAnimation:fadeoutAnimation forKey:@"fadeout"];
//    timetextlayer.opacity=0;
    istimehidden=YES;
    
}

- (void) statusbarResize{
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
    screenframe.size.height-=statusframe.size.height;

//    CGRect toolbarframe=[inputToolbar frame];
//    toolbarframe.origin.y=screenframe.size.height-toolbarframe.size.height-kNavBarHeight-keyboardheight;
    
    CGRect toolbarframe=CGRectMake(0, screenframe.size.height-kDefaultToolbarHeight-DECTOR_HEIGHT-DECTOR_HEIGHT_EXTRA, screenframe.size.width, kDefaultToolbarHeight);
  
    [inputToolbar setFrame:toolbarframe];
    
}

- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    //CGPoint location = [sender locationInView:self.tableView];
    CGPoint location = [sender locationInView:self.view];
    location.y = location.y - CGRectGetMinY(self.tableView.frame);
    CGRect showTimeRect=[self.view frame];
    
// TODO: right 60px for touch area
    if(CGRectContainsPoint(showTimeRect, location))
    {
        CGPoint point=self.tableView.contentOffset;
        NSArray *paths = [self.tableView indexPathsForVisibleRows];
        for(NSIndexPath *path in paths){
            CGRect rect=[self.tableView rectForRowAtIndexPath:path];
            rect.origin.y-=point.y;
            if(CGRectContainsPoint(rect, location))
            {
                if(istimehidden==NO)
                {
                    CGRect timetextlayerrect=timetextlayer.frame;
                    timetextlayerrect.origin.y-=point.y;
                    if(CGRectContainsPoint(timetextlayerrect, location))
                    {
                        showTimeMode+=1;
                        if(showTimeMode>1)
                            showTimeMode=0;
                    }
                }
                else{
                   showTimeMode=0; 
                }
                    
                istimehidden=NO;
                Post *post=[self.posts objectAtIndex:path.row];
              
                if(post && !timetextlayer){
                    timetextlayer=[CATextLayer layer];
                    timetextlayer.contentsScale=[[UIScreen mainScreen] scale];
                    timetextlayer.cornerRadius = 2.0;
                    timetextlayer.backgroundColor=FONT_COLOR_232737.CGColor;
                    [timetextlayer setAlignmentMode:kCAAlignmentCenter];
                    [self.tableView.layer addSublayer:timetextlayer];
                }
                int textheight=14;
                NSMutableAttributedString *timeattribstring=nil;
                CTFontRef timefontref= CTFontCreateWithName(CFSTR("HelveticaNeue"), 10.0, NULL);
                CTFontRef timefontref9= CTFontCreateWithName(CFSTR("HelveticaNeue"), 9.0, NULL);

                if(showTimeMode==0)
                {
                    
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
                    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:post.created_at];
                    NSString *timestring= [[DateTimeUtil GetRelativeTime:comps format:1] capitalizedString];
                    
                    timeattribstring=[[NSMutableAttributedString alloc] initWithString:timestring];
                    [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)timefontref range:NSMakeRange(0,[timestring length])];
                    [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[timestring length])];
                }
                else if(showTimeMode==1)
                {
                    NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
                    NSString *language = [NSLocale preferredLanguages][0];
                    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:language];
                    [dateformat_to setLocale:locale];

                    
                    [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
                    [dateformat_to setDateFormat:@"ccc, MMM d"];
                    NSString *datestring=[dateformat_to stringFromDate:post.created_at];
                    [dateformat_to setDateFormat:@"h:mm a"];
                    NSString *timestring=[dateformat_to stringFromDate:post.created_at];
                    timeattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",datestring,timestring]];
                    [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)timefontref range:NSMakeRange(0,[datestring length])];
                    [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[datestring length])];

                    [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)timefontref9 range:NSMakeRange([datestring length]+1,[timestring length])];
                    [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_CCC.CGColor range:NSMakeRange([datestring length]+1,[timestring length])];
                    textheight=28;
                }
                CFRelease(timefontref);
                CFRelease(timefontref9);

                CGSize timesize=[self textWidthForHeight:textheight withAttributedString:timeattribstring];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                if(rect.size.height<=40 && timesize.height>20)
                    [timetextlayer setFrame:CGRectMake(rect.origin.x+rect.size.width-5-(timesize.width+4*2),rect.origin.y+point.y+12-5,timesize.width+8,timesize.height+2)];
                else
                    [timetextlayer setFrame:CGRectMake(rect.origin.x+rect.size.width-5-(timesize.width+4*2),rect.origin.y+point.y+12,timesize.width+8,timesize.height+2)];
                [timetextlayer setString:timeattribstring];
                [CATransaction commit];

                [timetextlayer removeAnimationForKey:@"fadeout"];
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                [self performSelector:@selector(hiddenTime) withObject:nil afterDelay:2];
            }
        }
    }
}
#pragma mark UIExpandingTextViewDelegate methods
- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView{
    [self addPost:expandingTextView.internalTextView.text];
    [expandingTextView clearText];
    return YES;
}
-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    [inputToolbar expandingTextView:expandingTextView willChangeHeight:height];
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    showfloattime=YES;
    [inputToolbar hidekeyboard];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(showfloattime==YES)
    {
        CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeoutAnimation.fillMode = kCAFillModeForwards;
        fadeoutAnimation.duration=0.5;
        fadeoutAnimation.removedOnCompletion =NO;
        fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [floattimetextlayer addAnimation:fadeoutAnimation forKey:@"fadeout"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(istimehidden==NO)
    {
        [timetextlayer removeAnimationForKey:@"fadeout"];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self hiddenTimeNow];
    }
    
    CGPoint point=self.tableView.contentOffset;
    NSArray *paths = [self.tableView indexPathsForVisibleRows];
    if(paths!=nil && [paths count]>0)
    {
        NSIndexPath *path=(NSIndexPath*)[paths objectAtIndex:0];
        if(paths!=nil && topcellPath!=path.row && point.y>0 && showfloattime==YES)
        {
            if(!floattimetextlayer){
                floattimetextlayer=[CATextLayer layer];
                floattimetextlayer.contentsScale=[[UIScreen mainScreen] scale];
                floattimetextlayer.cornerRadius = 2.0;
                floattimetextlayer.backgroundColor=FONT_COLOR_232737.CGColor;
                [floattimetextlayer setAlignmentMode:kCAAlignmentCenter];
                [floattimetextlayer setFrame:CGRectMake(self.view.frame.size.width - 5 - (40 + 4*2), 25, 40 + 8, 24 + 2)];
                [self.view.layer addSublayer:floattimetextlayer];
            }
            
            [floattimetextlayer removeAnimationForKey:@"fadeout"];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            Post *post = [self.posts objectAtIndex:path.row];
            NSDate *post_created_at = post.created_at;

            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [gregorian setTimeZone:[NSTimeZone localTimeZone]];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:post_created_at];
            NSString *relative= [[DateTimeUtil GetRelativeTime:comps format:1] capitalizedString];

            NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
            [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
            [dateformat_to setDateFormat:@"h:mm a MMM d"];
            NSString *datestring=[dateformat_to stringFromDate:post_created_at];

            NSMutableAttributedString *timeattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",relative,datestring]];
            CTFontRef timefontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 10.0, NULL);
            CTFontRef timefontref9=CTFontCreateWithName(CFSTR("HelveticaNeue"), 9.0, NULL);
            [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)timefontref range:NSMakeRange(0,[relative length])];
            [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[relative length])];

            [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)timefontref9 range:NSMakeRange([relative length]+1,[datestring length])];
            [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_CCC.CGColor range:NSMakeRange([relative length]+1,[datestring length])];
            CFRelease(timefontref);
            CFRelease(timefontref9);
            CGSize timesize=[self textWidthForHeight:28 withAttributedString:timeattribstring];
            [floattimetextlayer setFrame:CGRectMake(self.view.frame.size.width - 5 - (timesize.width + 4 * 2),  25, timesize.width + 8, timesize.height + 2)];
            [floattimetextlayer setString:timeattribstring];
            topcellPath=path.row;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        if (scrollView.contentOffset.y <= -5 || scrollView.contentOffset.y >= scrollView.contentSize.height + 5) {
            [self loadConversation];
        }
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [self.posts count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post=[self.posts objectAtIndex:indexPath.row];
    NSString *name=post.by_identity.nickname;
    if(name==nil || [name isEqualToString:@""])
        name=post.by_identity.name;

    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN_LEFT +CELL_CONTENT_MARGIN_RIGHT), 20000.0f);

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",name,post.content]];
    CTFontRef boldfontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 14.0, NULL);
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)boldfontref range:NSMakeRange(0,[name length])];
    CTFontRef fontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 14.0, NULL);
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontref range:NSMakeRange([name length]+2,[post.content length])];

    CFRelease(boldfontref);
    CFRelease(fontref);
    
    CGSize size= [CTUtil CTSizeOfString:attributedString minLineHeight:20 linespacing:0 constraint:constraint];
    CGFloat height = MAX(size.height, 20.0);
    return height + (CELL_CONTENT_MARGIN_TOP+CELL_CONTENT_MARGIN_BOTTOM);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"Post Cell";
    PostCell *cell =[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
	if (nil == cell) {
        cell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

    Post *post=[self.posts objectAtIndex:indexPath.row];
    cell.content=[post.content stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.time=@"";
    cell.background=cellbackground;
    cell.avatarframe=avatarframe;
    cell.identity_name=post.by_identity.nickname;
    if(cell.identity_name==nil || [cell.identity_name isEqualToString:@""])
        cell.identity_name=post.by_identity.name;
    if(indexPath.row!=0)
        cell.separator=cellsepator;
    [cell setShowTime:NO];
    
    NSString *imageKey = post.by_identity.avatar_filename;
    UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
    
    if (!imageKey) {
        cell.avatar = defaultImage;
    } else {
        [[EFDataManager imageManager] loadImageForView:cell
                                      setImageSelector:@selector(setAvatar:)
                                           placeHolder:defaultImage
                                                   key:imageKey
                                       completeHandler:nil];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [inputToolbar hidekeyboard];
}

- (void) addPost:(NSString*)content{
    [Flurry logEvent:@"SEND_CONVERSATION"];
    
    if (content.length == 0) {
        return;
    };
    [self.model postConversation:content by:self.myInvitation.identity on:self.exfee];
}

- (void)showOrHideHint{
    hintGroup.hidden = (self.posts.count > 0);
}
@end
