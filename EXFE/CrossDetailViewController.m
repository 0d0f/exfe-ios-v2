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


@interface CrossDetailViewController ()

@end

@implementation CrossDetailViewController
@synthesize cross;

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
    conversationView=[[ConversationViewController alloc]initWithNibName:@"conversationViewController" bundle:nil] ;
    [conversationView.view setHidden:YES];
    [self.view addSubview:conversationView.view];

//    Exfee *exfee=cross.exfee;
//    NSLog(@"%@",exfee.exfee_id);
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *chatimg = [UIImage imageNamed:@"chat.png"];
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatButton setTitle:@"Chat" forState:UIControlStateNormal];
    [chatButton setImage:chatimg forState:UIControlStateNormal];
    chatButton.frame = CGRectMake(0, 0, chatimg.size.width, chatimg.size.height);
    [chatButton addTarget:self action:@selector(toconversation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
	self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];  
//    cross_tiltle.text=cross.title;
//    exfee_id.text=[cross.exfee.exfee_id stringValue];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSURL *baseURL = [NSURL fileURLWithPath:documentsDirectory];
    NSString *html=[self GenerateHtmlWithEvent];
    [webview loadHTMLString:html baseURL:baseURL];

/*
    dispatch_queue_t loaddata= dispatch_queue_create("loaddata", NULL);
    dispatch_async(loaddata, ^{
        NSString *html=[self GenerateHtmlWithEvent];
        dispatch_async(dispatch_get_main_queue(), ^{
            [webview loadHTMLString:html baseURL:baseURL];
        });
    });
    dispatch_release(loaddata);
 */
    
//    [APIConversation LoadConversationWithExfeeId:[cross.exfee.exfee_id intValue] updatedtime:@"" delegate:self];
    //LoadConversationWithExfeeId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate{
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [conversationView release];
    [cross release];
    [super dealloc];
}
- (NSString*)GenerateHtmlWithEvent
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    DBUtil *dbu=[DBUtil sharedManager];

//    NSDate *theDate = nil;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    theDate = [dateFormatter dateFromString:eventobj.begin_at];  
//    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSString *dateString = [dateFormatter stringFromDate:theDate];
//    [dateFormatter release];
//    
//    
//    NSDateFormatter *dateFormatter_human = [[NSDateFormatter alloc] init];
//    [dateFormatter_human setTimeStyle:NSDateFormatterNoStyle];
//    [dateFormatter_human setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter_human setLocale:[NSLocale currentLocale]];
//    
//    [dateFormatter_human setDoesRelativeDateFormatting:YES];
//    
//    NSString *dateString_human = [dateFormatter_human stringFromDate:theDate];
//    [dateFormatter_human release];
    NSString *dateString;
    if(dateString==nil)
    {
//        dateString_human=@"Anytime";
        dateString=@"";
    }
    
    NSString *xpath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"x.html"];
    NSString *html=[NSString stringWithContentsOfFile:xpath encoding:NSUTF8StringEncoding error:nil];
//    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at_human#}" withString:[Util formattedDateRelativeToNow:eventobj.begin_at withTimeType:eventobj.time_type]];
    
//    html=[html stringByReplacingOccurrencesOfString:@"{#begin_at#}" withString:[Util getLongLocalTimeStrWithTimetype:eventobj.time_type time:eventobj.begin_at]];
    
//    if([eventobj.begin_at isEqualToString:@"0000-00-00 00:00:00"]&& [eventobj.time_type isEqualToString:@""])
//    {
//        html=[html stringByReplacingOccurrencesOfString:@"{#hidden_calendar#}" withString:@"hidden"];
//        html=[html stringByReplacingOccurrencesOfString:@"{#show_detail_time#}" withString:@"display:none"];
//    }
//    else
//        html=[html stringByReplacingOccurrencesOfString:@"{#show_detail_time#}" withString:@"display:block"];
    
    
    NSString *mapimg=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&markers=size:mid|color:blue|%@,%@&zoom=13&size=130x75&sensor=false",cross.place.lat,cross.place.lng,cross.place.lat,cross.place.lng];
    
    
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
//    if(eventobj.background!=nil && ![eventobj.background isEqualToString:@""])
//        html=[html stringByReplacingOccurrencesOfString:@"{#background_img#}" withString:[Util getBackgroundLink:eventobj.background]];
//    else {
//        html=[html stringByReplacingOccurrencesOfString:@"{#background_img#}" withString:@"x_background.png"];
//    }
    
    NSString *exfeelist=@"";
    NSSet *invitations=cross.exfee.invitations;
    int confirmed_num=0;
    if(invitations !=nil&&[invitations count]>0)
    {
        NSEnumerator *enumerator=[invitations objectEnumerator];
        Invitation *invitation=nil;
        for (Invitation *invitation in invitations) {
            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                confirmed_num++;
            
        }

        while (invitation = [enumerator nextObject])
        {
            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                confirmed_num++;
            
            NSString 	*imgurl = [ImgCache getImgUrl:invitation.identity.avatar_filename];
            NSString *host=@"";
            NSString *withnum=@"";
            if((BOOL)invitation.host==YES)
                host=@"<span class='rt'>H</span>";
//            if(invitation.withnum>0)
//                withnum=[NSString stringWithFormat:@"<span class='lt'>%d</span>",invitation.withnum];
            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                exfeelist=[exfeelist stringByAppendingFormat:@"<li id='avatar_%d'><img alt='' width='40px' height='40px' src='%@' />%@%@</li>",invitation.identity.identity_id,imgurl,host,withnum];
            else
                exfeelist=[exfeelist stringByAppendingFormat:@"<li id='avatar_%d' class='opacity'><img alt='' width='40px' height='40px' src='%@' />%@%@</li>",invitation.identity.identity_id,imgurl,host,withnum];
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
//    if(conversationView==nil)
//    {
//    }
    
    if(conversationView.view.isHidden==YES)
    {
        [conversationView.view setHidden:NO];

        [UIView transitionFromView:self.view toView:conversationView.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    }
    else {
        [UIView transitionFromView:conversationView.view toView:self.view duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        [conversationView.view setHidden:YES];
    }

//    if(showeventinfo==YES)
//    {
//    }   
//    else
//    {
//        
//        [UIView transitionFromView:conversionViewController.view toView:webview duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
//    }
//    ////    
//    if(showeventinfo==YES)
//    {
//        CGRect screenFrame = [self.view frame];
//        
//        CGRect crect=conversationview.frame;
//        conversationview.frame=CGRectMake(crect.origin.x, crect.origin.y, crect.size.width, crect.size.height-kDefaultToolbarHeight);
//        CGRect toolbarframe=CGRectMake(0, screenFrame.size.height-kDefaultToolbarHeight, screenFrame.size.width, kDefaultToolbarHeight);
//        
//        self.inputToolbar = [[UIInputToolbar alloc] initWithFrame:toolbarframe];
//        inputToolbar.delegate = self;
//        [self.view addSubview:self.inputToolbar];
//        conversionViewController.inputToolbar=inputToolbar;
//    }
//    else
//    {
//        [self.inputToolbar removeFromSuperview];
//    }
//    showeventinfo=!showeventinfo;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
        NSLog(@"success:%@",objects);
//    if([objects count]>0)
//    {
//        Cross *cross=[objects lastObject];
//        NSLog(@"%@",cross.updated_at);
//        [[NSUserDefaults standardUserDefaults] setObject:cross.updated_at forKey:@"exfee_updated_at"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [self loadObjectsFromDataStore];
//    }
    
    //    Cross *cross=[objects objectAtIndex:0];
    //    NSLog(@"load:%@",cross);
    //    UsersLogin *result = [objects objectAtIndex:0];
    
    //    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}



@end
