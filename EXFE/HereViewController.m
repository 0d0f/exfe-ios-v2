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

@interface HereViewController ()
@property (nonatomic, retain) EXHereHeaderView *headerView;
@property (nonatomic, retain) EXCardViewController *cardViewController;
@property (nonatomic, retain) EXPopoverController *popoverCardViewController;

@property (nonatomic, retain) EXLiveServiceController  *liveService;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) Card *meCard;
@property (nonatomic, retain) NSSet *othersCards;
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
    [_meCard release];
    [_othersCards release];
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
    
    self.meCard = [Card cardWithDictionary:[self meCardParamsToSend]];
    
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
    
    // live service
    _liveService = [[EXLiveServiceController alloc] init];
    _liveService.cleanUpWhenStoped = NO;
    _liveService.delegate = self;
    _liveService.dataSource = self;
    
    [self.liveService start];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.meCard = [Card cardWithDictionary:[self meCardParamsToSend]];
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
    
    [self.liveService invokeUserCardUpdate];
}

#pragma mark - EXLiveServiceControllerDelegate
- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetMe:(Card *)me others:(NSSet *)cards {
    self.meCard = me;
    self.othersCards = cards;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_avatarlistview reloadData];
    });
}

#pragma mark - EXLiveServiceControllerDataSource
- (NSDictionary *)postBodyParamForliveServiceController:(EXLiveServiceController *)serviceController {
    NSMutableDictionary *param = [[NSMutableDictionary alloc ] initWithObjectsAndKeys:
                                  [self meCardParamsToSend], @"card",
                                  @[], @"traits", nil];
    
    if (self.currentLocation) {
        [param setValue:[NSString stringWithFormat:@"%lf", self.currentLocation.coordinate.latitude] forKey:@"latitude"];
        [param setValue:[NSString stringWithFormat:@"%lf", self.currentLocation.coordinate.longitude] forKey:@"longitude"];
        [param setValue:[NSString stringWithFormat:@"%lf", self.currentLocation.horizontalAccuracy] forKey:@"accuracy"];
    }
    
    NSDictionary *postBody = [[param copy] autorelease];
    [param release];
    
    return postBody;
}

- (NSDictionary *)meCardDictionaryForliveServiceController:(EXLiveServiceController *)serviceController {
    return [self meCardParamsToSend];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentLocation = newLocation;
        [self.liveService invokeUserCardUpdate];
    });
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = (CLLocation *)[locations lastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentLocation = newLocation;
        [self.liveService invokeUserCardUpdate];
    });
}

#pragma mark - UserAvatarCollectionDataSource
- (NSInteger)numberOfCircleItemInAvatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView {
    return [self.othersCards count] + 1; // + me
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
        card = self.meCard;
    } else {
        // others
        NSArray *visibleCells = [avatarCollectionView visibleCircleItemCells];
        for (Card *aCard in self.othersCards) {
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
    if (NSOrderedSame == [cell.indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]])
        return NO;
    Card *card = cell.card;
    for (Card *aCard in self.othersCards) {
        if ([aCard isEqualToCard:card]) {
            return NO;
        }
    }
    return YES;
}

- (void)reloadCircleItemCells:(NSSet *)cells {
    for (EXCircleItemCell *cell in cells) {
        if (NSOrderedSame == [cell.indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
            [cell setCard:self.meCard animated:NO complete:nil];
        } else {
            for (Card *card in self.othersCards) {
                if ([cell.card isEqualToCard:card]) {
                    cell.card = card;
                    break;
                }
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
                                                          [self.liveService stop];
                                                      }];
}

- (NSDictionary *)meCardParamsToSend {
    User *me = [User getDefaultUser];
    NSMutableArray *identities = [[NSMutableArray alloc] initWithCapacity:me.identities.count];
    
    if (self.cardViewController.identityPrivacyDict) {
        NSDictionary *identityPrivacyDict = self.cardViewController.identityPrivacyDict;
        
        for (Identity *identity in me.identities) {
            NSString *key = [NSString stringWithFormat:@"%@%@%@", identity.external_id, identity.external_username, identity.provider];
            if ([[identityPrivacyDict valueForKey:key] boolValue]) {
                NSDictionary *identityParam = @{@"external_id": identity.external_id, @"external_username": identity.external_username, @"provider": identity.provider};
                [identities addObject:identityParam];
            }
        }
    } else {
        for (Identity *identity in me.identities) {
            NSDictionary *identityParam = @{@"external_id": identity.external_id, @"external_username": identity.external_username, @"provider": identity.provider};
            [identities addObject:identityParam];
        }
    }
    
    NSDictionary *cardParams = @{@"id" : (self.liveService.cardID && self.liveService.cardID.length) ? self.liveService.cardID : @"" , @"name" : me.name, @"avatar" : me.avatar_filename, @"bio" : me.bio, @"identities" : identities, @"is_me": [NSNumber numberWithBool:YES]};
    [identities release];
    
    return cardParams;
}


@end
