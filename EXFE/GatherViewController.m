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
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction) Gather:(id) sender{


    Identity *by_identity=[Identity object];
    by_identity.identity_id=[NSNumber numberWithInt:174];
    
    Cross *cross=[Cross object];
    cross.title=crosstitle.text;
    cross.cross_description=@"test desc";
    cross.by_identity=by_identity;
//    cross.cross_id=[NSNumber numberWithInt:1];
    Invitation *invitation=[Invitation object];
    invitation.identity=by_identity;
    invitation.by_identity=by_identity;
    invitation.rsvp_status=@"ACCEPTED";
    invitation.host=[NSNumber numberWithBool:YES];

    Exfee *exfee=[Exfee object];
    [exfee addInvitationsObject:invitation];
    cross.exfee = exfee;
    
    [APICrosses GatherCross:cross delegate:self];

//        RKParams* params = [RKParams params];
//        [params setValue:cross forParam:@"cross"];
//    [[RKObjectManager sharedManager] postObject:cross delegate:self block:^(RKObjectLoader *loader){
//        
//        RKParams* params = [RKParams params];
//        [params setValue:pet.accountId forParam:@"accountId"];
//        [params setValue:pet.identifier forParam:@"petId"];
//        [params setValue:_photoId forParam:@"photoId"];
//        [params setValue:_isThumb ? @"THUMB" : @"FULL" forParam:@"photoSize"];
//        [params setData:data MIMEType:@"image/png" forParam:@"image"];
//        
//        loader.params = params;
//    }];
    
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=postParams;
//        request.onDidLoadResponse=^(RKResponse *response){
//           //navigationController
//            NSArray *viewControllers = app.navigationController.viewControllers;
//            CrossesViewController *rootViewController = [viewControllers objectAtIndex:0];
//            
//
//            NSLog(@"%@",response.bodyAsString);
//            if (response.statusCode == 200) {
//                NSLog(@"%@",response);
//                [rootViewController refreshCrosses:@"gatherview"];
////                NSLog(@"%@",response.bodyAsString);
////                [self refreshConversation];
//            }else {
////                NSLog(@"%@",response);
////                //Check Response Body to get Data!
//            }
//        };
//        request.delegate=self;
//    }];
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
- (IBAction) Close:(id) sender{
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {

    if([objects count]>0)
    {
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app GatherCrossDidFinish];
    }
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
//    [self stopLoading];
}


@end
