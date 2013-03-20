//
//  WidgetConvViewController.m
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WidgetConvViewController.h"
#import "Post.h"
#import "APIConversation.h"
#import "PostCell.h"
#import "ImgCache.h"
#import "Util.h"

#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (15)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (44)
#define DECTOR_HEIGHT_EXTRA              (LARGE_SLOT)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define OVERLAP                          (DECTOR_HEIGHT)
#define TITLE_HORIZON_MARGIN             (SMALL_SLOT)
#define TITLE_VERTICAL_MARGIN            (9)

@interface WidgetConvViewController ()

@end

@implementation WidgetConvViewController
@synthesize exfee_id;
@synthesize myIdentity;
@synthesize inputToolbar;


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
    CGRect b = self.view.bounds;
    CGRect a = [[UIScreen mainScreen] applicationFrame];
    CGRect f = CGRectMake(0, DECTOR_HEIGHT, CGRectGetWidth(a), CGRectGetHeight(a) - DECTOR_HEIGHT);
    [self.view setFrame:f];

    [super viewDidLoad];
    _tableView=[[ConversationTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(f), CGRectGetHeight(f) - kDefaultToolbarHeight + 2)];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    [self refreshConversation];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [_tableView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    hintGroup = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(b), 100, CGRectGetWidth(b), CGRectGetHeight(b) - 100 - 42)];
    {
        UILabel *no_posts = [[UILabel alloc] initWithFrame:CGRectMake(50, 60, 260, 51)];
        no_posts.textAlignment = NSTextAlignmentCenter;
        no_posts.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
        no_posts.text = @"No post in conversation,\n yet.";
        no_posts.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
        no_posts.backgroundColor = [UIColor clearColor];
        no_posts.numberOfLines = 2;
        [hintGroup addSubview:no_posts];
        [no_posts release];
    }
    [self.view  addSubview:hintGroup];
    
    CGRect toolbarframe=CGRectMake(0, CGRectGetHeight(f) - kDefaultToolbarHeight, CGRectGetWidth(f), kDefaultToolbarHeight);
    
    inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
    inputToolbar.backgroundColor=[UIColor clearColor];
    inputToolbar.delegate = self;
    inputToolbar.textView.delegate=self;
    [inputToolbar.textView.internalTextView setReturnKeyType:UIReturnKeySend];
    [self.view addSubview:inputToolbar];
//    [self statusbarResize];
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
//    CGRect _tableviewrect=_tableView.frame;
//    _tableviewrect.size.height=_tableviewrect.size.height-kDefaultToolbarHeight-44;
//    [_tableView setFrame:_tableviewrect];
    _tableView.backgroundColor=[UIColor colorWithPatternImage:cellbackground];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    istimehidden=YES;
    showTimeMode=0;
    topcellPath=-1;
    showfloattime=YES;
    inputaccessoryview=[[ConversationInputAccessoryView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];
    [inputaccessoryview setBackgroundColor:[UIColor lightGrayColor]];
    [inputaccessoryview setAlpha: 0.8];
    [Flurry logEvent:@"VIEW_CONVERSATION"];
//    floatTime=[[UILabel alloc] initWithFrame:CGRectMake(0, 80, 60, 26)];
//    floatTime.text=@"label time";
//    [self.view addSubview:floatTime];
    
    
    
    
    [self showOrHideHint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusbarResize) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    RKObjectManager* manager =[RKObjectManager sharedManager];
    [manager.operationQueue cancelAllOperations];
    //	[_tableView release];
	[_posts release];
    [cellbackground release];
    [cellsepator release];
    [avatarframe release];
    [_tableView release];
    [inputToolbar release];
    
    [super dealloc];
}

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
        if(_tableView.contentSize.height>_tableView.frame.size.height - keyboardEndFrame.size.height)
        {
            CGRect f = _tableView.frame;
            f.size.height = CGRectGetHeight(_tableView.superview.frame) - kDefaultToolbarHeight + 2 - keyboardEndFrame.size.height;
            CGPoint offset = _tableView.contentOffset;
            offset.y = _tableView.contentSize.height - CGRectGetHeight(f);
            _tableView.contentOffset = offset;
            _tableView.frame = f;
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
        if(_tableView.contentSize.height>_tableView.frame.size.height){
            CGRect _tableviewrect=_tableView.frame;
            //_tableviewrect.origin.y=DECTOR_HEIGHT;
            _tableviewrect.origin.y = 0;
            _tableviewrect.size.height = CGRectGetHeight(_tableView.superview.frame) - kDefaultToolbarHeight + 2;
//          NSLog(@"tableview height:%f",_tableView.frame.size.height);
            [_tableView setFrame:_tableviewrect];
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
-(void) refreshConversation{
    if(_posts==nil)
        [self loadObjectsFromDataStore];
    NSString *updated_at=@"";
    if(_posts!=nil && [_posts count]>0)
    {
        Post *post=[_posts objectAtIndex:0];
        if(post && post.updated_at!=nil)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            updated_at = [formatter stringFromDate:post.updated_at];
            [formatter release];
        }
    }
  [APIConversation LoadConversationWithExfeeId:exfee_id updatedtime:updated_at success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    Meta *meta=(Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
    if(meta!=nil){
      if([meta.code intValue]==200){
        [self loadObjectsFromDataStore];
      }
    }else{
      //show error hint
    }

  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    
  }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [inputToolbar hidekeyboard];
}
- (void)loadObjectsFromDataStore {
	[_posts release];

  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
  NSPredicate *predicate = [NSPredicate
                            predicateWithFormat:@"(postable_type = %@) AND (postable_id = %u)",
                            @"exfee", exfee_id];

  [request setPredicate:predicate];
  
  
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  _posts = [[objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil] retain];

  
    [self showOrHideHint];
    [_tableView reloadData];
    if(_tableView.contentSize.height>_tableView.frame.size.height) {
        CGPoint bottomOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
        showfloattime=NO;
        [_tableView setContentOffset:bottomOffset animated:NO];
    }
    [inputToolbar setInputEnabled:YES];
    [inputToolbar hidekeyboard];

}
- (CGSize)textWidthForHeight:(CGFloat)inHeight withAttributedString:(NSAttributedString *)attributedString {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributedString);
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
    //CGPoint location = [sender locationInView:_tableView];
    CGPoint location = [sender locationInView:self.view];
    location.y = location.y - CGRectGetMinY(_tableView.frame);
    CGRect showTimeRect=[self.view frame];
    
// TODO: right 60px for touch area
    if(CGRectContainsPoint(showTimeRect, location))
    {
        CGPoint point=_tableView.contentOffset;
        NSArray *paths = [_tableView indexPathsForVisibleRows];
        for(NSIndexPath *path in paths){
            CGRect rect=[_tableView rectForRowAtIndexPath:path];
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
                Post *post=[_posts objectAtIndex:path.row];
                if(post && !timetextlayer){
                    timetextlayer=[CATextLayer layer];
                    timetextlayer.contentsScale=[[UIScreen mainScreen] scale];
                    timetextlayer.cornerRadius = 2.0;
                    timetextlayer.backgroundColor=FONT_COLOR_232737.CGColor;
                    [timetextlayer setAlignmentMode:kCAAlignmentCenter];
                    [_tableView.layer addSublayer:timetextlayer];
                }
                int textheight=14;
                NSMutableAttributedString *timeattribstring=nil;
                CTFontRef timefontref= CTFontCreateWithName(CFSTR("HelveticaNeue"), 10.0, NULL);
                CTFontRef timefontref9= CTFontCreateWithName(CFSTR("HelveticaNeue"), 9.0, NULL);

                if(showTimeMode==0)
                {
                    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                    [dateformat setDateFormat:@"yyyy-MM-dd"];
                    NSString *datestr=[dateformat stringFromDate:post.created_at];
                    [dateformat setDateFormat:@"HH:mm:ss"];
                    NSString *timestr=[dateformat stringFromDate:post.created_at];
                    [dateformat release];
                    NSString *timestring=[Util EXRelativeFromDateStr:datestr TimeStr:timestr type:@"conversation" localTime:NO];
                    timeattribstring=[[NSMutableAttributedString alloc] initWithString:timestring];
                    [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)timefontref range:NSMakeRange(0,[timestring length])];
                    [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[timestring length])];
                }
                else if(showTimeMode==1)
                {
                    NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
                    NSLocale *locale_to=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                    [dateformat_to setLocale:locale_to];

                    
                    [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
                    [dateformat_to setDateFormat:@"ccc, MMM d"];
                    NSString *datestring=[dateformat_to stringFromDate:post.created_at];
                    [dateformat_to setDateFormat:@"h:mm a"];
                    NSString *timestring=[dateformat_to stringFromDate:post.created_at];
                    [locale_to release];
                    [dateformat_to release];
                    timeattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",datestring,timestring]];
                    [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)timefontref range:NSMakeRange(0,[datestring length])];
                    [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[datestring length])];

                    [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)timefontref9 range:NSMakeRange([datestring length]+1,[timestring length])];
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

                [timeattribstring release];
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
    return YES;
}
-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    [inputToolbar expandingTextView:expandingTextView willChangeHeight:height];
}

#pragma mark UIScrollView methods
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
    
    CGPoint point=_tableView.contentOffset;
    NSArray *paths = [_tableView indexPathsForVisibleRows];
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
            Post *post=[_posts objectAtIndex:path.row];

            NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
            [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateformat setDateFormat:@"yyyy-MM-dd"];
            NSString *datestr=[dateformat stringFromDate:post.created_at];
            [dateformat setDateFormat:@"HH:mm:ss"];
            NSString *timestr=[dateformat stringFromDate:post.created_at];
            [dateformat release];
            NSString *relative=[Util EXRelativeFromDateStr:datestr TimeStr:timestr type:@"conversation" localTime:NO];

            NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
            [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
            [dateformat_to setDateFormat:@"h:mm a MMM d"];
            NSString *datestring=[dateformat_to stringFromDate:post.created_at];
            [dateformat_to release];

            NSMutableAttributedString *timeattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",relative,datestring]];
            CTFontRef timefontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 10.0, NULL);
            CTFontRef timefontref9=CTFontCreateWithName(CFSTR("HelveticaNeue"), 9.0, NULL);
            [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)timefontref range:NSMakeRange(0,[relative length])];
            [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[relative length])];

            [timeattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)timefontref9 range:NSMakeRange([relative length]+1,[datestring length])];
            [timeattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_CCC.CGColor range:NSMakeRange([relative length]+1,[datestring length])];
            CFRelease(timefontref);
            CFRelease(timefontref9);
            CGSize timesize=[self textWidthForHeight:28 withAttributedString:timeattribstring];
            [floattimetextlayer setFrame:CGRectMake(self.view.frame.size.width - 5 - (timesize.width + 4 * 2),  25, timesize.width + 8, timesize.height + 2)];
            [floattimetextlayer setString:timeattribstring];
            [timeattribstring release];
            topcellPath=path.row;
        }
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_posts count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post=[_posts objectAtIndex:indexPath.row];
    NSString *name=post.by_identity.nickname;
    if(name==nil || [name isEqualToString:@""])
        name=post.by_identity.name;

    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN_LEFT +CELL_CONTENT_MARGIN_RIGHT), 20000.0f);

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@",name,post.content]];
    CTFontRef boldfontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 14.0, NULL);
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(id)boldfontref range:NSMakeRange(0,[name length])];
    CTFontRef fontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 14.0, NULL);
    [attributedString addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref range:NSMakeRange([name length]+2,[post.content length])];

    CFRelease(boldfontref);
    CFRelease(fontref);
    
    CGSize size= [CTUtil CTSizeOfString:attributedString minLineHeight:20 linespacing:0 constraint:constraint];
    [attributedString release];
    CGFloat height = MAX(size.height, 20.0);
    return height + (CELL_CONTENT_MARGIN_TOP+CELL_CONTENT_MARGIN_BOTTOM);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"Post Cell";
    PostCell *cell =[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
	if (nil == cell) {
        cell = [[[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

    Post *post=[_posts objectAtIndex:indexPath.row];
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
    if(post.by_identity.avatar_filename!=nil) {
        
        UIImage *avatar = [[ImgCache sharedManager] getImgFromCache:post.by_identity.avatar_filename];
        if(avatar==nil || [avatar isEqual:[NSNull null]]){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [[ImgCache sharedManager] getImgFrom:post.by_identity.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                        cell.avatar = avatar;
                    }else{
                        cell.avatar = [UIImage imageNamed:@"portrait_default.png"];
                    }
                });
            });
            dispatch_release(imgQueue);
        }
        else{
            cell.avatar=avatar;
        }
    }else{
        cell.avatar = [UIImage imageNamed:@"portrait_default.png"];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [inputToolbar setInputEnabled:NO];
    [inputToolbar hidekeyboard];
}
- (void) addPost:(NSString*)content{
    [Flurry logEvent:@"SEND_CONVERSATION"];

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *postdict=[NSDictionary dictionaryWithObjectsAndKeys:myIdentity.identity_id,@"by_identity_id",content,@"content",[NSArray arrayWithObjects:nil],@"relative", @"post",@"type", @"iOS",@"via",nil];

    NSString *endpoint = [NSString stringWithFormat:@"%@/conversation/%u/add?token=%@",API_ROOT,exfee_id,app.accesstoken];
    RKObjectManager *manager=[RKObjectManager sharedManager];
    manager.HTTPClient.parameterEncoding=AFJSONParameterEncoding;
    [manager.HTTPClient postPath:endpoint parameters:postdict success:^(AFHTTPRequestOperation *operation, id responseObject) {
      if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]){
          [self refreshConversation];
          [inputToolbar.textView clearText];
      }else {
      }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [inputToolbar setInputEnabled:YES];
      NSString *errormsg;
      if(error.code==2)
          errormsg=@"A connection failure has occurred.";
      else
          errormsg=@"Could not connect to the server.";
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alert show];
      [alert release];

    }];
}
-(void)inputButtonPressed:(NSString *)inputText{
    [self addPost:inputText];
}

- (void)showOrHideHint{
    if (_posts == nil || _posts.count == 0) {
        hintGroup.hidden = NO;
    }else{
        hintGroup.hidden = YES;
    }
}

@end
