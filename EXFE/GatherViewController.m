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

    exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle becomeFirstResponder];

    suggestionTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,60,60) style:UITableViewStylePlain];
    suggestionTable.dataSource=self;
    suggestionTable.delegate=self;
    
    [exfeeShowview setDataSource:self];
    [exfeeShowview setDelegate:self];
    [self addDefaultIdentity];
    // Do any additional setup after loading the view from its nib.
}

- (void) addDefaultIdentity{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0)
    {
        User *user=[users objectAtIndex:0];
        if(user!=nil){
            [exfeeIdentities addObject:user.default_identity];
            [exfeeShowview reloadData];
        }
    }
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
}
- (void)dealloc {
	[exfeeIdentities release];
    [suggestIdentities release];
    [super dealloc];
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

- (IBAction)textEditBegin:(id)textField
{
}

- (IBAction)textDidChange:(UITextField*)textField
{
    if(ExfeeInput.text!=nil && ExfeeInput.text.length>=1) {
        [APIProfile LoadSuggest:ExfeeInput.text delegate:self];
        [self loadIdentitiesFromDataStore];
    }
    else{
        [suggestionTable removeFromSuperview];
    }
}

- (void)loadIdentitiesFromDataStore {
        NSLog(@"%@",@"loadIdentitiesFromDataStore");
        [suggestIdentities release];
        NSFetchRequest* request = [Identity fetchRequest];
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];

        NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",ExfeeInput.text];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((name like[c] %@) OR (external_username like[c] %@) OR (external_id like[c] %@) OR (nickname like[c] %@)) AND provider != %@ AND  provider != %@ ",inputpredicate,inputpredicate,inputpredicate,inputpredicate,@"iOSAPN",@"android"];
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        NSMutableArray *temp=[[NSMutableArray alloc]initWithCapacity:10];
        NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
        for (Identity *identity in suggestwithselected){
            BOOL flag=NO;
            for (Identity *selected in exfeeIdentities){
                if([selected.identity_id intValue]==[identity.identity_id intValue])
                {
                    flag=YES;
                    continue;
                }
            }
            if(flag==NO)
                [temp addObject:identity];
        }
        
        suggestIdentities=[temp retain];
        [temp release];
        if([suggestIdentities count]>0)
        {
            [suggestionTable reloadData];
            CGRect rect=ExfeeInput.frame;
            [suggestionTable setFrame:CGRectMake(rect.origin.x, rect.origin.y+rect.size.height, rect.size.width, 200)];
            [suggestionTable setHidden:NO];
            [self.view addSubview:suggestionTable];
        }

}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {

    if([objects count]>0)
    {
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if([objectLoader.userData isEqualToString:@"suggest"])
            [self loadIdentitiesFromDataStore];
        else
            [app GatherCrossDidFinish];
    }
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
//    [self stopLoading];
}

#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
//	return [_crosses count];
    if(suggestIdentities)
        return [suggestIdentities count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"suggest view";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
	cell.textLabel.text = identity.name;
	
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
    [exfeeIdentities addObject:identity];
    [exfeeShowview reloadData];
    [suggestionTable removeFromSuperview];
}

#pragma mark EXImagesCollectionView Datasource methods

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [exfeeIdentities count];
}
- (UIImage *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index{
    
    Identity *identity=[exfeeIdentities objectAtIndex:index];
    UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
    return avatar;
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col {
    
    NSLog(@"exfee click index:%i, row:%i, col:%i",index,row,col);
}

@end
