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

@property (nonatomic, retain) UILabel *networkLabel;

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
        
        _cardViewController = [[EXCardViewController alloc] init];
        _cardViewController.user = [User getDefaultUser];
        _cardViewController.delegate = self;
    }
    
    return self;
}

- (void)dealloc {
    if (self.liveService.isRunning) {
        [self.liveService stop];
    }
    [_networkLabel release];
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
    
    // bg Color
    UIImage *bgColorImage = [UIImage imageNamed:@"livebg.png"];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:bgColorImage];
    backgroundView.frame = self.view.bounds;
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
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
    
    // network label
    UILabel *networkLabel = [[UILabel alloc] initWithFrame:(CGRect){{5, CGRectGetHeight(self.view.frame) - 12}, {310, 12}}];
    networkLabel.backgroundColor = [UIColor clearColor];
    networkLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.4f];
    networkLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:networkLabel];
    _networkLabel = networkLabel;
    
    // live service
    self.liveService = [EXLiveServiceController defaultService];
    _liveService.cleanUpWhenStoped = NO;
    _liveService.delegate = self;
    _liveService.dataSource = self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self becomeFirstResponder];
    self.canUpdateData = YES;
    
    self.headerView.gatherButton.enabled = NO;
    
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
    
    [self.liveService start];
}

#pragma mark - Motion Handle
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"Motion Began: %d", motion);
    if (motion == UIEventSubtypeMotionShake) {
        [self motionShakeBegan];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"Motion Ended: %d", motion);
    if (motion == UIEventSubtypeMotionShake) {
        [self motionShakeEnded];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"Motion Cancelled: %d", motion);
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
        NSSet *visbleCells = [_avatarlistview visibleCircleItemCells];
        NSMutableSet *visibleCards = [NSMutableSet setWithCapacity:[unselectedCells count]];
        for (EXCircleItemCell *cell in visbleCells) {
            if (![cell.card isEqualToCard:self.meCard]) {
                [visibleCards addObject:cell.card];
            }
        }
        
        [visibleCards minusSet:cardsToRemove];
        
        self.othersCards = visibleCards;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_avatarlistview reloadData];
    });
}

- (void)motionShakeEnded {
    self.meCard = self.liveService.latestMeCard ?: [Card cardWithDictionary:[self meCardParamsToSend]];
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm";
        self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Stream got %d cards [timestamp: %@]", [cards count], [formatter stringFromDate:[NSDate date]]];
        [formatter release];
    });
}

- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetToken:(NSString *)totken andCardID:(NSString *)cardID {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm";
    self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Got token:%@ [timestamp: %@]", totken, [formatter stringFromDate:[NSDate date]]];
    [formatter release];
}

- (void)liveServiceControllerTokenDidInvalid:(EXLiveServiceController *)serviceController willRetry:(BOOL)retry {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm";
    self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Token Invalid [timestamp: %@]", [formatter stringFromDate:[NSDate date]]];
    [formatter release];
}

- (void)liveServiceControllerStreamDidOpen:(EXLiveServiceController *)serviceController {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm";
    self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Stream opened [timestamp: %@]", [formatter stringFromDate:[NSDate date]]];
    [formatter release];
}

- (void)liveServiceControllerStreamDidFail:(EXLiveServiceController *)serviceController {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm";
    self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Stream failed [timestamp: %@]", [formatter stringFromDate:[NSDate date]]];
    [formatter release];
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm";
        self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Got location [timestamp: %@]", [formatter stringFromDate:[NSDate date]]];
        [formatter release];
        
        self.currentLocation = newLocation;
        [self.liveService invokeUserCardUpdate];
    });
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = (CLLocation *)[locations lastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm";
        self.networkLabel.text = [NSString stringWithFormat:@"DEBUG info: Got location [timestamp: %@]", [formatter stringFromDate:[NSDate date]]];
        [formatter release];
        
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
        CGRect titleLabelFrame = cell.titleLabel.frame;
        titleLabelFrame.origin.x = 0.0;
        titleLabelFrame.size.width = 200.0f;
        cell.titleLabel.frame = titleLabelFrame;
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
        
        [_cardViewController presentFromViewController:self
                                              animated:YES
                                            completion:nil];
    }
    
    NSSet *selectedCells = [avatarCollectionView selectedCircleItemCells];
    if ([selectedCells count]) {
        self.headerView.gatherButton.enabled = YES;
    } else {
        self.headerView.gatherButton.enabled = NO;
    }
}

- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didBeginLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath {
    EXCircleItemCell *cell = [avatarCollectionView circleItemCellAtIndexPath:indexPath];
    CGSize contentSize = [EXPopoverCardViewController cardSizeWithCard:cell.card];
    
    if (self.popoverCardViewController) {
        ((EXPopoverCardViewController *)self.popoverCardViewController.contentViewController).card = cell.card;
    } else {
        EXPopoverCardViewController *contentViewController = [[EXPopoverCardViewController alloc] initWithCard:cell.card];
        contentViewController.tableView.showsHorizontalScrollIndicator = NO;
        contentViewController.tableView.showsVerticalScrollIndicator = NO;
        _popoverCardViewController = [[EXPopoverController alloc] initWithContentViewController:contentViewController];
        [contentViewController release];
    }
    
    self.popoverCardViewController.contentSize = contentSize;
    
    [_popoverCardViewController presentFromRect:cell.frame
                                         inView:_avatarlistview
                                 arrowDirection:kEXArrowDirectionUp | kEXArrowDirectionDown
                                       animated:YES
                                       complete:nil];
}

- (void)avatarCollectionView:(EXUserAvatarCollectionView *)avatarCollectionView didEndLongPressCircleItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.popoverCardViewController dismissWithAnimated:YES complete:nil];
}

#pragma mark - EXCardViewControllerDelegate
- (void)cardViewControllerDidChangeUserPrivacy:(EXCardViewController *)controller {
    [self.liveService forceInvokeUserCardUpdate];
}

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
    self.meCard = self.liveService.latestMeCard ?: [Card cardWithDictionary:[self meCardParamsToSend]];
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
    NSMutableArray *noresponseIdentity = [[NSMutableArray alloc] init];
    for (EXCircleItemCell *cell in selectedCells) {
        NSArray *cardIdentities = cell.card.identities;
        BOOL gotNoresponseIdentity = NO;
        for (CardIdentitiy *anIdentity in cardIdentities) {
            if (!gotNoresponseIdentity) {
                gotNoresponseIdentity = YES;
                [noresponseIdentity addObject:[NSString stringWithFormat:@"%@%@", anIdentity.provider, anIdentity.externalUsername]];
            }
            [identityParams addObject:[anIdentity dictionaryValue]];
        }
    }
    
//    NSLog(@"\n%@", noresponseIdentity);
    
    [APIExfee getIdentitiesFromIdentityParams:identityParams
                                       succes:^(NSArray *identities){
                                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                                           
                                           RKObjectManager *manager=[RKObjectManager sharedManager] ;
                                           manager.HTTPClient.parameterEncoding=AFJSONParameterEncoding;
                                           
                                           NSMutableArray *invitations = [[NSMutableArray alloc] initWithCapacity:[identities count]];
                                           
                                           for (Identity *identity in identities) {
                                               NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext];
                                               Invitation *invitation=[[[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:manager.managedObjectStore.mainQueueManagedObjectContext] autorelease];
                                               NSString *key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
//                                               NSLog(@"\n key:%@", key);
                                               for (NSString *aKey in noresponseIdentity) {
                                                   if ([key isEqualToString:aKey]) {
//                                                       NSLog(@"NORESPONSE");
                                                       invitation.rsvp_status=@"NORESPONSE";
                                                   } else {
//                                                       NSLog(@"NOTIFICATION");
                                                       invitation.rsvp_status=@"NOTIFICATION";
                                                   }
                                               }
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
    [identityParams release];
    [noresponseIdentity release];
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
    NSMutableArray *identities = [[NSMutableArray alloc] initWithCapacity:[me.identities count]];
    
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
    
    NSDictionary *cardParams = @{@"id" : (self.liveService.cardID && self.liveService.cardID.length) ? self.liveService.cardID : @"" , @"name" : [me.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"avatar" : me.avatar_filename, @"bio" : [me.bio stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"identities" : identities, @"is_me": [NSNumber numberWithBool:YES]};
    [identities release];
    
    return cardParams;
}


@end
