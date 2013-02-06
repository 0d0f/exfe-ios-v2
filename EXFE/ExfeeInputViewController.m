//
//  ExfeeInputViewController.m
//  EXFE
//
//  Created by huoju on 7/25/12.
//
//

#import "ExfeeInputViewController.h"

@interface ExfeeInputViewController ()

@end

@implementation ExfeeInputViewController
@synthesize gatherview;

static char identitykey;
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
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    screenframe.size.height-=20;
    [self.view setFrame:screenframe];

    suggestionTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 77, 320, self.view.frame.size.height-77) style:UITableViewStylePlain];
    suggestionTable.dataSource=self;
    suggestionTable.delegate=self;
    [self.view addSubview:suggestionTable];
    
    address=[[AddressBook alloc] init];

    
    
    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 77)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];

    [self.view addSubview:toolbar];

    [self.view setBackgroundColor:[UIColor colorWithRed:221/255.0f green:221/255.0f blue:221/255.0f alpha:1]];
    btnLocal=[UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnLocal setFrame:CGRectMake(0, 38, self.view.frame.size.width/2, 39)];
    [btnLocal addTarget:self action:@selector(reloadLocalAddressBook) forControlEvents:UIControlEventTouchUpInside];
    [btnLocal setTitle:@"Phone contacts" forState:UIControlStateNormal];
    [btnLocal.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [btnLocal setTitleColor:FONT_COLOR_51 forState:UIControlStateNormal];

    
    [btnLocal setBackgroundImage:[[UIImage imageNamed:@"tab_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0,10)] forState:UIControlStateNormal];

    [self.view addSubview:btnLocal];

    btnEXFE=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnEXFE setFrame:CGRectMake(self.view.frame.size.width/2, 38, self.view.frame.size.width/2, 39)];
    [btnEXFE addTarget:self action:@selector(reloadExfeAddressBook) forControlEvents:UIControlEventTouchUpInside];
    [btnEXFE setTitle:@"Exfees" forState:UIControlStateNormal];
    [btnEXFE.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [btnEXFE setTitleColor:FONT_COLOR_51 forState:UIControlStateNormal];
    [btnEXFE setBackgroundImage:nil forState:UIControlStateNormal];
    [self.view addSubview:btnEXFE];
    
    selectedRowIndex=-1;
    
    exfeeList=[[EXBubbleScrollView alloc] initWithFrame:CGRectMake(28, 7, 232, 31)];
    [exfeeList setContentSize:CGSizeMake(exfeeList.frame.size.width, 30)];
    [exfeeList setEXBubbleDelegate:self];
    
    inputframeview=[[UIImageView alloc] initWithFrame:exfeeList.frame];
    inputframeview.image=[UIImage imageNamed:@"textfield.png"];
    inputframeview.contentMode    = UIViewContentModeScaleToFill;
    inputframeview.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:inputframeview];
    [toolbar addSubview:exfeeList];
    
    UIButton *btncancel=[UIButton buttonWithType:UIButtonTypeCustom];
    [btncancel setFrame:CGRectMake(0, 0, 20, 44)];
    btncancel.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btncancel setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btncancel setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btncancel addTarget:self action:@selector(Close) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:btncancel];
    
    inputleftmask=[[UIImageView alloc] initWithFrame:CGRectMake(exfeeList.frame.origin.x,exfeeList.frame.origin.y , 40, 30)];
    inputleftmask.image=[UIImage imageNamed:@"exfee_inputfield.png"];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *roundedPath =
    [UIBezierPath bezierPathWithRoundedRect:inputleftmask.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(5.f, 5.f)];
    maskLayer.path = [roundedPath CGPath];
    inputleftmask.layer.mask=maskLayer;
    inputleftmask.layer.masksToBounds = YES;
    [inputleftmask setHidden:NO];
    [toolbar addSubview:inputleftmask];

    
    exfeeList.layer.cornerRadius=5;
    [self changeLeftIconWhite:NO];
  
    UIImage *btn_dark = [UIImage imageNamed:@"btn_dark.png"];
    UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(255+5+5, 7, 50, 31)];
    backimg.image=btn_dark;
    backimg.contentMode=UIViewContentModeScaleToFill;
    backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:backimg];
    [backimg release];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Add" forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    doneButton.frame = CGRectMake(255+5+5, 7, 50, 30);
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0,5)] forState:UIControlStateNormal];

    [toolbar addSubview:doneButton];
    addressbookType=LOCAL_ADDRESSBOOK;
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [docsPath stringByAppendingPathComponent:@"localcontacts"];
    localcontacts=[[NSKeyedUnarchiver unarchiveObjectWithFile:filename] copy];
    filteredlocalcontacts=[localcontacts retain];

}

- (void)viewDidAppear:(BOOL)animated{
//    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filename = [docsPath stringByAppendingPathComponent:@"localcontacts"];
    NSDate *localaddressbook_read_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"localaddressbook_read_at"];
    int offset=[[NSDate date] timeIntervalSince1970]-[localaddressbook_read_at timeIntervalSince1970];
    
    //TODO: offset=10000 for debug, must be deleted before release.
//    offset=100000;
    if(offset > 1*24*60*60){
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode=MBProgressHUDModeCustomView;
        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
        [bigspin startAnimating];
        hud.customView=bigspin;
        [bigspin release];
        hud.labelText = @"Loading";

        dispatch_queue_t loadingQueue = dispatch_queue_create("loading addressbook", NULL);
        dispatch_async(loadingQueue, ^{
            [address UpdatePeople:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSFetchRequest* request = [LocalContact fetchRequest];
                if(filteredlocalcontacts!=nil)
                   [filteredlocalcontacts release];
               filteredlocalcontacts=[[LocalContact objectsWithFetchRequest:request] retain];
                if(addressbookType==LOCAL_ADDRESSBOOK)
                    [self reloadLocalAddressBook];

                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self copyMoreContactsFromIdx:100];
            });
        });
        dispatch_release(loadingQueue);
    }else{
        NSFetchRequest* request = [LocalContact fetchRequest];
        if(filteredlocalcontacts!=nil)
            [filteredlocalcontacts release];
        filteredlocalcontacts=[[LocalContact objectsWithFetchRequest:request] retain];
        if(addressbookType==LOCAL_ADDRESSBOOK)
            [self reloadLocalAddressBook];

    }
}

- (void) copyMoreContactsFromIdx:(int)idx{
    dispatch_queue_t loadingQueue = dispatch_queue_create("loading addressbook", NULL);
    dispatch_async(loadingQueue, ^{
        [address CopyAllPeopleFrom:idx];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSFetchRequest* request = [LocalContact fetchRequest];
            if(filteredlocalcontacts!=nil)
                [filteredlocalcontacts release];
            filteredlocalcontacts=[[LocalContact objectsWithFetchRequest:request] retain];
            if(addressbookType==LOCAL_ADDRESSBOOK)
                [self reloadLocalAddressBook];

            if(idx+100<address.contactscount){
                [self copyMoreContactsFromIdx:idx+100];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date]  forKey:@"localaddressbook_read_at"];
            }
        });
    });
    dispatch_release(loadingQueue);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [exfeeList hiddenkeyboard];
}

- (void) changeLeftIconWhite:(BOOL)iswhite{
    if(inputlefticon==nil)
    {
        inputlefticon=[[UIImageView alloc] initWithFrame:CGRectMake(exfeeList.frame.origin.x+6, 14, 18, 18)];
        [toolbar addSubview:inputlefticon];
    }
    
    if(iswhite==YES){
        inputlefticon.image=[UIImage imageNamed:@"exfee_18_white.png"];
        [inputleftmask setHidden:NO];
    }
    else{
        inputlefticon.image=[UIImage imageNamed:@"exfee_18.png"];
        [inputleftmask setHidden:YES];
    }

}
- (void) reloadLocalAddressBook{
    [btnLocal setBackgroundImage:[[UIImage imageNamed:@"tab_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0,10)] forState:UIControlStateNormal];
    [btnEXFE setBackgroundImage:nil forState:UIControlStateNormal];

    addressbookType=LOCAL_ADDRESSBOOK;
    [expandExfeeView setHidden:YES];
    expandCellHeight=44;
    [suggestionTable reloadData];
}

- (void) reloadExfeAddressBook{
    
    [btnEXFE setBackgroundImage:[[UIImage imageNamed:@"tab_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0,10)] forState:UIControlStateNormal];
    [btnLocal setBackgroundImage:nil forState:UIControlStateNormal];

    addressbookType=EXFE_ADDRESSBOOK;
    [self loadIdentitiesFromDataStore:@""];
    [expandExfeeView setHidden:YES];
    expandCellHeight=44;
    [suggestionTable reloadData];
}

- (void) ErrorHint:(BOOL)hidden content:(NSString*)content{
    CGRect suggectrect=[suggestionTable frame];
    if(hidden==YES){
        suggectrect.origin.y-=44;
        suggectrect.size.height+=44;
    }else{
        suggectrect.origin.y+=44;
        suggectrect.size.height-=44;
    }
    if(errorHint==nil){
        errorHint=[[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 44)];
        [self.view addSubview:errorHint];
        errorHinticon=[[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 18, 18)];
        errorHinticon.image=[UIImage imageNamed:@"exclamation.png"];
        [errorHint addSubview:errorHinticon];
        errorHintLabel=[[UILabel alloc] initWithFrame:CGRectMake(12+18+6+6, 13,self.view.frame.size.width-(12+18+6+6)-5 , 21)];
        errorHintLabel.backgroundColor=[UIColor clearColor];
        [errorHintLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [errorHintLabel setTextColor:[UIColor colorWithRed:204/255.0f green:81/255.0f blue:71/255.0f alpha:1]];
        [errorHintLabel setShadowColor:[UIColor blackColor]];
        [errorHintLabel setShadowOffset:CGSizeMake(0, 1)];
        [errorHint addSubview:errorHintLabel];
    }
    errorHintLabel.text=content;
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    [suggestionTable setFrame:suggectrect];
    [UIView commitAnimations];
    
    if(hidden==YES){
        [errorHint setHidden:YES];
        CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];

        fadeoutAnimation.fillMode = kCAFillModeForwards;
        fadeoutAnimation.duration=0.5;
        fadeoutAnimation.removedOnCompletion =NO;
        fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [errorHint.layer addAnimation:fadeoutAnimation forKey:@"fadeout"];
    }else{
        [errorHint setHidden:NO];
        CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeoutAnimation.fillMode = kCAFillModeForwards;
        fadeoutAnimation.duration=0.5;
        fadeoutAnimation.removedOnCompletion =NO;
        fadeoutAnimation.fromValue=[NSNumber numberWithFloat:0.0];
        fadeoutAnimation.toValue=[NSNumber numberWithFloat:1.0];
        [errorHint.layer addAnimation:fadeoutAnimation forKey:@"fadein"];
    }


}
- (void)dealloc {
    [inputlefticon release];
    [errorHinticon release];
    [errorHintLabel release];
    [errorHint release];
    [address release];
    [expandExfeeViewShadow release];
    [super dealloc];
}
- (BOOL) showErrorHint{
    //TODO: replace with new alert view
//    if([(NewGatherViewController*)gatherview exfeeIdentitiesCount]+[exfeeList bubblecount]>=12){
//        if(errorHint==nil||[errorHint isHidden]==YES){
//            [self ErrorHint:NO content:@"12 exfees maximum"];
//        }
//        return YES;
//    }
//    else{
//        if(errorHint!=nil && [errorHint isHidden]==NO)
//            [self ErrorHint:YES content:@""];
//    }
    return NO;
}


- (void) Close{
    [self dismissModalViewControllerAnimated:YES];    
}

- (void) addExfeeToCross{
    NSArray *customobjects=[exfeeList bubbleCustomObjects];
    NSMutableArray *invitations=[[[NSMutableArray alloc] initWithCapacity:[customobjects count]] autorelease];
    NSMutableDictionary *dict=[[[NSMutableDictionary alloc] initWithCapacity:[customobjects count]] autorelease];
    
    NSMutableArray *inputobjs=[[[NSMutableArray alloc] initWithCapacity:[customobjects count]] autorelease];
    
    for(id inputobj in customobjects){
        if([inputobj isKindOfClass:[Invitation class]]){
            Invitation *invitation=(Invitation*)inputobj;
//            invitation.identity.connected_user_id
            NSString *key=[invitation.identity.provider stringByAppendingString:invitation.identity.external_id];
            if(![dict objectForKey:key]){
                [dict setObject:@"" forKey:key];
                [invitations addObject:invitation];
            }
        }
        else if([inputobj isKindOfClass:[NSDictionary class]]){
            [inputobjs addObject:(NSDictionary*)inputobj];
        }
    }
    if([inputobjs count]==0){
        [(NewGatherViewController*)gatherview addExfee:invitations];
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        NSString *json=@"";

        for(NSDictionary *inputobj in inputobjs){
            NSString *input=[inputobj objectForKey:@"input"];
            NSString *provider=[inputobj objectForKey:@"provider"];
            if([provider isEqualToString:@""])
                provider=[Util findProvider:input];
            
            if(![provider isEqualToString:@""]) {
                if(![json isEqualToString:@""])
                    json=[json stringByAppendingString:@","];
                json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,input];
            }
        }
        json=[NSString stringWithFormat:@"[%@]",json];
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        RKClient *client = [RKClient sharedClient];
        [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
        
        MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Adding...";
        hud.mode=MBProgressHUDModeCustomView;
        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
        [bigspin startAnimating];
        hud.customView=bigspin;
        [bigspin release];
        
        NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];
        RKParams* rsvpParams = [RKParams params];
        [rsvpParams setValue:json forParam:@"identities"];
        [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
        [client post:endpoint usingBlock:^(RKRequest *request){
            request.method=RKRequestMethodPOST;
            request.params=rsvpParams;
            request.onDidLoadResponse=^(RKResponse *response){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (response.statusCode == 200) {
                    NSDictionary *body=[response.body objectFromJSONData];
                    if([body isKindOfClass:[NSDictionary class]]) {
                        id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                        if(code)
                            if([code intValue]==200) {
                                NSDictionary* response = [body objectForKey:@"response"];
                                NSArray *identities = [response objectForKey:@"identities"];
                                for (NSDictionary *identitydict in identities) {
                                    NSString *external_id=[identitydict objectForKey:@"external_id"];
                                    NSString *provider=[identitydict objectForKey:@"provider"];
                                    NSString *avatar_filename=[identitydict objectForKey:@"avatar_filename"];
                                    NSString *identity_id=[identitydict objectForKey:@"id"];
                                    NSString *name=[identitydict objectForKey:@"name"];
                                    NSString *nickname=[identitydict objectForKey:@"nickname"];
                                    NSString *external_username=[identitydict objectForKey:@"external_username"];

                                    Identity *identity=[Identity object];
                                    identity.external_id=external_id;
                                    identity.provider=provider;
                                    identity.avatar_filename=avatar_filename;
                                    identity.name=name;
                                    identity.external_username=external_username;
                                    identity.nickname=nickname;
                                    identity.identity_id=[NSNumber numberWithInt:[identity_id intValue]];
                                    
                                    Invitation *invitation =[Invitation object];
                                    invitation.rsvp_status=@"NORESPONSE";
                                    invitation.identity=identity;
                                    Invitation *myinvitation=[((NewGatherViewController*)gatherview) getMyInvitation];
                                    if(myinvitation!=nil)
                                        invitation.updated_by=myinvitation.identity;
                                    else
                                        invitation.updated_by=[[((NewGatherViewController*)gatherview).default_user.identities allObjects] objectAtIndex:0];
                                    [invitations addObject:invitation];
                                }
                                [(NewGatherViewController*)gatherview addExfee:invitations];
                                [self dismissModalViewControllerAnimated:YES];
                            }
                    }
                }
            };
            request.onDidFailLoadWithError=^(NSError *error){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            };
            request.delegate=self;
        }];
        
    }
}

- (void) done:(id)sender{
    NSString *inputtext=[exfeeList getInput];
    if(![inputtext isEqualToString:@""])
        [self addByInputIdentity:inputtext provider:@"" dismiss:YES];
    else{
        [self addExfeeToCross];
    }
}
- (IBAction)textDidChange:(UITextField*)textField{
    if(addressbookType== EXFE_ADDRESSBOOK){
        if(exfeeInput.text!=nil && exfeeInput.text.length>=1) {
            showInputinSuggestion=YES;
            [APIProfile LoadSuggest:exfeeInput.text delegate:self];
            [self loadIdentitiesFromDataStore:exfeeInput.text];
        }
        if(exfeeInput.text==nil || [exfeeInput.text isEqualToString:@""])
        {
            if(suggestIdentities!=nil){
                [suggestIdentities release];
                suggestIdentities=nil;
                [suggestionTable reloadData];
            }
        }
    }else if(addressbookType== LOCAL_ADDRESSBOOK){

    }
    
}
- (IBAction)editingDidBegan:(UITextField*)textField{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (Identity*) getIdentityFromLocal:(NSString*)input provider:(NSString*)provider{
    
    NSFetchRequest* request = [Identity fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((external_username == %@) AND (provider== %@))",input,provider];
    [request setPredicate:predicate];
    NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
    if([suggestwithselected count]>0)
        return (Identity*)[suggestwithselected objectAtIndex:0];
    return nil;
}

- (void)loadIdentitiesFromDataStore:(NSString*)input{
    [suggestIdentities release];
    suggestIdentities=nil;
    NSFetchRequest* request = [Identity fetchRequest];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
    NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",[input stringByReplacingOccurrencesOfString:@" " withString:@"*"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((name like[c] %@) OR (external_username like[c] %@) OR (external_id like[c] %@) OR (nickname like[c] %@)) AND provider != %@ AND provider != %@ AND connected_user_id != 0",inputpredicate,inputpredicate,inputpredicate,inputpredicate,@"iOSAPN",@"android"];
    
    if([input isEqualToString:@""]) {
        predicate = [NSPredicate predicateWithFormat:@"provider != %@ AND provider != %@ AND connected_user_id !=0",@"iOSAPN",@"android"];
    }

    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    NSMutableArray *temp=[[NSMutableArray alloc]initWithCapacity:10];
    NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[suggestwithselected count]];
    
    for (Identity *identity in suggestwithselected){
        BOOL flag=NO;
        NSString *key=[identity.provider stringByAppendingString:identity.external_id];
        if([dict objectForKey:key]==nil){
            for (Invitation *selected in ((NewGatherViewController*)gatherview).exfeeIdentities){
                if([selected.identity.identity_id intValue]==[identity.identity_id intValue])
                {
                    flag=YES;
                    continue;
                }
            }
            for (id selected in exfeeList.bubbleCustomObjects){
                if([selected isKindOfClass:[Invitation class]]) {
                    if([((Invitation*)selected).identity.identity_id intValue]==[identity.identity_id intValue])
                    {
                        flag=YES;
                        continue;
                    }
                }
            }
            if(flag==NO)
                [temp addObject:identity];
            [dict setObject:@"" forKey:key];
        }
    }
    [dict release];
    [suggestwithselected release];
    suggestIdentities=[temp retain];
    [temp release];
    [suggestionTable reloadData];
}

- (IBAction)editingDidEnd:(UITextField*)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}
- (void) addBubbleByIdentity:(Identity*)identity input:(NSString*)input{

    Invitation *invitation =[Invitation object];
    invitation.rsvp_status=@"NORESPONSE";
    invitation.identity=identity;
    Invitation *myinvitation=[((NewGatherViewController*)gatherview) getMyInvitation];
    if(myinvitation!=nil)
        invitation.updated_by=myinvitation.identity;
    else
        invitation.updated_by=[[((NewGatherViewController*)gatherview).default_user.identities allObjects] objectAtIndex:0];
    
    [exfeeList addBubble:input customObject:invitation];
    if([exfeeList bubblecount]>0)
        [self changeLeftIconWhite:YES];
    
}

- (void) addBubbleByInputString:(NSString*)input provider:(NSString*)provider{
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:input,@"input",provider,@"provider", nil];
    [exfeeList addBubble:input customObject:dict];
    if([exfeeList bubblecount]>0)
        [self changeLeftIconWhite:YES];
    
}

- (void) addByInputIdentity:(NSString*)input provider:(NSString*)provider dismiss:(BOOL)shoulddismiss{
    Identity* identity=[self getIdentityFromLocal:input provider:provider];
    if(identity!=nil){
        [self addBubbleByIdentity:identity input:input];
//        [identity release];
        return;
    }
    
    NSArray* inputs=[input componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
    for(input in inputs){
        [self addBubbleByInputString:input provider:provider];
    }
}

#pragma mark UITableView Datasource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if(addressbookType==LOCAL_ADDRESSBOOK)
        return [filteredlocalcontacts count];
    else{
        if(suggestIdentities)
        {
            return [suggestIdentities count];
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"suggest view";
    GatherExfeeInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[GatherExfeeInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if(addressbookType==LOCAL_ADDRESSBOOK)
    {
        LocalContact *person=[filteredlocalcontacts objectAtIndex:indexPath.row];

        cell.title = person.name;

        UIImage *avatar=[UIImage imageWithData:person.avatar];
        if(avatar==nil)
            cell.avatar=[UIImage imageNamed:@"portrait_default.png"];
        else
            cell.avatar=avatar;
        
        NSMutableArray *iconset=[[NSMutableArray alloc] initWithCapacity:3];
        if(person.social!=nil){
            NSArray *social_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.social];
            if( social_array!=nil && [social_array isKindOfClass:[NSArray class]]){
                for (NSDictionary *socialdict in social_array) {
                    if([[socialdict objectForKey:@"service"] isEqualToString:@"twitter"]){
                        [iconset addObject:[UIImage imageNamed:@"identity_twitter_18_grey.png"]];
                    }
                    if([[socialdict objectForKey:@"service"] isEqualToString:@"facebook"]){
                        [iconset addObject:[UIImage imageNamed:@"identity_facebook_18_grey.png"]];
                    }
                }
            }
        }
        if(person.im!=nil){
            NSArray *im_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.im];
            if( im_array!=nil && [im_array isKindOfClass: [NSArray class]]){
                for (NSDictionary *imdict in im_array) {
                    if([[imdict objectForKey:@"service"] isEqualToString:@"Facebook"]){
                        [iconset addObject:[UIImage imageNamed:@"identity_facebook_18_grey.png"]];
                    }
                }
            }
 
        }
        if(person.emails!=nil){
            NSArray *emails_array=[NSKeyedUnarchiver unarchiveObjectWithData:person.emails];

            if(emails_array!=nil && [emails_array isKindOfClass: [NSArray class]]){
                [iconset addObject:[UIImage imageNamed:@"identity_email_18_grey.png"]];
            }
            
        }
        cell.providerIconSet=iconset;
        cell.providerIcon=nil;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if([iconset count]>1){
            CGRect frame = CGRectMake(0.0, 0.0, (18+10)*([iconset count]+1), 110);
            button.frame = frame;
            [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
        }
    }else{
        int row=indexPath.row;
        Identity *identity=[suggestIdentities objectAtIndex:row];
        cell.title = identity.name;
        if(cell.title==nil || [cell.title isEqualToString:@""])
            cell.title = identity.external_username;
        
//        if([identity.provider isEqualToString:@"twitter"])
//            cell.subtitle =[NSString stringWithFormat:@"@%@",identity.external_username];
//        else
//            cell.subtitle =identity.external_id;
//    
        if(identity.provider!=nil && ![identity.provider isEqualToString:@""]){

            NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",identity.provider];
            UIImage *icon=[UIImage imageNamed:iconname];
            cell.providerIcon=icon;
            cell.providerIconSet=nil;
        }
        if(identity.avatar_filename!=nil) {
            UIImage *avatar = [[ImgCache sharedManager] getImgFromCache:identity.avatar_filename];
            if(avatar==nil || [avatar isEqual:[NSNull null]])
            {
                cell.avatar=[UIImage imageNamed:@"portrait_default.png"];
                dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                dispatch_async(imgQueue, ^{
                    UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                            cell.avatar=avatar;
                        }
                    });
                });
                dispatch_release(imgQueue);
            }
            else
                cell.avatar=avatar;
        }
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedRowIndex==indexPath.row){
        return expandCellHeight;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(addressbookType==LOCAL_ADDRESSBOOK){
        LocalContact *person=[filteredlocalcontacts objectAtIndex:indexPath.row];
        [self addByInputIdentity:[[AddressBook getDefaultIdentity:person] objectForKey:@"external_id"] provider:[[AddressBook getDefaultIdentity:person] objectForKey:@"provider"] dismiss:NO];
    }else{
        Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
        Invitation *invitation =[Invitation object];
        invitation.rsvp_status=@"NORESPONSE";
        invitation.identity=identity;
        Invitation *myinvitation=[((NewGatherViewController*)gatherview) getMyInvitation];
        if(myinvitation!=nil)
            invitation.updated_by=myinvitation.identity;
        else
            invitation.updated_by=[[((NewGatherViewController*)gatherview).default_user.identities allObjects] objectAtIndex:0];

        NSString *identity_name=identity.nickname;
        if(identity_name==nil || [identity_name isEqualToString:@""])
            identity_name=identity.name;
        if(identity_name==nil || [identity_name isEqualToString:@""])
            identity_name=identity.external_username;
        if(identity_name==nil || [identity_name isEqualToString:@""])
            identity_name=identity.external_id;
        
        [exfeeList addBubble:identity_name customObject:invitation];
        if([exfeeList bubblecount]>0)
            [self changeLeftIconWhite:YES];
    }

}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    
    if([objects count]>0) {
        if([objectLoader.userData isEqualToString:@"suggest"])
            [self loadIdentitiesFromDataStore:[exfeeList getInput]];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    //    [self stopLoading];
}

#pragma mark EXBubbleScrollViewDelegate methods
- (void) deleteLastBubble:(EXBubbleScrollView *)bubbleScrollView deletedbubble:(EXBubbleButton*)bubble{
    [self showErrorHint];
    if([exfeeList bubblecount]==0)
        [self changeLeftIconWhite:NO];

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if(scrollView.contentOffset.x>5&&scrollView.contentOffset.x<20)
//        [self changeLeftIconWhite:NO];
//    if(scrollView.contentOffset.x>20)
//        [self changeLeftIconWhite:YES];
//    else
//        [self changeLeftIconWhite:NO];
}
- (void)OnInputConfirm:(EXBubbleScrollView *)bubbleScrollView textField:(UITextField*)textfield{
    NSString *inputtext=[textfield.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [self addByInputIdentity:inputtext provider:@"" dismiss:NO];
}
- (id)customObject:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    NSDictionary *dictionary=[[[NSDictionary alloc] initWithObjectsAndKeys:input,@"name",@"id",@"id", nil ] autorelease];
    return dictionary;
}
- (BOOL)isInputValid:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isemail= [emailTest evaluateWithObject:input];
    if(isemail==YES)
        return YES;
    
    NSString *twitterRegex = @"@[A-Za-z0-9]+";
    NSPredicate *twitterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex];
    BOOL istwitter= [twitterTest evaluateWithObject:input];
    if(istwitter==YES)
        return YES;
    return NO;
}
- (BOOL) inputTextChange:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input{
    expandCellHeight=44;
    [expandExfeeView setHidden:YES];

    if(addressbookType== EXFE_ADDRESSBOOK){
        if(input!=nil && input.length>=1) {
            if([self showErrorHint]==YES)
                return YES;
            showInputinSuggestion=YES;
            [APIProfile LoadSuggest:input delegate:self];
            [self loadIdentitiesFromDataStore:input];
        }
        if(input==nil || [input isEqualToString:@""])
        {
            if(suggestIdentities!=nil){
                [suggestIdentities release];
                suggestIdentities=nil;
                [suggestionTable reloadData];
            }
        }
    }else if(addressbookType == LOCAL_ADDRESSBOOK){
        
        NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",[input stringByReplacingOccurrencesOfString:@" " withString:@"*"]];
        if(filteredlocalcontacts!=nil){
            [filteredlocalcontacts release];
            filteredlocalcontacts=nil;
        }
        
        NSFetchRequest* request = [LocalContact fetchRequest];
        if(filteredlocalcontacts!=nil)
            [filteredlocalcontacts release];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(indexfield like[c] %@)", inputpredicate];
        [request setPredicate:predicate];

        
        filteredlocalcontacts=[[LocalContact objectsWithFetchRequest:request] retain];

        [suggestionTable reloadData];
    }
    return YES;
}


- (void)checkButtonTapped:(id)sender event:(id)event
{
    if(addressbookType== EXFE_ADDRESSBOOK)
        return;
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:suggestionTable];
    NSIndexPath *indexPath = [suggestionTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        if(selectedRowIndex==indexPath.row)
            selectedRowIndex=-1;
        else{
            selectedRowIndex=indexPath.row;
        }
        LocalContact *localcontact=[filteredlocalcontacts objectAtIndex:indexPath.row];
        
        NSArray* useridentities=[AddressBook getLocalIdentityObjects:localcontact];
        expandCellHeight=44+[useridentities count]/2*40+([useridentities count]%2)*40;
        
        [[suggestionTable cellForRowAtIndexPath:indexPath] setNeedsDisplay];
        [suggestionTable reloadData];
        UITableViewCell *cell = [suggestionTable cellForRowAtIndexPath:indexPath];
        if([cell frame].size.height>44) {
            if(expandExfeeView==nil) {
                expandExfeeView=[[UIView alloc] init];
                [suggestionTable addSubview:expandExfeeView];
            }else{
                NSArray *subviews=[expandExfeeView subviews];
                for(UIView *subview in subviews){
                    [subview removeFromSuperview];
                    [subview release];
                }
            }
            expandExfeeViewShadow=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4)];
            
            [expandExfeeViewShadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow.png"]]];

            [expandExfeeView setFrame:CGRectMake(0, [cell frame].origin.y+44, cell.frame.size.width, cell.frame.size.height-44)];
            [expandExfeeView setBackgroundColor:[UIColor colorWithRed:111/255.f green:118/255.f blue:125/255.f alpha:1]];
            int idx=0;
            float cellwidth=cell.frame.size.width/2;
            for(NSDictionary *identity in useridentities)
            {
                UIBorderView *identitycell=[[UIBorderView alloc] initWithFrame:CGRectMake(idx%2*cellwidth, idx/2*40, cellwidth, 40)];

                NSString *iconname=[NSString stringWithFormat:@"identity_%@_18.png",[identity objectForKey:@"provider"]];
                UIImage *icon=[UIImage imageNamed:iconname];
                
                UIImageView *imgprovider=[[[UIImageView alloc] initWithFrame:CGRectMake(6, (44-18)/2, icon.size.width, icon.size.height)] autorelease];
                imgprovider.backgroundColor=[UIColor clearColor];
                imgprovider.image=icon;
                [identitycell addSubview:imgprovider];
                
                UILabel *labelusername=[[[UILabel alloc] initWithFrame:CGRectMake(6+18+6, 0,  cellwidth-6-18-6,40)] autorelease];
                labelusername.numberOfLines = 0;
                [labelusername setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:16]];
                [labelusername setTextColor:[UIColor whiteColor]];
                
                [labelusername setText:[identity objectForKey:@"external_id"]];
                [labelusername setLineBreakMode:NSLineBreakByCharWrapping];
                labelusername.backgroundColor=[UIColor clearColor];
                [identitycell addSubview:labelusername];

                
                UIButton *identitycellbtn=[UIButton buttonWithType:UIButtonTypeCustom];
                [identitycellbtn setFrame:CGRectMake(0, 0, cellwidth, 40)];
                [identitycellbtn setBackgroundColor:[UIColor clearColor]];
                
                [identitycellbtn setBackgroundImage:[[UIImage imageNamed:@"cell_selected_40.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0,0)] forState:UIControlStateHighlighted];



                SEL selector = @selector(selectidentity:);
                [identitycellbtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject (identitycellbtn, &identitykey, identity,OBJC_ASSOCIATION_RETAIN);
                [identitycell addSubview:identitycellbtn];
                
//              if((idx+1)/2%2==0 )
                
                    [identitycell setBackgroundColor:FONT_COLOR_51];
//              else
//                  [identitycell setBackgroundColor:[UIColor colorWithRed:58/255.f green:110/255.f blue:165/255.f alpha:1]];
                [expandExfeeView addSubview:identitycell];
//                [identitycell release];
                idx++;
            }
            if([useridentities count]%2==1){
                UIBorderView *identitycell=[[UIBorderView alloc] initWithFrame:CGRectMake([useridentities count]%2*cellwidth, [useridentities count]/2*40, cellwidth, 40)];
                [identitycell setBackgroundColor:FONT_COLOR_51];
                [expandExfeeView addSubview:identitycell];
//                [identitycell release];

            }
            [expandExfeeView addSubview:expandExfeeViewShadow];
//            [expandExfeeViewShadow release];
            [expandExfeeView setHidden:NO];
        }
        else{
            expandCellHeight=44;
            [expandExfeeView setHidden:YES];
        }
    }
}
- (void) selectidentity:(id)sender{
    NSDictionary *identity = (NSDictionary *)objc_getAssociatedObject(sender, &identitykey);
    [self addByInputIdentity:[identity objectForKey:@"external_id"] provider:[identity objectForKey:@"provider"] dismiss:NO];
}
@end
