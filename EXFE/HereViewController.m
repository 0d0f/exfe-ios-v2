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
#import "EXPopoverController.h"
#import "EXPopoverCardViewController.h"
#import "EXStreamingServiceController.h"

#define kMinRegistCardsDuration             (5.0f)
#define kServerStreamingTimeroutInterval    (60.0f)

@interface HereViewController ()
@property (nonatomic, retain) EXHereHeaderView *headerView;
@property (nonatomic, retain) EXCardViewController *cardViewController;
@property (nonatomic, retain) EXPopoverController *popoverCardViewController;

@property (nonatomic, retain) EXStreamingServiceController  *streamingService;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) NSDate *latestRegistReqeustDate;
@property (nonatomic, assign) BOOL shouldInvokeLater;

@property (nonatomic, retain) AFHTTPClient *client;

@property (nonatomic, retain) NSSet *cards;
@property (nonatomic, copy) NSString *token;
@end

@implementation HereViewController {
    NSRecursiveLock *_lock;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.title = @"Here controller";
      self.view.backgroundColor=[UIColor whiteColor];
        _lock = [[NSRecursiveLock alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_popoverCardViewController release];
    [_lock release];
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
    
    // avatarView
    CGRect viewBounds = self.view.bounds;
    _avatarlistview = [[EXUserAvatarCollectionView alloc] initWithFrame:(CGRect){{0, CGRectGetHeight(headerViewBounds)},
        {CGRectGetWidth(viewBounds), CGRectGetHeight(viewBounds) - CGRectGetHeight(headerViewBounds)}}];
    _avatarlistview.backgroundColor = [UIColor clearColor];
    _avatarlistview.delegate = self;
    _avatarlistview.dataSource = self;
    _avatarlistview.scrollEnable = NO;
    [self.view addSubview:_avatarlistview];
    
    [self.view bringSubviewToFront:headerView];
    
    [_avatarlistview reloadData];
    
    // network
    if (!self.client) {
        self.client = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:SERVICE_ROOT]] autorelease];
        self.client.parameterEncoding = AFJSONParameterEncoding;
    }
    
    if (!self.streamingService) {
        _streamingService = [[EXStreamingServiceController alloc] initWithBaseURL:[NSURL URLWithString:SERVICE_ROOT]];
        
        NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
        outputStream.delegate = self;
        _streamingService.outputStream = outputStream;
        
        _streamingService.invokeHandler = ^{
            if (self.shouldInvokeLater) {
                [self sendLiveCardsRequest];
                self.shouldInvokeLater = NO;
            }
        };
        _streamingService.heartBeatHandler = ^{
            [self sendLiveCardsRequest];
        };
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.cards = [NSSet setWithObject:[Card cardWithDictionary:[self meCardParams]]];
    [_avatarlistview reloadData];
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10.0f;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
    
    if ([self canSendRequestNow]) {
        [self sendLiveCardsRequest];
    } else {
        self.shouldInvokeLater = YES;
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentLocation = newLocation;
        if ([self canSendRequestNow]) {
            [self sendLiveCardsRequest];
        } else {
            self.shouldInvokeLater = YES;
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = (CLLocation *)[locations lastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentLocation = newLocation;
        if ([self canSendRequestNow]) {
            [self sendLiveCardsRequest];
        } else {
            self.shouldInvokeLater = YES;
        }
    });
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
    
    [cell setCard:card
         animated:NO
         complete:nil];
    
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

- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didBeginLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath {
    EXCircleItemCell *cell = [avatarCollectionView circleItemCellAtIndexPath:indexPath];
    CGSize contentSize = [EXPopoverCardViewController cardSizeWithCard:cell.card];
    
    if (self.popoverCardViewController) {
        ((EXPopoverCardViewController *)self.popoverCardViewController.contentViewController).card = cell.card;
    } else {
        EXPopoverCardViewController *contentViewController = [[EXPopoverCardViewController alloc] initWithCard:cell.card];
        _popoverCardViewController = [[EXPopoverController alloc] initWithContentViewController:contentViewController];
        [contentViewController release];
    }
    
    self.popoverCardViewController.contentSize = contentSize;
    
    [_popoverCardViewController presentFromRect:cell.frame
                                         inView:_avatarlistview
                                 arrowDirection:kEXArrowDirectionAny
                                       animated:YES
                                       complete:nil];
}

- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didEndLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.popoverCardViewController dismissWithAnimated:YES complete:nil];
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
                                                          [self cleanUpWithTokenNeedClean:NO];
                                                      }];
}

- (NSDictionary *)meCardParams {
    User *me = [User getDefaultUser];
    NSMutableArray *identities = [[NSMutableArray alloc] initWithCapacity:me.identities.count];
    for (Identity *identity in me.identities) {
        NSDictionary *identityParam = @{@"external_id": identity.external_id, @"external_username": identity.external_username, @"provider": identity.provider};
        [identities addObject:identityParam];
    }
    
    NSDictionary *cardParams = @{@"id" : [NSString stringWithFormat:@"%@:%@", me.name, me.avatar_filename] , @"name" : me.name, @"avatar" : me.avatar_filename, @"bio" : me.bio, @"identities" : identities, @"is_me": [NSNumber numberWithBool:YES]};
    [identities release];
    
    return cardParams;
}

#pragma mark - runloop
- (void)heartRunloop:(NSTimer *)timer {
    [self sendLiveCardsRequest];
}

- (void)invokeRunloop:(NSTimer *)timer {
    if (self.shouldInvokeLater) {
        [self sendLiveCardsRequest];
        self.shouldInvokeLater = NO;
    }
}

#pragma mark - request
- (BOOL)canSendRequestNow {
    NSDate *now = [NSDate date];
    BOOL canSendRequest = YES;
    
    if (self.latestRegistReqeustDate) {
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.latestRegistReqeustDate];
        NSLog(@"!!!! %f", timeInterval);
        if (timeInterval >= kMinRegistCardsDuration) {
            self.latestRegistReqeustDate = now;
            canSendRequest = YES;
        } else {
            canSendRequest = NO;
        }
    } else {
        self.latestRegistReqeustDate = now;
        canSendRequest = YES;
    }
    
    return canSendRequest;
}

- (void)cleanUpWithTokenNeedClean:(BOOL)isTokenCleanNeeded {
    if (self.streamingService) {
        [self.streamingService stopStreaming];
    }
    
    [self.client.operationQueue cancelAllOperations];
    
    if (isTokenCleanNeeded) {
        self.token = nil;
    }
}

- (void)sendLiveCardsRequest {
    [_lock tryLock];
    
    NSDictionary *cardParams = [self meCardParams];
    NSMutableDictionary *params = [@{@"card": cardParams, @"traits": @[]} mutableCopy];
    if (self.currentLocation) {
        CLLocation *location = self.currentLocation;
        [params setValue:[NSString stringWithFormat:@"%f", location.coordinate.latitude] forKey:@"latitude"];
        [params setValue:[NSString stringWithFormat:@"%f", location.coordinate.longitude] forKey:@"longitude"];
        [params setValue:[NSString stringWithFormat:@"%f", location.horizontalAccuracy] forKey:@"accuracy"];
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
                      if (operation.response.statusCode >= 200 &&
                          operation.response.statusCode < 400) {
                          NSString *token = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] autorelease];
                          token = [token stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                          token = [token stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                          
                          if (self.token != nil &&
                              self.token.length != 0 &&
                              [self.token isEqualToString:token]) {
                              if (kEXStreamingServiceStateReady == self.streamingService.serviceState) {
                                  NSString *streamingPath = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
                                  [self.streamingService startStreamingWithPath:streamingPath
                                                                        success:nil
                                                                        failure:nil];
                              }
                          } else {
                              [self cleanUpWithTokenNeedClean:YES];
                              
                              self.token = token;
                              NSString *streamingPath = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
                              [self.streamingService startStreamingWithPath:streamingPath
                                                                    success:nil
                                                                    failure:nil];
                          }
                      }
                      
                      [_lock unlock];
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      if (403 == operation.response.statusCode ||
                          404 == operation.response.statusCode) {
                          [self cleanUpWithTokenNeedClean:YES];
                          
                          [self performSelector:_cmd];
                      }
                      [_lock unlock];
                  }];
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
                if ([self canSendRequestNow]) {
                    [self sendLiveCardsRequest];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.shouldInvokeLater = YES;
                    });
                }
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
                if (0 == [tempSet count]) {
                    tempSet = [NSSet setWithObject:[Card cardWithDictionary:[self meCardParams]]];
                }
                
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
