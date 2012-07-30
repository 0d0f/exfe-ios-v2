//
//  CrossDetailViewController.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossDetailViewController.h"
#import "Exfee.h"
#import "Cross.h"
#import "Place.h"
#import "Invitation.h"
#import "Identity.h"
#import "APIConversation.h"
#import "ImgCache.h"
#import "EFTime.h"
#import "CrossTime.h"
#import "Rsvp.h"
#import "Util.h"
#import <RestKit/JSONKit.h>

#define kStatusBarHeight 20
#define kDefaultToolbarHeight 40
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface CrossDetailViewController ()

@end

@implementation CrossDetailViewController
@synthesize interceptLinks;
@synthesize cross;
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
    conversationView=[[ConversationViewController alloc]initWithNibName:@"ConversationViewController" bundle:nil] ;
    conversationView.exfee_id=[cross.exfee.exfee_id intValue];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSSet *invitations=cross.exfee.invitations;
    if(invitations !=nil&&[invitations count]>0)
    {
        for(Invitation* invitation in invitations)
            if([invitation.identity.connected_user_id intValue]==app.userid)
                conversationView.identity=invitation.identity;  
    }
    
    [conversationView.view setHidden:YES];
    [self.view addSubview:conversationView.view];
    
    UIImage *chatimg = [UIImage imageNamed:@"chat.png"];
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatButton setTitle:@"Chat" forState:UIControlStateNormal];
    [chatButton setImage:chatimg forState:UIControlStateNormal];
    chatButton.frame = CGRectMake(0, 0, chatimg.size.width, chatimg.size.height);
    [chatButton addTarget:self action:@selector(toconversation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
	self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];  
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSURL *baseURL = [NSURL fileURLWithPath:documentsDirectory];
    NSString *html=[self GenerateHtmlWithEvent];
    [webview loadHTMLString:html baseURL:baseURL];
    [conversationView refreshConversation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc {
    [conversationView release];
    [cross release];
    [super dealloc];
}
- (NSString*)GenerateHtmlWithEvent
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *xpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"x.html"];
    NSString *html=[NSString stringWithContentsOfFile:xpath encoding:NSUTF8StringEncoding error:nil];
//    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at_human#}" withString:[Util formattedDateRelativeToNow:eventobj.begin_at withTimeType:eventobj.time_type]];
    NSDictionary *humanreadable_date=[Util crossTimeToString:cross.time];

    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at#}" withString:[humanreadable_date objectForKey:@"date"]];
    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at_human#}" withString:[humanreadable_date objectForKey:@"relative"]];
    
    NSString *mapimg=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=size:mid|color:blue|%@,%@&zoom=13&size=130x75&sensor=false",cross.place.lat,cross.place.lng,cross.place.lat,cross.place.lng];
    NSString *background=@"x_background.png";
    if(cross.widget!=nil)
    {
        id widgets=cross.widget;
        if([widgets isKindOfClass:[NSArray class]])
        {
            
            for(int i=0;i<[(NSArray*)widgets count];i++)
            {
                id widget=[widgets objectAtIndex:i];
                if([widget isKindOfClass:[NSDictionary class]])
                {
                    NSString *type=[((NSDictionary*)widget) objectForKey:@"type"];
                    if([type isEqualToString:@"Background"])
                        background=[((NSDictionary*)widget) objectForKey:@"image"];
                }
            }
        }
    }

    html=[html stringByReplacingOccurrencesOfString:@"{#background_img#}" withString:[Util getBackgroundLink:background]];

    if([cross.place.title isEqualToString:@""])
    {
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line2#}" withString:@""];
        html=[html stringByReplacingOccurrencesOfString:@"{#map_display}" withString:@"none"]
        ;
        if(!([cross.place.lat intValue]==0  && [cross.place.lng intValue]==0)){
            html=[html stringByReplacingOccurrencesOfString:@"{#map_img_url#}" withString:mapimg];
            html=[html stringByReplacingOccurrencesOfString:@"{#show_map_img#}" withString:@"display:block"];
            html=[html stringByReplacingOccurrencesOfString:@"{#place_line1#}" withString:@"Somewhere"];
        }
        else {
            html=[html stringByReplacingOccurrencesOfString:@"{#place_line1#}" withString:@"Any Place"];
            html=[html stringByReplacingOccurrencesOfString:@"{#show_map_img#}" withString:@"display:none"];
            html=[html stringByReplacingOccurrencesOfString:@"{#nomap#}" withString:@"nomap"];
        }
    }
    else
    {
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line1#}" withString:cross.place.title];
        html=[html stringByReplacingOccurrencesOfString:@"{#map_display}" withString:@"inline"];
        if(!([cross.place.lat intValue]==0  && [cross.place.lng intValue]==0)) {
            html=[html stringByReplacingOccurrencesOfString:@"{#map_img_url#}" withString:mapimg];
            html=[html stringByReplacingOccurrencesOfString:@"{#show_map_img#}" withString:@"display:block"];
        }
        else{
            html=[html stringByReplacingOccurrencesOfString:@"{#show_map_img#}" withString:@"display:none"];
            html=[html stringByReplacingOccurrencesOfString:@"{#nomap#}" withString:@"nomap"];
        }
        
        NSString *place_line2=[[cross.place.place_description componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@"<br/>"];
        
        html=[html stringByReplacingOccurrencesOfString:@"{#place_line2#}" withString:place_line2];
    }
    html=[html stringByReplacingOccurrencesOfString:@"{#title#}" withString:cross.title];
    
    NSString *exfeelist=@"";
    NSSet *invitations=cross.exfee.invitations;
    int confirmed_num=0;
    if(invitations !=nil&&[invitations count]>0)
    {
        NSEnumerator *enumerator=[invitations objectEnumerator];
        Invitation *invitation=nil;

        while (invitation = [enumerator nextObject])
        {
            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                confirmed_num++;

            NSString *imgurl = [ImgCache getImgUrl:invitation.identity.avatar_filename];
            NSString *host=@"";
            NSString *withnum=@"";
            if((BOOL)invitation.host==YES)
                host=@"<span class='rt'>H</span>";

            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                exfeelist=[exfeelist stringByAppendingFormat:@"<li id='avatar_%d'><img alt='' width='40px' height='40px' src='%@' />%@%@</li>",[invitation.identity.identity_id intValue],imgurl,host,withnum];
            else
                exfeelist=[exfeelist stringByAppendingFormat:@"<li id='avatar_%d' class='opacity'><img alt='' width='40px' height='40px' src='%@' />%@%@</li>",[invitation.identity.identity_id intValue],imgurl,host,withnum];
            if([invitation.identity.connected_user_id intValue]==app.userid)
            {
                if([invitation.rsvp_status isEqualToString:@"ACCEPTED"] || [invitation.rsvp_status isEqualToString:@"DECLINED"] || [invitation.rsvp_status isEqualToString:@"INTERESTED"])
                {
                    html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_btn_show#}" withString:@"style='display:none'"];
                    if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                        html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_opt_text#}" withString:@"Accepted"];
                    else if([invitation.rsvp_status isEqualToString:@"DECLINED"])
                        html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_opt_text#}" withString:@"Declined"];
                    else if([invitation.rsvp_status isEqualToString:@"INTERESTED"])
                        html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_opt_text#}" withString:@"Interested"];
                    html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_opt_show#}" withString:@"style='display:block'"];
                }
                else {
                    html=[html stringByReplacingOccurrencesOfString:@"{#rsvp_opt_show#}" withString:@"style='display:none'"];
                }
            }
        }
    }    
    
    html=[html stringByReplacingOccurrencesOfString:@"{#confirmed_num#}" withString:[NSString stringWithFormat:@"%d",confirmed_num]];
    html=[html stringByReplacingOccurrencesOfString:@"{#all_num#}" withString:[NSString stringWithFormat:@"%d",[invitations count]]];
    
    html=[html stringByReplacingOccurrencesOfString:@"{#exfee_list#}" withString:exfeelist];
    NSString *description=[cross.cross_description stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    html=[html stringByReplacingOccurrencesOfString:@"{#description#}" withString:description];
    return html;
}

- (void)toconversation
{
    
    if(conversationView.view.isHidden==YES)
    {
        [conversationView.view setHidden:NO];
        [conversationView refreshConversation];
        cross.conversation_count=0;
        NSError *saveError;
        [[Cross currentContext] save:&saveError];

        NSLog(@"%@",self.navigationController.viewControllers);
        
        for(id viewcontroller in self.navigationController.viewControllers)
        {
            if([viewcontroller isKindOfClass:[CrossesViewController class]])
            {
                [viewcontroller refreshCell];
            }
        }
        [UIView transitionFromView:self.view toView:conversationView.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    }
    else {
        [UIView transitionFromView:conversationView.view toView:self.view duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        [conversationView.view setHidden:YES];
    }

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(bool) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (interceptLinks)
    {
        NSString *requestString = [[request URL] absoluteString];
        if ([requestString hasPrefix:@"js-frame:"]) {
            NSArray *components = [requestString componentsSeparatedByString:@":"];
            NSString *function = (NSString*)[components objectAtIndex:1];
            int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
            NSString *argsAsString = [(NSString*)[components objectAtIndex:3] 
                                      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@",[argsAsString objectFromJSONString]);
            
            [self handleCall:function callbackId:callbackId args:[argsAsString objectFromJSONString]];
        }
    }
    
    if (interceptLinks && navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSArray *chunk=[[url absoluteString] componentsSeparatedByString:@"#"];
        if([chunk count]==2)
        {
//            if( [[chunk objectAtIndex:0] isEqualToString:@"http://addical/"])
//            {
//                NSString *datestr=[self.event objectForKey:@"begin_at"];
//                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//                
//                if (datestr.length > 20) {
//                    datestr = [datestr stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(20, datestr.length-20)];                                    
//                }                 
//                [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
//                NSDate *sdate=[dateFormat dateFromString:datestr];
//                
//                [dateFormat release];                
//                
//                DBUtil *dbu=[DBUtil sharedManager];
//                
//                EKEventStore *eventStore = [[EKEventStore alloc] init];
//                EKEvent *sevent  = [EKEvent eventWithEventStore:eventStore];
//                sevent.title     = [self.event objectForKey:@"title"];
//                sevent.startDate =  sdate;//[[NSDate alloc] init];
//                sevent.endDate   = [[NSDate alloc] initWithTimeInterval:600 sinceDate:sevent.startDate];
//                sevent.location =[self.event objectForKey:@"venue"];
//                //                NSLog(@"%@",sevent.eventIdentifier);
//                [sevent setCalendar:[eventStore defaultCalendarForNewEvents]];
//                NSError *err;
//                [eventStore saveEvent:sevent span:EKSpanThisEvent error:&err]; 
//                [dbu updateEventicalWithid:self.eventid identifier:sevent.eventIdentifier];
//            }
        }
        else if( [[chunk objectAtIndex:0] isEqualToString:@"http://showmap/"])
        {
//            NSString *q =@"";
//            if(![eventobj.place_line2 isEqualToString:@""])
//                q =[NSString stringWithFormat:@"%@",eventobj.place_line2];
//            else
//                q =[NSString stringWithFormat:@"%@",eventobj.place_line1];
//            int zoom = 13;
//            
//            NSString *stringURL = [[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@&z=%d", q,zoom] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            if(abs([eventobj.place_lat intValue])>0 && abs([eventobj.place_lng intValue])>0)
//                stringURL = [[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@@%@,%@&z=%d",q,eventobj.place_lat,eventobj.place_lng,zoom] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            //            NSLog(@"url:%@",stringURL);
//            NSURL *url = [NSURL URLWithString:stringURL];
//            
//            [[UIApplication sharedApplication] openURL:url];
            
        }
        return NO;
    }
    //No need to intercept the initial request to fill the WebView
    else {
        //        NSLog(@"interceptLinks");
        interceptLinks = YES;
        return YES;
    }
    
}
- (void)returnResult:(int)callbackId args:(id)arg;
{
    NSArray *rsvp_list=(NSArray*)arg;
    NSDictionary *rsvp=[rsvp_list objectAtIndex:0];
    int confirmed_num=0;
    for (Invitation *invitation in cross.exfee.invitations)
    {
        int identity_id=[[rsvp objectForKey:@"identity_id"] intValue];
        if([invitation.identity.identity_id intValue]==identity_id)
        {
            if([[rsvp objectForKey:@"rsvp_status"] isEqualToString:@"ACCEPTED"])
                confirmed_num++;
        }
        else{
        if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
            confirmed_num++;
        }
    }
    NSMutableDictionary *r_rsvp=[NSMutableDictionary dictionaryWithDictionary:rsvp];
    [r_rsvp setObject:[NSNumber numberWithInt:confirmed_num] forKey:@"confirmed_num"];
    NSString *result=[r_rsvp JSONString];
    [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"NativeBridge.resultForCallback(%d,%@);",callbackId,result]];
    
}

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([functionName isEqualToString:@"rsvp"]) {
        int rsvp_int=[[args objectAtIndex:0] intValue];
        NSString* rsvp=@"";
        if(rsvp_int==1)
            rsvp=@"ACCEPTED";
        else if(rsvp_int==2)
            rsvp=@"DECLINED";
        else if(rsvp_int==3)
            rsvp=@"INTERESTED";

//        Rsvp* rsvpobj=[Rsvp object];
//        rsvpobj.rsvp_status=rsvp;
        
        NSNumber *identity_id=[NSNumber numberWithInt:0];
        NSNumber *by_identity_id=[NSNumber numberWithInt:0];
        for (Invitation* invitation in cross.exfee.invitations )
        {
            if([invitation.identity.connected_user_id intValue] == app.userid)
            {
                identity_id=invitation.identity.identity_id;
                by_identity_id=invitation.identity.identity_id;
            }
        }

        NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:identity_id,@"identity_id",by_identity_id,@"by_identity_id",rsvp,@"rsvp_status",@"rsvp",@"type", nil];
        NSArray *postarray=[NSArray arrayWithObject:rsvpdict];        
        
        RKParams* rsvpParams = [RKParams params];
        [rsvpParams setValue:[postarray JSONString] forParam:@"rsvp"];
        RKClient *client = [RKClient sharedClient];
        NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/rsvp?token=%@",[cross.exfee.exfee_id intValue],app.accesstoken];
        [client post:endpoint usingBlock:^(RKRequest *request){
            request.method=RKRequestMethodPOST;
            request.params=rsvpParams;
            request.onDidLoadResponse=^(RKResponse *response){
                
                if (response.statusCode == 200) {
                    
                    NSDictionary *body=[response.body objectFromJSONData];
                    if([body isKindOfClass:[NSDictionary class]]) {
                        id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                        if(code)
                            if([code intValue]==200) {
                                
                                [self returnResult:callbackId args:[[body objectForKey:@"response"] objectForKey:@"rsvp"]];
                            }
                        
                    }
                    //We got an error!
                }else {
                    //Check Response Body to get Data!
                }
            };
            request.delegate=self;
        }];
        
    } else if ([functionName isEqualToString:@"prompt"]) {
        
        if ([args count]!=1) {
    //            NSLog(@"prompt wait exactly one argument!");
            return;
        }
        
        NSString *message = (NSString*)[args objectAtIndex:0];
        
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] autorelease];
        [alert show];
        
    } else {
        NSLog(@"Unimplemented method '%@'",functionName);
    }
}


#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
        NSLog(@"success:%@",objects);

}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

- (void)pushback
{
    if (webview.loading)
        [webview stopLoading];
    webview.delegate = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
