//
//  HereViewController.m
//  EXFE
//
//  Created by huoju on 3/26/13.
//
//

#import "HereViewController.h"

#import "EXHereHeaderView.h"

@interface HereViewController ()
@property (nonatomic, retain) EXHereHeaderView *headerView;
@property (nonatomic, retain) EXCardViewController *cardViewController;
@end

@implementation HereViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.title = @"Here controller";
      self.view.backgroundColor=[UIColor whiteColor];

      UIButton *start =[UIButton buttonWithType:UIButtonTypeRoundedRect];
      [start setFrame:CGRectMake(256,50,60,40)];
      [start setTitle:@"Start" forState:UIControlStateNormal];
      [start addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:start];
    }
    return self;
}

- (void)dealloc {
    [_cardViewController release];
    [_headerView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    User* me = [User getDefaultUser];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://panda.0d0f.com:23333/v3/here/streaming?token=n%i",[me.user_id intValue]]]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToMemory];
    [operation.outputStream setDelegate:self];
    [operation start];
    _data = [[NSMutableData alloc] init];
    
    // headerView
    CGRect headerViewBounds;
    EXHereHeaderView *headerView = [[EXHereHeaderView alloc] init];
    headerViewBounds = headerView.bounds;
    [headerView.backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.headerView = headerView;
    [self.view addSubview:headerView];
    [headerView release];
    
    CGRect viewBounds = self.view.bounds;
    _avatarlistview = [[EXUserAvatarCollectionView alloc] initWithFrame:(CGRect){{0, CGRectGetHeight(headerViewBounds)},
        {CGRectGetWidth(viewBounds), CGRectGetHeight(viewBounds) - CGRectGetHeight(headerViewBounds)}}];
    [_avatarlistview setBackgroundColor:[UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)]];
    _avatarlistview.delegate = self;
    _avatarlistview.dataSource = self;
    [self.view addSubview:_avatarlistview];
    
    [_avatarlistview reloadData];
}

#pragma mark - UserAvatarCollectionDataSource
- (NSInteger)numberOfCircleItemInAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView {
    return 12;
}

- (EXCircleItemCell *)circleItemForAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView atIndex:(int)index {
    EXCircleItemCell *cell = [[[EXCircleItemCell alloc] init] autorelease];
    
#warning test only 需要拿到实际数据后替换
    cell.user = [User getDefaultUser];
    
    return cell;
}

#pragma mark - UserAvatarCollectionDelegate
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didSelectCircleItemAtIndex:(int)index {
    if (index == 0) {
        NSArray *cells = [avatarCollectionView visibleCircleItemCells];
        [UIView animateWithDuration:0.25f
                         animations:^{
                             for (EXCircleItemCell *cell in cells) {
                                 if (0 != cell.index) {
                                     cell.alpha = 0.5f;
                                 } else {
                                     cell.titleLabel.alpha = 0.0f;
                                 }
                             }
                         }];
        
        if (nil == _cardViewController) {
            _cardViewController = [[EXCardViewController alloc] init];
            _cardViewController.user = [User getDefaultUser];
            _cardViewController.delegate = self;
        }

        [_cardViewController presentFromViewController:self
                                              animated:YES
                                            completion:nil];
    }
}

- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didLongPressCircleItemAtIndex:(int)index {

}

#pragma mark - EXCardViewControllerDelegate
- (void)cardViewControllerWillFinish:(EXCardViewController *)controller {
    NSArray *cells = [_avatarlistview visibleCircleItemCells];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         for (EXCircleItemCell *cell in cells) {
                             if (0 != cell.index) {
                                 cell.alpha = 1.0f;
                             } else {
                                 cell.titleLabel.alpha = 1.0f;
                             }
                         }
                     }];
}

- (void)cardViewControllerDidFinish:(EXCardViewController *)controller {}

#pragma mark - Public
- (void)close {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)start {
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

#pragma mark - NSStreamDelegate
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
