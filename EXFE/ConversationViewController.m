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
#import "JSONKit.h"

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
//    [self addPost:@"test"];

    /* Calculate screen size */
//    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
//    self.view = [[UIView alloc] initWithFrame:screenFrame];
//    self.view.backgroundColor = [UIColor whiteColor];
    /* Create toolbar */
//    self.inputToolbar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, screenFrame.size.height-kDefaultToolbarHeight, screenFrame.size.width, kDefaultToolbarHeight)];
//    [self.view addSubview:self.inputToolbar];
//    inputToolbar.delegate = self;
    
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
//    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x,_tableView.frame.origin.y-50,_tableView.frame.size.width,_tableView.frame.size.height/2)];

//    _tableView.frame

//    NSLog(@"%@",identity);
    //[self loadObjectsFromDataStore];
    // Do any additional setup after loading the view from its nib.
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
            //        2012-04-24 07:06:13 +0000
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            updated_at = [formatter stringFromDate:post.updated_at];
            [formatter release];
            NSLog(@"%@",updated_at);
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

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_posts count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post=[_posts objectAtIndex:indexPath.row];
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN_LEFT +CELL_CONTENT_MARGIN_RIGHT), 20000.0f);
    CGSize size = [post.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
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
    CGSize size = [post.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MAX(size.height, 20.0);
//    NSLog(@"height: %f",height );
    cell.content=post.content;
    cell.text_height=height;
    
    cell.time=[Util formattedDateRelativeToNow:post.created_at];
    
//    NSLog(@"post.post.time:%@",post_time);
    
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
//    + (NSString *) formattedLongDateRelativeToNow:(NSString*)datestr
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
//    NSString *dateString = [dateFormatter stringFromDate:post.created_at];
//    [dateFormatter release];
//    cell.time=[Util formattedLongDateRelativeToNow:dateString];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [inputToolbar setInputEnabled:NO];
    [inputToolbar hidekeyboard];
//    NSLog(@"111");
}
- (void) addPost:(NSString*)content{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *postdict=[NSDictionary dictionaryWithObjectsAndKeys:identity.identity_id,@"by_identity_id",content,@"content",[NSArray arrayWithObjects:nil],@"relative", @"post",@"type", @"iOS",@"via",nil];
    
    RKParams* postParams = [RKParams params];
    [postParams setValue:[postdict JSONString] forParam:@"post"];
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/conversation/%u/add?token=%@",exfee_id,app.accesstoken];
    [inputToolbar setInputEnabled:NO];

    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=postParams;
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
