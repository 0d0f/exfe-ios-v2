//
//  ConversationViewController.m
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationViewController.h"
#import "Post.h"
#import "APIConversation.h"
#import "PostCell.h"
#import "ImgCache.h"
#import "Util.h"
#import <RestKit/JSONKit.h>

@interface ConversationViewController ()

@end

@implementation ConversationViewController
@synthesize exfee_id;
@synthesize identity;
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
    [super viewDidLoad];
    [self refreshConversation];
    
    CGRect screenFrame = [self.view frame];
    CGRect toolbarframe=CGRectMake(0, screenFrame.size.height-kDefaultToolbarHeight-kNavBarHeight, screenFrame.size.width, kDefaultToolbarHeight);
    
    inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
    inputToolbar.delegate = self;
    [self.view addSubview:inputToolbar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif    
    cellbackground=[UIImage imageNamed:@"conversation_bg.png"];
    cellsepator=[UIImage imageNamed:@"conversation_line_h.png"];
    avatarframe=[UIImage imageNamed:@"conversation_portrait_frame.png"];
    CGRect _tableviewrect=_tableView.frame;
    _tableviewrect.size.height-=kDefaultToolbarHeight;
    [_tableView setFrame:_tableviewrect];
    _tableView.backgroundColor=[UIColor colorWithPatternImage:cellbackground];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [_tableView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    istimehidden=YES;
    showTimeMode=0;

//    floatTime=[[UILabel alloc] initWithFrame:CGRectMake(0, 80, 60, 26)];
//    floatTime.text=@"label time";
//    [self.view addSubview:floatTime];
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
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
    //	[_tableView release];
	[_posts release];
    [cellbackground release];
    [cellsepator release];
    [avatarframe release];
    [super dealloc];
}
//- (void)viewWillAppear:(BOOL)animated 
//{
//	[super viewWillAppear:animated];
//    
//}
//
//- (void)viewWillDisappear:(BOOL)animated 
//{
//	[super viewWillDisappear:animated];
//	/* No longer listen for keyboard */
//}
- (void)keyboardWillShow:(NSNotification *)notification 
{
    CGRect keyboardEndFrame;
    
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    /* Move the toolbar to above the keyboard */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.origin.y = self.view.frame.size.height - frame.size.height - keyboardEndFrame.size.height;
        
    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height - keyboardEndFrame.size.height - kStatusBarHeight;
    }
	self.inputToolbar.frame = frame;
	[UIView commitAnimations];
//    keyboardIsVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification 
{
    /* Move the toolbar back to bottom of the screen */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect frame = self.inputToolbar.frame;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        frame.origin.y = self.view.frame.size.height - frame.size.height;
    }
    else {
        frame.origin.y = self.view.frame.size.width - frame.size.height;
    }
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
    [APIConversation LoadConversationWithExfeeId:exfee_id updatedtime:updated_at delegate:self];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog (@"conversation touch began");
}
- (void)loadObjectsFromDataStore {
	[_posts release];

	NSFetchRequest* request = [Post fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(postable_type = %@) AND (postable_id = %u)",
                              @"exfee", exfee_id];    
    [request setPredicate:predicate];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    
	_posts = [[Post objectsWithFetchRequest:request] retain];
    [_tableView reloadData];
    [inputToolbar setInputEnabled:YES];
    [inputToolbar hidekeyboard];

}
- (CGSize)textWidthForHeight:(CGFloat)inHeight withAttributedString:(NSAttributedString *)attributedString {
//    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef) attributedString);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributedString);
    int textLength = [attributedString length];
    CFRange range;
    CGFloat maxWidth  = 100.0f;
    CGFloat maxHeight = 10000.0f;
    CGSize constraint = CGSizeMake(maxWidth, maxHeight);
    
    //  checking frame sizes
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, textLength), nil, constraint, &range); 
//    CGFloat ascent;
//    CGFloat descent;
//    CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
//    CGFloat height = ascent+descent;
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


- (void)touchesBegan:(UITapGestureRecognizer*)sender{

    
    CGPoint location = [sender locationInView:self.view];
//    NSLog(@"touch: %f %f",location.x,location.y);
    CGRect showTimeRect=[self.view frame];
    showTimeRect.origin.x=showTimeRect.size.width-60;
    showTimeRect.size.width=60;
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
//                showTimeMode=0;
                Post *post=[_posts objectAtIndex:path.row];
                if(post && !timetextlayer){
                    timetextlayer=[CATextLayer layer];
                    timetextlayer.contentsScale=[[UIScreen mainScreen] scale];
                    timetextlayer.cornerRadius = 2.0;
                    timetextlayer.backgroundColor=[UIColor yellowColor].CGColor;
                    [timetextlayer setAlignmentMode:kCAAlignmentCenter];

                    [_tableView.layer addSublayer:timetextlayer];

                }
//                NSString *timestring=@"";
                int textheight=14;
                NSMutableAttributedString *timeattribstring;
                
                
                if(showTimeMode==0)
                {
                    NSString *timestring=[Util formattedDateRelativeToNow:post.created_at];
                    timeattribstring=[[NSMutableAttributedString alloc] initWithString:timestring];
                    [timeattribstring addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:10] range:NSMakeRange(0,[timestring length])];
                }
                else if(showTimeMode==1)
                {
                    NSDateFormatter *dateformat_to = [[NSDateFormatter alloc] init];
                    [dateformat_to setTimeZone:[NSTimeZone localTimeZone]];
                    [dateformat_to setDateFormat:@"ccc, MMM d"];
                    NSString *datestring=[dateformat_to stringFromDate:post.created_at];
                    [dateformat_to setDateFormat:@"h:mm a"];
                    NSString *timestring=[dateformat_to stringFromDate:post.created_at];
                    
                    [dateformat_to release];
                    timeattribstring=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",datestring,timestring]];
                    [timeattribstring addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:10] range:NSMakeRange(0,[datestring length])];
                    [timeattribstring addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:9] range:NSMakeRange([datestring length]+1,[timestring length])];
                    textheight=28;
                }
                CGSize timesize=[self textWidthForHeight:textheight withAttributedString:timeattribstring];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                [timetextlayer setFrame:CGRectMake(rect.origin.x+rect.size.width-5-(timesize.width+4*2),rect.origin.y+point.y+1,timesize.width+8,timesize.height+2)];
                [timetextlayer setString:timeattribstring];
                [CATransaction commit];

                [timeattribstring release];
                [timetextlayer removeAnimationForKey:@"fadeout"];
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                [self performSelector:@selector(hiddenTime) withObject:nil afterDelay:2];


                
                
//                [((PostCell*)[_tableView cellForRowAtIndexPath:path]) setRelativetime:crosstime_time];
//                [((PostCell*)[_tableView cellForRowAtIndexPath:path]) setShowTime:YES];
            }
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
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN_LEFT +CELL_CONTENT_MARGIN_RIGHT), 20000.0f);
    CGSize size = [post.content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
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
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN_LEFT+CELL_CONTENT_MARGIN_RIGHT), 20000.0f);
    CGSize size = [post.content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 20.0);
    cell.content=post.content;
    cell.text_height=height;
    cell.time=@"";
    cell.background=cellbackground;
    cell.avatarframe=avatarframe;
    cell.separator=cellsepator;
    [cell setShowTime:NO];
    if(post.by_identity.avatar_filename!=nil) {
        dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
        dispatch_async(imgQueue, ^{
            UIImage *avatar = [[ImgCache sharedManager] getImgFrom:post.by_identity.avatar_filename];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                    cell.avatar=avatar;
                }
            });
        });
        dispatch_release(imgQueue);        
    }    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [inputToolbar setInputEnabled:NO];
    [inputToolbar hidekeyboard];
    NSLog(@"select cell");
}
- (void) addPost:(NSString*)content{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *postdict=[NSDictionary dictionaryWithObjectsAndKeys:identity.identity_id,@"by_identity_id",content,@"content",[NSArray arrayWithObjects:nil],@"relative", @"post",@"type", @"iOS",@"via",nil];
    
//    RKParams* postParams = [RKParams params];
//    [postParams setValue:[postdict JSONString] forParam:@"post"];
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/conversation/%u/add?token=%@",exfee_id,app.accesstoken];
    [inputToolbar setInputEnabled:NO];
    NSString *JSON=[postdict JSONString];
    RKParams *params = [RKRequestSerialization serializationWithData:[JSON 
                                                                      dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=params;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                NSLog(@"%@",response.bodyAsString);
                [self refreshConversation];
            }else {
                NSLog(@"%@",response);
                //Check Response Body to get Data!
            }
        };
        request.delegate=self;
    }];
    
}
-(void)inputButtonPressed:(NSString *)inputText{
    [self addPost:inputText];
}
#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"success:%@",objects);

    if(objectLoader.isGET) {
        if([objects count]>0)
        {
            [self loadObjectsFromDataStore];
        }
    }
}
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

@end
