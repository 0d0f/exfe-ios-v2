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

#import "EXSpinView.h"
#import "MBProgressHUD.h"
#import "APIExfee.h"

@interface HereViewController ()
@property (nonatomic, retain) EXHereHeaderView *headerView;
@property (nonatomic, retain) EXCardViewController *cardViewController;
@property (nonatomic, retain) EXPopoverController *popoverCardViewController;

@property (nonatomic, retain) EXLiveServiceController  *liveService;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) Card *meCard;
@property (nonatomic, retain) NSSet *othersCards;

@property (nonatomic, assign) BOOL canUpdateData;
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
    if (self.liveService.isRunning) {
        [self.liveService stop];
    }
    self.liveService = nil;
    self.locationManager = nil;
    self.currentLocation = nil;
    self.popoverCardViewController = nil;
    [_lock release];
    self.meCard = nil;
    self.othersCards = nil;
    self.cardViewController = nil;
    self.headerView = nil;
    if (_avatarlistview) {
        [_avatarlistview release];
        _avatarlistview = nil;
    }
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // headerView
    CGRect headerViewBounds;
    EXHereHeaderView *headerView = [[EXHereHeaderView alloc] init];
    headerViewBounds = headerView.bounds;
    [headerView.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headerView.gatherButton addTarget:self action:@selector(gatherButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
    self.liveService = [EXLiveServiceController defaultService];
    _liveService.cleanUpWhenStoped = NO;
    _liveService.delegate = self;
    _liveService.dataSource = self;
    
    [self.liveService start];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self becomeFirstResponder];
    self.canUpdateData = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.meCard = [Card cardWithDictionary:[self meCardParamsToSend]];
    [_avatarlistview reloadData];
    
    if (self.locationManager == nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 10.0f;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
    
    [self.liveService invokeUserCardUpdate];
}

#pragma mark - Motion Handle
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self motionShakeBegan];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self motionShakeEnded];
    }
}

- (void)motionShakeBegan {
    self.canUpdateData = NO;
    
    @autoreleasepool {
        NSSet *unselectedCells = [_avatarlistview unselectedCircleItemCells];
        NSMutableSet *cardsToRemove = [NSMutableSet setWithCapacity:[unselectedCells count]];
        for (EXCircleItemCell *cell in unselectedCells) {
            if (![cell.card isEqualToCard:self.meCard]) {
                [cardsToRemove addObject:cell.card];
            }
        }
        
        NSMutableSet *nowCards = [NSMutableSet setWithCapacity:[self.othersCards count]];
        for (Card *card in self.othersCards) {
            BOOL needRemove = NO;
            for (Card *toRemoveCard in cardsToRemove) {
                if ([card isEqualToCard:toRemoveCard]) {
                    needRemove = YES;
                    break;
                }
            }
            if (!needRemove) {
                [nowCards addObject:card];
            }
        }
        
        self.othersCards = nowCards;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_avatarlistview reloadData];
    });
}

- (void)motionShakeEnded {
    self.meCard = self.liveService.latestMeCard;
    self.othersCards = self.liveService.latestOthersCards;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_avatarlistview reloadData];
        self.canUpdateData = YES;
    });
}

#pragma mark - EXLiveServiceControllerDelegate
- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetMe:(Card *)me others:(NSSet *)cards {
    if (!self.canUpdateData)
        return;
    
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
        NSSet *visibleCells = [avatarCollectionView visibleCircleItemCells];
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

- (void)circleItemCellsNeedReload:(NSSet *)cells {
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
        self.canUpdateData = NO;
        
        NSSet *cells = [avatarCollectionView visibleCircleItemCells];
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
    NSSet *cells = [_avatarlistview visibleCircleItemCells];
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

- (void)cardViewControllerDidFinish:(EXCardViewController *)controller {
    self.meCard = self.liveService.latestMeCard;
    self.othersCards = self.liveService.latestOthersCards;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_avatarlistview reloadData];
        self.canUpdateData = YES;
    });
}

#pragma mark - Action
- (void)backButtonPressed:(id)sender {
    [self close];
}

- (void)gatherButtonPressed:(id)sender {
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding...";
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    
    NSSet *selectedCells = [_avatarlistview selectedCircleItemCells];
    NSMutableArray *identityParams = [[NSMutableArray alloc] initWithCapacity:[selectedCells count]];
    for (EXCircleItemCell *cell in selectedCells) {
        NSArray *cardIdentities = cell.card.identities;
        for (CardIdentitiy *anIdentity in cardIdentities) {
            [identityParams addObject:[anIdentity dictionaryValue]];
        }
    }
    
    [APIExfee getIdentitiesFromIdentityParams:identityParams
                                       succes:^(NSArray *identities){
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                           
                                           RKObjectManager *manager=[RKObjectManager sharedManager] ;
                                           manager.HTTPClient.parameterEncoding=AFJSONParameterEncoding;
                                           
                                           NSMutableArray *invitations = [[NSMutableArray alloc] initWithCapacity:[identities count]];
                                           
                                           for (Identity *identity in identities) {
                                               NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext];
                                               Invitation *invitation=[[[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext] autorelease];
                                               invitation.rsvp_status=@"NORESPONSE";
                                               invitation.identity=identity;
                                               Invitation *myinvitation=[self.exfee getMyInvitation];
                                               if(myinvitation!=nil)
                                                   invitation.updated_by=myinvitation.identity;
                                               else{
                                                   invitation.updated_by = [[[User getDefaultUser].identities allObjects] objectAtIndex:0];
                                               }
                                               [invitations addObject:invitation];
                                           }
                                           
                                           NSSet *set = [NSSet setWithArray:invitations];
                                           [invitations release];
                                           
                                           [self.exfee addInvitations:set];
                                           if (self.needSubmit) {
                                               [self submitExfeBeforeDismiss:self.exfee];
                                           } else {
                                               if (self.finishHandler) {
                                                   self.finishHandler();
                                                   [self close];
                                               }
                                           }
                                       }
                                      failure:^(NSError *error){
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          });
                                      }];
}

#pragma mark -
- (void)submitExfeBeforeDismiss:(Exfee*)exfee {
    Identity *myidentity = [self.exfee getMyInvitation].identity;
    [APIExfee edit:exfee
        myIdentity:[myidentity.identity_id intValue]
           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
               {
                   
                   if ([operation.HTTPRequestOperation.response statusCode] == 200){
                       if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
                       {
                           Meta* meta = (Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                           int code = [meta.code intValue];
                           int type = code /100;
                           switch (type) {
                               case 2: // HTTP OK
                                   if (code == 206) {
                                       NSLog(@"HTTP 206 Partial Successfully");
                                   }
                                   if(code == 200){
                                       Exfee *respExfee = [[mappingResult dictionary] objectForKey:@"response.exfee"];
                                       self.exfee = respExfee;
                                       if (self.finishHandler) {
                                           self.finishHandler();
                                           [self close];
                                       }
                                   }
                                   break;
                               case 4: // Client Error
                                   if(code == 403){
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       alert.tag=403;
                                       [alert show];
                                       [alert release];
                                   }
                                   break;
                               case 5: // Server Error
                                   break;
                               default:
                                   break;
                           }
                           
                           
                           
                       }
                   }
               }
           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
               ;
           }];
}


- (void)close {
    if ([CLLocationManager locationServicesEnabled] && self.locationManager) {
        [self.locationManager stopUpdatingLocation];
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.liveService stop];
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
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
