//
//  GatherViewController.m
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import "GatherViewController.h"

@interface GatherViewController ()

@end

@implementation GatherViewController

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
    // Do any additional setup after loading the view from its nib.
}
- (IBAction) Gather:(id) sender{
    RKClient *client = [RKClient sharedClient];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSDictionary *identity_0=[NSDictionary dictionaryWithKeysAndObjects:@"id",[NSNumber numberWithInt:174], nil];
    
    NSDictionary *invitation_0=[NSDictionary dictionaryWithKeysAndObjects:@"identity",identity_0,@"rsvp_status",@"ACCEPTED",@"type", @"Invitation",nil];

    NSDictionary *identity_1=[NSDictionary dictionaryWithKeysAndObjects:@"id",[NSNumber numberWithInt:190], nil];
    NSDictionary *invitation_1=[NSDictionary dictionaryWithKeysAndObjects:@"identity",identity_1,@"rsvp_status", @"ACCEPTED",@"type", @"Invitation",nil];
    NSArray *invitations=[NSArray arrayWithObjects:invitation_0,invitation_1, nil];
    
    NSDictionary *place=[NSDictionary dictionaryWithKeysAndObjects:@"description",@"",@"external_id", @"", @"lat",@"23.13177681",@"lng",@"113.26757050",@"provider",@"place title",@"title",@"by ios",@"type", @"Place",nil];

    NSDictionary *exfee=[NSDictionary dictionaryWithKeysAndObjects:@"invitations",invitations,@"type",@"Exfee" ,nil];
    
    NSDictionary *postdict=[NSDictionary dictionaryWithKeysAndObjects:@"host_id",[NSNumber numberWithInt:174],@"description",@"desc...",@"relative",[NSArray arrayWithObjects:nil], @"title",@"post by iPhone 5",@"exfee",exfee,@"place",place,@"type", @"Cross", @"via",@"iOS",nil];
    NSString *test=[postdict JSONString];
    NSLog(@"%@",test);
    RKParams* postParams = [RKParams params];
    [postParams setValue:[postdict JSONString] forParam:@"cross"];
    [postParams setValue:[NSNumber numberWithInt:174] forParam:@"by_identity_id"];
    
    NSString *endpoint = [NSString stringWithFormat:@"/crosses/add?token=%@",app.accesstoken];
    
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.params=postParams;
        request.onDidLoadResponse=^(RKResponse *response){
           //navigationController
            NSArray *viewControllers = app.navigationController.viewControllers;
            CrossesViewController *rootViewController = [viewControllers objectAtIndex:0];
            [rootViewController refreshCrosses:@"gatherview"];

            NSLog(@"%@",response.bodyAsString);
//            if (response.statusCode == 200) {
//                NSLog(@"%@",response.bodyAsString);
//                [self refreshConversation];
//            }else {
//                NSLog(@"%@",response);
//                //Check Response Body to get Data!
//            }
        };
        request.delegate=self;
    }];
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

@end
