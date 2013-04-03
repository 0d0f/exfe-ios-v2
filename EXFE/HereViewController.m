//
//  HereViewController.m
//  EXFE
//
//  Created by huoju on 3/26/13.
//
//

#import "HereViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "EXHereHeaderView.h"
#import "Card.h"

#define kServerStreamingTimeroutInterval    (60.0f)

@interface HereViewController ()
@property (nonatomic, retain) EXHereHeaderView *headerView;
@property (nonatomic, retain) EXCardViewController *cardViewController;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) AFHTTPClient *client;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSSet *cards;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign, setter = setStreamOpened:) BOOL isStreamOpened;
@end

@implementation HereViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.title = @"Here controller";
      self.view.backgroundColor=[UIColor whiteColor];
    }
    
    return self;
}

- (void)dealloc {
    [_cards release];
    [_cardViewController release];
    [_headerView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // headerView
    CGRect headerViewBounds;
    EXHereHeaderView *headerView = [[EXHereHeaderView alloc] init];
    headerViewBounds = headerView.bounds;
    [headerView.backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.headerView = headerView;
    [self.view addSubview:headerView];
    [headerView release];
    
    self.cards = [NSSet setWithObject:[Card cardWithDictionary:[self meCardParams]]];
    
    CGRect viewBounds = self.view.bounds;
    _avatarlistview = [[EXUserAvatarCollectionView alloc] initWithFrame:(CGRect){{0, CGRectGetHeight(headerViewBounds)},
        {CGRectGetWidth(viewBounds), CGRectGetHeight(viewBounds) - CGRectGetHeight(headerViewBounds)}}];
    _avatarlistview.backgroundColor = [UIColor clearColor];
    _avatarlistview.delegate = self;
    _avatarlistview.dataSource = self;
    _avatarlistview.scrollEnable = NO;
    [self.view addSubview:_avatarlistview];
    
    [_avatarlistview reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10.0f;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
    [self registerCard];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    if (-[newLocation.timestamp timeIntervalSinceNow] <= 60) {
        [self registerCard];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    NSTimeInterval timerInterval = -[((CLLocation *)[locations lastObject]).timestamp timeIntervalSinceNow];
    if (timerInterval <= 60) {
        [self registerCard];
    }
}

#pragma mark - UserAvatarCollectionDataSource
- (NSInteger)numberOfCircleItemInAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView {
    return [self.cards count];
}

- (EXCircleItemCell *)circleItemForAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView
                                            atIndexPath:(NSIndexPath *)indexPath {
    EXCircleItemCell *cell = [avatarCollectionView dequeueReusableCircleItemCell];
    if (nil == cell) {
        cell = [[[EXCircleItemCell alloc] init] autorelease];
    }
    
    Card *card = nil;
    if (NSOrderedSame == [indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        // me
        for (Card *aCard in self.cards) {
            if (aCard.isMe) {
                card = aCard;
                break;
            }
        }
//        NSAssert(card != nil, @"Card中没有自己");
    } else {
        // others
        NSArray *visibleCells = [avatarCollectionView visibleCircleItemCells];
        for (Card *aCard in self.cards) {
            BOOL hasShown = NO;
            for (EXCircleItemCell *visibleCell in visibleCells) {
                if ([aCard isEqualToCard:visibleCell.card]) {
                    hasShown = YES;
                    break;
                }
            }
            if (!hasShown) {
                card = aCard;
                break;
            }
        }
    }
    
    cell.card = card;
    
    return cell;
}

- (BOOL)shouldCircleItemCell:(EXCircleItemCell *)cell removeFromAvatarCollectionView:(EXUserAvatarCollectionView *)collectionView {
    Card *card = cell.card;
    for (Card *aCard in self.cards) {
        if ([aCard isEqualToCard:card]) {
            return NO;
        }
    }
    return YES;
}

- (void)reloadCircleItemCells:(NSSet *)cells {
    for (EXCircleItemCell *cell in cells) {
        for (Card *card in self.cards) {
            if ([cell.card isEqualToCard:card]) {
                cell.card = card;
            }
        }
    }
}

#pragma mark - UserAvatarCollectionDelegate
- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didSelectCircleItemAtIndexPath:(NSIndexPath *)indexPath {
    if (NSOrderedSame == [indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        NSArray *cells = [avatarCollectionView visibleCircleItemCells];
        [UIView animateWithDuration:0.25f
                         animations:^{
                             for (EXCircleItemCell *cell in cells) {
                                 if (NSOrderedSame != [cell.indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
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

- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - EXCardViewControllerDelegate
- (void)cardViewControllerWillFinish:(EXCardViewController *)controller {
    NSArray *cells = [_avatarlistview visibleCircleItemCells];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         for (EXCircleItemCell *cell in cells) {
                             if (NSOrderedSame != [cell.indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
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
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          if ([CLLocationManager locationServicesEnabled] && self.locationManager) {
                                                              [self.locationManager stopUpdatingLocation];
                                                          }
                                                          [UIApplication sharedApplication].idleTimerDisabled = NO;
                                                          [self cleanUpTimerAndRequestWithTokenNeedClean:NO];
                                                      }];
}

- (NSDictionary *)meCardParams {
    User *me = [User getDefaultUser];
    NSMutableArray *identities = [[NSMutableArray alloc] initWithCapacity:me.identities.count];
    for (Identity *identity in me.identities) {
        NSDictionary *identityParam = @{@"external_id": identity.external_id, @"external_username": identity.external_username, @"provider": identity.provider};
        [identities addObject:identityParam];
    }
    
    NSDictionary *cardParams = @{@"id" : [NSString stringWithFormat:@"n%i", [me.user_id intValue]] , @"name" : me.name, @"avatar" : me.avatar_filename, @"bio" : me.bio, @"identities" : identities, @"is_me": [NSNumber numberWithBool:YES]};
    [identities release];
    
    return cardParams;
}

#pragma mark - runloop
- (void)runloop:(NSTimer *)timer {
    [self registerCard];
}

#pragma mark - request
- (void)cleanUpTimerAndRequestWithTokenNeedClean:(BOOL)isTokenCleanNeeded {
    if ([self.timer isValid]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.timer invalidate];
            self.timer = nil;
        });
    }
    
    if (isTokenCleanNeeded) {
        self.token = nil;
    }
    
    if (self.outputStream) {
        [self.outputStream close];
        self.outputStream = nil;
    }
    [self.client.operationQueue cancelAllOperations];
    self.isStreamOpened = NO;
}

- (void)registerCard {
    NSDictionary *cardParams = [self meCardParams];
    NSMutableDictionary *params = [@{@"card": cardParams, @"traits": @[]} mutableCopy];
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocation *location = self.locationManager.location;
        [params setValue:@(location.coordinate.latitude) forKey:@"latitude"];
        [params setValue:@(location.coordinate.longitude) forKey:@"longitude"];
        [params setValue:@(location.horizontalAccuracy) forKey:@"accuracy"];
    }
    
    if (!self.client) {
        self.client = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SERVICE_ROOT]] autorelease];
        self.client.parameterEncoding=AFJSONParameterEncoding;
    }
    
    NSString *path = nil;
    if (self.token != nil && self.token.length) {
        path = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT,@"live/cards", self.token];
    } else {
        path = [NSString stringWithFormat:@"%@/%@",SERVICE_ROOT,@"live/cards"];
    }
    
    [self.client postPath:path
               parameters:params
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      if (200 == operation.response.statusCode) {
                          NSString *token = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] autorelease];
                          token = [token stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                          token = [token stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                          if (self.token != nil &&
                              self.token.length != 0 &&
                              [self.token isEqualToString:token]) {
                              if (!self.isStreamOpened) {
                                  [self startStreaming];
                              }
                          } else {
                              [self cleanUpTimerAndRequestWithTokenNeedClean:YES];
                              
                              self.token = token;
                              [self startStreaming];
                          }
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (403 == operation.response.statusCode) {
                          [self cleanUpTimerAndRequestWithTokenNeedClean:YES];
                          
                          [self performSelector:_cmd];
                      }
                  }];
}

- (void)startStreaming {
    self.isStreamOpened = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f * kServerStreamingTimeroutInterval
                                                      target:self
                                                    selector:@selector(runloop:)
                                                    userInfo:nil
                                                     repeats:YES];
    });
    
    NSString *path=[NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
    NSMutableURLRequest *request = [self.client requestWithMethod:@"GET"
                                                             path:path
                                                       parameters:nil];
    request.timeoutInterval = 120.0f;
    AFHTTPRequestOperation *operation = [self.client HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                 NSLog(@"%@", responseObject);
                                                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                 NSLog(@"%@", error);
                                                                             }];
    self.outputStream = [NSOutputStream outputStreamToMemory];
    operation.outputStream = self.outputStream;
    operation.outputStream.delegate = self;
    
    [self.client.operationQueue addOperation:operation];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
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

            NSArray *array = [string componentsSeparatedByString:@"\n"];
            
            if ([array count] == 0) {
                // restart
                [self registerCard];
            } else {
                NSString *lastJSON = [array lastObject];
                data = [lastJSON dataUsingEncoding:NSUTF8StringEncoding];
                
                NSArray *cardsInDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSMutableDictionary *cardDict = [[NSMutableDictionary alloc] initWithCapacity:[cardsInDict count]];
                for (NSDictionary *param in cardsInDict) {
                    Card *newCard = [Card cardWithDictionary:param];
                    NSString *key = [NSString stringWithFormat:@"%@%@", newCard.userName, newCard.avatarURLString];
                    Card *oldCard = [cardDict valueForKey:key];
                    if (oldCard) {
                        if (newCard.timeStamp > oldCard.timeStamp) {
                            [cardDict setValue:newCard forKey:key];
                        }
                    } else {
                        [cardDict setValue:newCard forKey:key];
                    }
                }
                
                NSSet *tempSet = [NSSet setWithArray:[cardDict allValues]];
                self.cards = tempSet;
                
                NSLog(@"Cards:\n%@", self.cards);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_avatarlistview reloadData];
                });
            }
            
            NSLog(@"Stream HasSpaceAvailable");
            break;
        }
        default:
            NSLog(@"Unknown event: %@ : %d", stream, eventCode);
    }
}

@end
