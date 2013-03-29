//
//  HereViewController.m
//  EXFE
//
//  Created by huoju on 3/26/13.
//
//

#import "HereViewController.h"

@interface HereViewController ()

@end

@implementation HereViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.title = @"Here controller";
      self.view.backgroundColor=[UIColor whiteColor];
      UIButton *close =[UIButton buttonWithType:UIButtonTypeRoundedRect];
      [close setFrame:CGRectMake(20,10,60,20)];
      [close setTitle:@"Close" forState:UIControlStateNormal];
      [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:close];


      UIButton *start =[UIButton buttonWithType:UIButtonTypeRoundedRect];
      [start setFrame:CGRectMake(100,100,60,40)];
      [start setTitle:@"Start" forState:UIControlStateNormal];
      [start addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:start];
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  User* me=[User getDefaultUser];
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://panda.0d0f.com:23333/v3/here/streaming?token=n%i",[me.user_id intValue]]]];
  AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.outputStream = [NSOutputStream outputStreamToMemory];
  [operation.outputStream setDelegate:self];
  [operation start];
  _data = [[NSMutableData alloc] init];
  
  avatarlistview=[[EXUserAvatarCollectionView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
  [avatarlistview setBackgroundColor:[UIColor grayColor]];
  [avatarlistview setDataSource:self];
  [self.view addSubview:avatarlistview];
  [avatarlistview reloadData];
  
}

- (NSInteger) numberOfAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView{
  return 1;
  
}
- (id)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView itemAtIndex:(int)index{
  EXCircleItemCell *cell = [[EXCircleItemCell alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
  [cell setBackgroundColor:[UIColor blueColor]];
  return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) close{
  [self dismissModalViewControllerAnimated:YES];
}
- (void) start{
  User* me=[User getDefaultUser];
  NSMutableArray *identities=[[NSMutableArray alloc] initWithCapacity:me.identities.count];
  for (Identity *identity in me.identities)
  {
    [identities addObject:@{@"id":[NSString stringWithFormat:@"%@@%@",identity.external_id,identity.provider]}];
  }

//  NSString *ip=[Util getIPAddress];

  NSDictionary *dict=@{@"id":[NSString stringWithFormat:@"n%i",[me.user_id intValue]],@"name":me.name,@"avatar":me.avatar_filename,@"bio":me.bio,@"identities":identities,@"traits":@[]};
  
  AFHTTPClient *cilent=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SERVICE_ROOT]];
  NSString *path=[NSString stringWithFormat:@"%@/%@",SERVICE_ROOT,@"here/users"];
  cilent.parameterEncoding=AFJSONParameterEncoding;
  [cilent postPath:path parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    NSLog(@"%@",responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    NSLog(@"%@",error);
  }];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
//  NSLog(@"Unknown event: %@ : %d", stream, eventCode);
  switch (eventCode) {
    case NSStreamEventOpenCompleted:
      NSLog(@"Stream opened");
      break;
    case NSStreamEventHasBytesAvailable:
      NSLog(@"HasBytesAvailable");
      break;
    case NSStreamEventErrorOccurred:
      NSLog(@"Can not connect to the host!");
      break;
    case NSStreamEventEndEncountered:
      NSLog(@"Stream closed");
      break;
    case NSStreamEventHasSpaceAvailable:
    {

      NSData *data = (NSData *)[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
      NSString *string = [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:[NSString defaultCStringEncoding]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
                          
      NSArray *array=[string componentsSeparatedByString:@"\n"];
      
      NSLog(@"%@",[array objectAtIndex:[array count]-1]);
      NSLog(@"Stream HasSpaceAvailable");
      break;
    }
    default:
      NSLog(@"Unknown event: %@ : %d", stream, eventCode);
  }
}

@end
