//
//  WidgetExfeeViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "UILabel+EXFE.h"
#import "Invitation+EXFE.h"
#import "Identity+EXFE.h"
#import "Exfee+EXFE.h"
#import "Invitation+EXFE.h"
#import "User+EXFE.h"
#import "WidgetExfeeViewController.h"
#import "CrossGroupViewController.h"
#import "ExfeeCollectionViewCell.h"
#import "ExfeeAddCollectionViewCell.h"
#import "Util.h"
#import "DateTimeUtil.h"
#import "NSString+EXFE.h"
#import "EFContactViewController.h"
#import "EFAPIServer.h"
#import "MBProgressHUD.h"
#import "EXSpinView.h"
#import "Cross.h"
#import "IdentityId+EXFE.h"
#import "EFAPI.h"
#import "EFKit.h"
#import "EFModel.h"
#import "RoughIdentity.h"
#import "EFContactObject.h"


#define kTagViewExfeeRoot         10
#define kTagViewExfeeSelector     20
#define kTagViewExfeeContent      30

#define kTableFloating   222
#define kTableOrigin     223

#define kMenuTagRsvp 8901
#define kMenuTagAction 8902
#define kMenuTagMate 8903

#define kYOffset  0
#define kBottomMargin 2

#define kPopupIdRsvpMenu 1
#define kPopupIdRemoveIdentity 2


typedef enum {
    kTagIdNone = 0,
    kTagIdActionMenu,
    kTagIdBioContent,
    kTagIdBioTitle,
    kTagIdIdentityName,
    kTagIdIdentityWarninng,
    kTagIdIdentityProvider,
    kTagIdRSVPAltLabel,
    kTagIdRSVPLabel,
    kTagIdRSVPImage,
    kTagIdHostFlag,
    kTagIdName,
    kTagIdMax = INT16_MAX,
} _TagID;

@interface WidgetExfeeViewController ()

@end

@implementation WidgetExfeeViewController


- (id)initWithModel:(EXFEModel *)exfeModel
{
    self = [super initWithModel:exfeModel];
    if (self) {
        // Custom initialization
        
        rsvpDict = @{ @"header": NSLocalizedString(@"Set response to:", nil),
                      @"item0": @{ @"main": NSLocalizedString(@"Accepted", nil),
                                   @"style": @"Highlight"
                                   },
                      @"item1": @{ @"main": NSLocalizedString(@"Unavailable", nil),
                                   @"style": @"Normal"
                                   },
                      @"item2": @{ @"main": NSLocalizedString(@"Interested", nil),
                                   @"style": @"Normal"
//                                   },
//                      @"item3": @{ @"main": NSLocalizedString(@"+ mates...", nil),
//                                   @"style": @"Lowlight"
                                   }
                      };
        myRsvpDict = @{ @"header": NSLocalizedString(@"Set response to:", nil),
                        @"item0": @{ @"main": NSLocalizedString(@"I'm in", nil),
                                     @"style": @"Highlight"
                                     },
                        @"item1": @{ @"main": NSLocalizedString(@"Unavailable", nil),
                                     @"style": @"Normal"
                                     },
                        @"item2": @{ @"main": NSLocalizedString(@"Interested", nil),
                                     @"style": @"Normal"
//                                     },
//                        @"item3": @{ @"main": NSLocalizedString(@"+ mates...", nil),
//                                     @"style": @"Lowlight"
                                     }
                        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"WIDGET_EXFEE"];
    // Do any additional setup after loading the view from its nib.
    CGRect a = [UIScreen mainScreen].applicationFrame;
    CGRect b = self.initFrame;
    self.view.tag = kTagViewExfeeRoot;
    
    if (self.exfee) {
        self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
    }
    
    flowLayout = [[PSTCollectionViewFlowLayout alloc] init];
    exfeeContainer = [[PSTCollectionView alloc] initWithFrame:CGRectMake(0, kYOffset, CGRectGetWidth(b), CGRectGetHeight(b) - kYOffset) collectionViewLayout:flowLayout];
    exfeeContainer.delegate = self;
    exfeeContainer.dataSource = self;
    [exfeeContainer registerClass:[ExfeeCollectionViewCell class] forCellWithReuseIdentifier:@"Exfee Cell"];
    [exfeeContainer registerClass:[PSTCollectionViewCell class] forCellWithReuseIdentifier:@"Blank Cell"];
    [exfeeContainer registerClass:[ExfeeAddCollectionViewCell class] forCellWithReuseIdentifier:@"Add Cell"];
    exfeeContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"exfee_bg.png"]];
    exfeeContainer.alwaysBounceVertical = YES;
    exfeeContainer.contentOffset = CGPointMake(0, 0);
//    exfeeContainer.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
    exfeeContainer.tag = kTagViewExfeeSelector;
    [self.view addSubview:exfeeContainer];
    
    CGFloat exfee_content_height = CGRectGetHeight(exfeeContainer.frame) - 94 * (2 + (CGRectGetHeight(a) > 480 ? 1 : 0)) - kBottomMargin;

    invTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 + kYOffset, CGRectGetWidth(b), exfee_content_height )];
    invTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    invTable.backgroundColor = [UIColor COLOR_SNOW];
    invTable.alwaysBounceVertical = YES;
    invTable.delegate = self;
    invTable.dataSource = self;
    invTable.tag = kTableOrigin;
    [self.view addSubview:invTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadCrossSuccess
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
}
- (void)viewDidAppear:(BOOL)animated
{
    [self reloadSelected];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [invName release];
//    [invHostFlag release];
//    [invHostText release];
//    [invRsvpImage release];
//    [invRsvpLabel release];
//    [invRsvpAltLabel release];
//    [bioTitle release];
//    [bioContent release];
//    [invContent release];
    
    
    
    
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        
        [self.onExitBlock invoke];
    }
}
#pragma mark - Notification handler

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    
    if ([name isEqualToString:kEFNotificationNameLoadCrossSuccess]) {
        NSDictionary *userInfo = notification.userInfo;
        
        Meta *meta = (Meta *)[userInfo objectForKey:@"meta"];
        if ([meta.code intValue] == 200) {
            NSArray *viewControllers = [self.tabBarViewController viewControllersForClass:NSClassFromString(@"CrossGroupViewController")];
            NSAssert(viewControllers != nil && viewControllers.count, @"viewController 不应为空");
            
            CrossGroupViewController *crossGroupViewController = viewControllers[0];
            self.exfee = crossGroupViewController.cross.exfee;
            self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
            [exfeeContainer reloadData];
            [self reloadSelected];
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [_selected_invitation setRsvp_status:@"REMOVED"];
        
        Identity *myidentity = [self.exfee getMyInvitation].identity;
        AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.model.apiServer editExfee:self.exfee
                                     byIdentity:myidentity
                                        success:^(Exfee *exfee) {
                                            self.selected_invitation = nil;
                                            self.exfee = exfee;
                                            self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
                                            [exfeeContainer reloadData];
                                            [self reloadSelected];
                                        }
                                        failure:^(NSError *error) {
                                        }];
    }
}

#pragma mark Gesture Handler

#pragma mark Fill content and Layout
- (void)fillInvitationContent:(Invitation*)inv
{
    [invTable reloadData];
}

#pragma mark Actions
- (void)removeInvitation
{
    
    NSString *title = NSLocalizedString(@"People will no longer have access to any information in this ·X·. Please confirm to remove.", nil);
    NSString *destTitle = NSLocalizedString(@"Remove from this ·X·", nil);
    if ([[User getDefaultUser] isMe:_selected_invitation.identity]) {
        title = NSLocalizedString(@"You will no longer have access to any information in this ·X· once left. Please confirm to leave.", nil);
        destTitle = NSLocalizedString(@"Leave from this ·X·", nil);
    }
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:title
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              destructiveButtonTitle:destTitle
                                                   otherButtonTitles:nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    
	[popupQuery showInView:self.view];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return _selected_invitation.notification_identities.count + 1;
        case 3:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:{
            
            return tableHeader;
        }   //break;
        case 1:{
            NSString *reuseIdentifier = @"Invitation_head";
            if (!tableRsvp) {
                tableRsvp = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                tableRsvp.selectionStyle = UITableViewCellSelectionStyleNone;
                
                CALayer * layerLine = [CALayer layer];
                layerLine.frame = CGRectMake(0, 0, 320, 1);
                layerLine.contents = (id)[UIImage imageNamed:@"exfee_line_h1.png"].CGImage;
                [tableRsvp.contentView.layer addSublayer:layerLine];
                
                CAShapeLayer *centerline = [CAShapeLayer layer];
                centerline.backgroundColor = [UIColor COLOR_RGB(0xE6, 0xE6, 0xE6)].CGColor;
                centerline.frame = CGRectMake(65, 0, 1, 62);
                [tableRsvp.contentView.layer addSublayer:centerline];
                
                invRsvpImage = [[UIImageView alloc] initWithFrame:CGRectMake(33, 12, 26, 26)];
                invRsvpImage.tag = kTagIdRSVPImage;
                [tableRsvp.contentView addSubview:invRsvpImage];
                
                invRsvpLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 15, 200, 22)];
                invRsvpLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
                invRsvpLabel.backgroundColor = [UIColor clearColor];
                invRsvpLabel.tag = kTagIdRSVPLabel;
                [tableRsvp.contentView addSubview:invRsvpLabel];
                
                invRsvpAltLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 41, 180, 12)];
                invRsvpAltLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
                invRsvpAltLabel.textColor = [UIColor COLOR_GRAY];
                invRsvpAltLabel.backgroundColor = [UIColor clearColor];
                //        invRsvpAltLabel.numberOfLines = 0;
                invRsvpAltLabel.tag = kTagIdRSVPAltLabel;
                [tableRsvp.contentView addSubview:invRsvpAltLabel];
            }
            
            Invitation *inv = _selected_invitation;
            
            if (inv) {
//                NSUInteger changeFlag = kTagIdNone;
                RsvpCode rsvp = [Invitation getRsvpCode:inv.rsvp_status];
                
                
                switch (rsvp) {
                    case kRsvpAccepted:
                    {
                        invRsvpImage.image = [UIImage imageNamed:@"rsvp_accepted_stroke_26blue"];
                        
                        if ([inv.mates intValue] > 0) {
                            NSString *strWithMates = [NSString stringWithFormat:@"Accepted with %i mates", [inv.mates intValue]];
                            invRsvpLabel.textColor = [UIColor COLOR_BLUE_EXFE];
                            [invRsvpLabel setText:strWithMates afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                                NSRange rang = [strWithMates rangeOfString:@"Accepted"];
                                CTFontRef textfontref2 = CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 18.0, NULL);
                                if (rang.location > 0) {
                                    NSRange pre = NSMakeRange(0, rang.location);
                                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)[UIFont fontWithName:@"HelveticaNeue-Light" size:18] range:pre];
                                }
                                if (rang.location + rang.length < strWithMates.length) {
                                    NSRange sur = NSMakeRange(rang.location + rang.length, strWithMates.length - (rang.location + rang.length));
                                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)[UIFont fontWithName:@"HelveticaNeue-Light" size:18] range:sur];
                                }
                                CFRelease(textfontref2);
                                return mutableAttributedString;
                            }];
                        }else{
                            invRsvpLabel.textColor = [UIColor COLOR_BLUE_EXFE];
                            invRsvpLabel.text = NSLocalizedString(@"Accepted", nil);
                        }
                    }
                        break;
                    case kRsvpDeclined:
                    {
                        invRsvpImage.image = [UIImage imageNamed:@"rsvp_unavailable_stroke_26g5"];
                        invRsvpLabel.textColor = [UIColor COLOR_ALUMINUM];
                        invRsvpLabel.text = NSLocalizedString(@"Unavailable", nil);
                    }
                        break;
                    case kRsvpInterested:
                    {
                        invRsvpImage.image = [UIImage imageNamed:@"rsvp_pending_stroke_26g5"];
                        invRsvpLabel.textColor = [UIColor COLOR_ALUMINUM];
                        invRsvpLabel.text = NSLocalizedString(@"Intersted", nil);
                    }
                        break;
                        // no use
                    case kRsvpRemoved:
                        // should not be used here
                        break;
                        
                        //pending
                    case kRsvpNotification:
                    case kRsvpIgnored:
                    case kRsvpNoResponse:
                    default:{
                        invRsvpImage.image = [UIImage imageNamed:@"rsvp_pending_stroke_26g5"];
                        
                        invRsvpLabel.textColor = [UIColor COLOR_ALUMINUM];
                        invRsvpLabel.text = NSLocalizedString(@"Pending", nil);
                    }
                        break;
                }
                if ([inv.identity.unreachable boolValue]){
                    invRsvpLabel.textColor = [UIColor COLOR_ALUMINUM];
                    invRsvpLabel.text = NSLocalizedString(@"Pending", nil);
                }
                
                NSString *altString = @"";
                if (inv.updated_at != nil) {
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:inv.updated_at];
                    altString = [DateTimeUtil GetRelativeTime:comps format:0];
                }
                if ([inv.updated_by.connected_user_id intValue]!= [inv.identity.connected_user_id intValue]){
                    if (altString && altString.length > 0) {
                        altString = [NSString stringWithFormat:NSLocalizedString(@"Set by %@ %@", nil), [inv.updated_by getDisplayName], altString];
                    }else{
                        altString = [NSString stringWithFormat:NSLocalizedString(@"Set by %@", nil), [inv.updated_by getDisplayName]];
                    }
                }
                invRsvpAltLabel.text = [altString sentenceCapitalizedString];
                [invRsvpAltLabel wrapContent];
//                [self setNeedLayout:changeFlag];
                
                
                //            [CATransaction begin];
                //            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
                //            CGRect frame = layer1.frame;
                //            frame.origin.y = start.y + 4;
                //            layer1.frame = frame;
                //
                //            frame = layer4.frame;
                //            frame.origin.y = start.y + 4;
                //            layer4.frame = frame;
                //            [CATransaction commit];
                //
                //            frame = invRsvpImage.frame;
                //            frame.origin.y = CGRectGetMaxY(layer1.frame) + 12;
                //            invRsvpImage.frame = frame;
                //
                //            frame = invRsvpLabel.frame;
                //            frame.origin.y = CGRectGetMaxY(layer1.frame) + 14;
                //            invRsvpLabel.frame = frame;
                //            
                //            frame = invRsvpAltLabel.frame;
                //            frame.origin.y = CGRectGetMaxY(invRsvpLabel.frame) + 1;
                //            invRsvpAltLabel.frame = frame;
            }
            return tableRsvp;
        }   //break;
        case 2:{
            NSString *reuseIdentifier = @"Invitation_cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            UIImageView *identityProvider = nil;
            UIImageView *identityWaring = nil;
            UIBorderLabel *identityName = nil;
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                CALayer * layerLine = [CALayer layer];
                layerLine.frame = CGRectMake(0, 0, 320, 1);
                layerLine.contents = (id)[UIImage imageNamed:@"exfee_line_h2.png"].CGImage;
                [cell.contentView.layer addSublayer:layerLine];
                
                CAShapeLayer *centerline = [CAShapeLayer layer];
                centerline.backgroundColor = [UIColor COLOR_RGB(0xE6, 0xE6, 0xE6)].CGColor;
                centerline.frame = CGRectMake(65, 0, 1, 32);
                [cell.contentView.layer addSublayer:centerline];
                
                identityProvider = [[UIImageView alloc] initWithFrame:CGRectMake(37, 6, 18, 18)];
                identityProvider.tag = kTagIdIdentityProvider;
                [cell.contentView addSubview:identityProvider];
                
                identityWaring = [[UIImageView alloc] initWithFrame:CGRectMake(75, 6, 18, 18)];
                identityWaring.tag = kTagIdIdentityWarninng;
                [cell.contentView addSubview:identityWaring];
                
                identityName = [[UIBorderLabel alloc] initWithFrame:CGRectMake(70, 0, 225, 32)];
                identityName.leftInset = 5;
                identityName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
                identityName.textColor = [UIColor COLOR_BLACK];
                identityName.backgroundColor = [UIColor clearColor];
                identityName.tag = kTagIdIdentityName;
                [cell.contentView addSubview:identityName];
                
            } else {
                identityProvider = (UIImageView *)[cell.contentView viewWithTag:kTagIdIdentityProvider];
                identityWaring = (UIImageView *)[cell.contentView viewWithTag:kTagIdIdentityWarninng];
                identityName = (UIBorderLabel *)[cell.contentView viewWithTag:kTagIdIdentityName];
            }
            
            Invitation *inv = _selected_invitation;
            
            NSString * diplayIdentity = @"";
            Provider p = kProviderUnknown;
            
            if (row == 0){
                Identity *ident = inv.identity;
                if (ident) {
                    NSString* at_id = [ident getDisplayIdentity];
                    diplayIdentity = at_id;
                    
                    p = [Identity getProviderCode:ident.provider];
                }
            } else {
                IdentityId * identId = [inv.notification_identities objectAtIndex:row - 1];
                diplayIdentity = [identId displayIdentity];
                p = [Identity getProviderCode:[identId provider]];
            }
            
            identityName.text = diplayIdentity;
            switch(p){
                case kProviderEmail:
                    identityProvider.image = [UIImage imageNamed:@"identity_email_18_grey.png"];
                    break;
                case kProviderPhone:
                    identityProvider.image = [UIImage imageNamed:@"identity_phone_18_grey.png"];
                    break;
                case kProviderTwitter:
                    identityProvider.image = [UIImage imageNamed:@"identity_twitter_18_grey.png"];
                    break;
                case kProviderFacebook:
                    identityProvider.image = [UIImage imageNamed:@"identity_facebook_18_grey.png"];
                    break;
                default:
                    identityProvider.image = nil;
                    break;
            }
            
                //            [CATransaction begin];
                //            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
                //            CGRect frame = layer2.frame;
                //            frame.origin.y = start.y + 9;
                //            layer2.frame = frame;
                //            [CATransaction commit];
                
                //            frame = identityProvider.frame;
                //            frame.origin.y = CGRectGetMaxY(layer2.frame) + 6;
                //            identityProvider.frame = frame;
                //
                //            frame = identityWaring.frame;
                //            frame.origin.y = CGRectGetMaxY(layer2.frame) + 6;
                //            identityWaring.frame = frame;
                //            
                //            frame = identityName.frame;
                //            frame.origin.y = CGRectGetMaxY(layer2.frame) + 0;
                //            identityName.frame = frame;
            
            return cell;
        }   //break;
        case 3:{
            return tableFooter;
        }   //break;
        default:
            break;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: temp walkaround The only host cannot be removed
    if (_selected_invitation) {
        if ([_selected_invitation.host boolValue] == YES) {
            NSInteger count = 0;
            for (Invitation *inv in self.sortedInvitations) {
                if ([inv.host boolValue] == YES) {
                    count ++;
                }
            }
            if (count == 1) {
                return NO;
            }
        }
    }
    
    NSInteger section = indexPath.section;
    switch (section) {
        case 1:
            return YES;
        //  break;
        case 2:
            return indexPath.row == 0;
        //  break;
        default:
            return NO;
        //  break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: temp walkaround The only host cannot be removed
    if (_selected_invitation) {
        if ([_selected_invitation.host boolValue] == YES) {
            NSInteger count = 0;
            for (Invitation *inv in self.sortedInvitations) {
                if ([inv.host boolValue] == YES) {
                    count ++;
                }
            }
            if (count == 1) {
                return;
            }
        }
    }
    
    [self removeInvitation];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:{
            NSString *reuseIdentifier = @"Invitation_head";
            if (!tableHeader) {
                tableHeader = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                tableHeader.selectionStyle = UITableViewCellSelectionStyleNone;
                
                invName = [[UILabel alloc] initWithFrame:CGRectMake(25, 16 , 230, 25)];
                invName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
                invName.textColor = [UIColor COLOR_CARBON];
                invName.backgroundColor = [UIColor clearColor];
                invName.numberOfLines = 3;
                invName.tag = kTagIdName;
                [tableHeader.contentView addSubview:invName];
                
                invHostFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exfee_host_blue.png"]];
                invHostFlag.frame = CGRectMake(162, 21, CGRectGetWidth(invHostFlag.frame), CGRectGetHeight(invHostFlag.frame));
                invHostFlag.tag = kTagIdHostFlag;
                [tableHeader.contentView addSubview:invHostFlag];
                
                invHostText = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 57, 12)];
                invHostText.text = NSLocalizedString(@"HOST", nil);
                invHostText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
                invHostText.textColor = [UIColor COLOR_BLUE_EXFE];
                [invHostText sizeToFit];
                [tableHeader.contentView addSubview:invHostText];
            }
            
            Invitation *inv = _selected_invitation;
            Identity *identity = inv.identity;
            
            if (inv) {
                NSString* name = [identity getDisplayName];
                if (![invName.text isEqualToString:name]) {
                    invName.text = name;
                    [invName wrapContent];
                }
                
                BOOL shouldHidden = ![inv.host boolValue];
                if (invHostText.hidden != shouldHidden) {
                    invHostText.hidden = shouldHidden;
                }
                
                if (invHostFlag.hidden != shouldHidden) {
                    invHostFlag.hidden = shouldHidden;
                }
                
                if (!shouldHidden) {
                    CGSize size = [invName sizeWrapContent:CGSizeMake(CGRectGetWidth(invName.bounds), MAXFLOAT)];
                    CGFloat w = size.width;
                    if (w > CGRectGetWidth(invName.bounds)) {
                        w = CGRectGetWidth(invName.bounds);
                    }
                    CGFloat x = w + CGRectGetMinX(invName.frame);
                    CGRect f1 = invHostFlag.frame;
                    f1.origin.x = x + 12;
                    invHostFlag.frame = f1;
                    
                    CGRect f2 = invHostText.frame;
                    f2.origin.x = CGRectGetMaxX(f1);
                    invHostText.frame = f2;
                }
            }
            return CGRectGetMaxY(invName.frame) + 4;
        }
             break;
        case 1:
            return 62.f;
        // break;
        case 2:
            return 32.f;
        // break;
        case 3:{
            NSString *reuseIdentifier = @"Invitation_foot";
            UILabel *bioTitle = nil;
            UILabel *bioContent = nil;
            UIButton *ActionMenu = nil;
            if (!tableFooter) {
                tableFooter = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                tableFooter.selectionStyle = UITableViewCellSelectionStyleNone;
                
                CALayer * layerLine = [CALayer layer];
                layerLine.frame = CGRectMake(0, 0, 320, 1);
                layerLine.contents = (id)[UIImage imageNamed:@"exfee_line_h2.png"].CGImage;
                [tableFooter.contentView.layer addSublayer:layerLine];

                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = CGRectMake(65, 0, 1, 50);
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor COLOR_WA(0xE6, 0xFF)] CGColor], (id)[[UIColor COLOR_WA(0xE6, 0x00)] CGColor], nil];
                [tableFooter.contentView.layer addSublayer:gradient];
                
                bioTitle = [[UILabel alloc] initWithFrame:CGRectMake(36, 16, 40, 33)];
                bioTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
                bioTitle.text = NSLocalizedString(@"Bio", nil);
                [bioTitle sizeToFit];
                bioTitle.textColor = [UIColor COLOR_BLACK];
                bioTitle.backgroundColor = [UIColor clearColor];
                bioTitle.tag = kTagIdBioTitle;
                [tableFooter.contentView addSubview:bioTitle];
                
                bioContent = [[UILabel alloc] initWithFrame:CGRectMake(75, 16, 220, 80)];
                bioContent.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
                bioContent.textColor = [UIColor COLOR_BLACK];
                bioContent.backgroundColor = [UIColor clearColor];
                bioContent.numberOfLines = 0;
                bioContent.tag = kTagIdBioContent;
                [tableFooter.contentView addSubview:bioContent];
                
                ActionMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                ActionMenu.frame = CGRectMake(270, 17, 50, 50);
                ActionMenu.tag = kTagIdActionMenu;
                ActionMenu.hidden = YES;
//                [ActionMenu addTarget:self action:@selector(actionPress:) forControlEvents:UIControlEventTouchUpInside];
                
                [tableFooter.contentView addSubview:ActionMenu];
            } else {
                bioTitle = (UILabel *)[tableFooter.contentView viewWithTag:kTagIdBioTitle];
                bioContent = (UILabel *)[tableFooter.contentView viewWithTag:kTagIdBioContent];
                ActionMenu = (UIButton *)[tableFooter.contentView viewWithTag:kTagIdActionMenu];
            }
            
            Invitation *inv = _selected_invitation;
            Identity *identity = inv.identity;
            bioTitle.hidden = !(identity && identity.bio.length > 0);
            bioContent.text = identity.bio;
            [bioContent wrapContent];
            
            return MAX(CGRectGetMaxY(bioContent.frame), CGRectGetMaxY(ActionMenu.frame)) + 3;
        }   //break;
        default:
            return 0;
        //  break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
            break;
        case 1:{
            [self hidePopupIfShown:kPopupIdRsvpMenu];
            
            NSDictionary *data = rsvpDict;
            
            if ([[User getDefaultUser] isMe:[_selected_invitation identity]]) {
                data = myRsvpDict;
            }
            
            if (rsvpMenu == nil) {
                rsvpMenu = [[EXBasicMenu alloc] initWithFrame:CGRectMake(0, 0, 125, 20 + 44 * 3) andContent:
                            data];
                rsvpMenu.delegate = self;
                rsvpMenu.tag = kMenuTagRsvp;
                [self.view addSubview:rsvpMenu];
            }else{
                [rsvpMenu setContent:data];
            }
            
            
            ;
            [self show:rsvpMenu at:[tableView convertPoint:[tableView cellForRowAtIndexPath:indexPath].frame.origin toView:self.view] withAnimation:YES];
        }    break;
        case 2:
            break;
        case 3:
            break;
        default:
            break;
    }
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(PSTCollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.sortedInvitations.count + 1;
        default:
            return 0;
    }
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
        {
            PSTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Blank Cell" forIndexPath:indexPath];
            return cell;
        }
        case 1:
        {
            if (row == self.sortedInvitations.count) {
                ExfeeAddCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Add Cell" forIndexPath:indexPath];
                cell.description.text = [NSString stringWithFormat:NSLocalizedString(@"%u / %u", nil), [self.exfee.accepted integerValue], self.sortedInvitations.count];
                return cell;
            } else {
                ExfeeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Exfee Cell" forIndexPath:indexPath];
                
                Invitation* inv = [self.sortedInvitations objectAtIndex:row];
                cell.name.text = inv.identity.name;
                [cell setRsvp:[Invitation getRsvpCode:inv.rsvp_status] andUnreachable:[inv.identity.unreachable boolValue] withHost:[inv.host boolValue]];
                NSInteger seq = row % 4;
                switch (seq) {
                    case 0:
                        cell.sequence = kPosFirst;
                        break;
                    case 3:
                        cell.sequence = kPosLast;
                        break;
                    default:
                        cell.sequence = kPosMiddle;
                        break;
                }
                
                NSString *imageKey = inv.identity.avatar_filename;
                UIImage *defaultImage = [UIImage imageNamed:@"portrait_default.png"];
                
                if (!imageKey) {
                    cell.avatar.image = defaultImage;
                } else {
                    [[EFDataManager imageManager] loadImageForView:cell.avatar
                                                  setImageSelector:@selector(setImage:)
                                                       placeHolder:defaultImage
                                                               key:imageKey
                                                   completeHandler:nil];
                }
                
                cell.invitation_id = inv.invitation_id;
//                cell.mates = 10;
                cell.mates = [inv.mates integerValue];
                
                return cell;
            }
        }
        default:
            return nil;
    }
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger seq = row % 4;
    switch (section) {
        case 0:
//            return CGSizeMake(300, CGRectGetHeight(invContent.frame) + kBottomMargin);
            return CGSizeMake(300, CGRectGetHeight(invTable.frame) + kBottomMargin);
        case 1:
            switch (seq) {
                case 0:
                case 3:
                    return CGSizeMake(82, 94);
                    //break;
                default:
                    return CGSizeMake(78, 94);
                    //break;
            }
        default:
            return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
            return UIEdgeInsetsMake(0, 0, 0, 0);
        case 1:
            return UIEdgeInsetsMake(0, 0, 0, 0);
        default:
            return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
}

- (CGFloat)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
        case 1:
            return 0;
        default:
            return 0;
    }
}
- (CGFloat)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
        case 1:
            return 0;
        default:
            return 0;
    }
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self hidePopupIfShown];
    NSInteger section = indexPath.section;
    if (section == 1) {
        if (indexPath.row == self.sortedInvitations.count){
            void (^addActionHandler)(NSArray *contactObjects) = ^(NSArray *contactObjects){
                NSAssert(dispatch_get_main_queue() == dispatch_get_current_queue(), @"WTF! MUST on main queue! boy!");
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Adding...";
                hud.mode = MBProgressHUDModeCustomView;
                EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
                [bigspin startAnimating];
                hud.customView = bigspin;
                
                
                Exfee *exfee = [Exfee disconnectedEntity];
                [exfee addToContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
                exfee.exfee_id = [self.exfee.exfee_id copy];
                
                NSMutableSet *invitations = [[NSMutableSet alloc] init];
                RKObjectManager *objectManager = [RKObjectManager sharedManager];
                NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
                
                for (EFContactObject *object in contactObjects) {
                    RoughIdentity *roughIdentity = object.roughIdentities[0];
                    Identity *identity = roughIdentity.identity;
                    identity.name = object.name;
                    
                    NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:context];
                    Invitation *invitation = [[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:context];
                    invitation.rsvp_status = @"NORESPONSE";
                    invitation.identity = identity;
                    
                    Invitation *myinvitation = [self.exfee getMyInvitation];
                    if (myinvitation != nil) {
                        invitation.updated_by = myinvitation.identity;
                    } else {
                        invitation.updated_by = [[[User getDefaultUser].identities allObjects] objectAtIndex:0];
                    }
                    
                    for (int i = 1; i < object.roughIdentities.count; i++) {
                        IdentityId *identityId = [object.roughIdentities[i] identityIdValue];
                        [invitation addNotification_identitiesObject:identityId];
                    }
                    
                    [invitations addObject:invitation];
                }
                
                [exfee addInvitations:invitations];
                
                Identity *myidentity = [self.exfee getMyInvitation].identity;
                
                AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app.model.apiServer editExfee:exfee
                                             byIdentity:myidentity
                                                success:^(Exfee *editedExfee){
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    
                                                    self.exfee = editedExfee;
                                                    self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
                                                    [exfeeContainer reloadData];
                                                    
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                }
                                                failure:^(NSError *error){
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                }];
            };
            
            EFContactViewController *viewController = [[EFContactViewController alloc] initWithNibName:@"EFContactViewController" bundle:nil];
            viewController.addActionHandler = addActionHandler;
            [self presentViewController:viewController
                               animated:YES
                             completion:nil];
        } else {
            [self hidePopupIfShown];
            PSTCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            [self clickCell:cell];
            self.selected_invitation = [self.sortedInvitations objectAtIndex:indexPath.row];
            [self fillInvitationContent:_selected_invitation];
        }
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastContentOffset = CGPointMake(-1, -1);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == kTagViewExfeeSelector) {
        [self hidePopupIfShown];
        CGPoint offset = scrollView.contentOffset;
        ScrollDirection direction = ScrollDirectionNone;
        
        if (_lastContentOffset.x >= 0) {
            if (offset.y > _lastContentOffset.y) {
                direction = ScrollDirectionUp;
            } else {
                direction = ScrollDirectionDown;
            }
        }
        _lastContentOffset = offset;
        
        if (invContent.tag == kTableOrigin) {
            CGRect rect = invContent.frame;
            rect.origin.y = CGRectGetMinY(scrollView.frame) - scrollView.contentOffset.y + _floatingOffset.height;
            if (CGRectGetMinY(rect) > CGRectGetMinY(scrollView.frame)) {
                _floatingOffset = CGSizeMake(0, scrollView.contentOffset.y);
                rect.origin.y = CGRectGetMinY(scrollView.frame) - scrollView.contentOffset.y + _floatingOffset.height;
                invContent.frame = rect;
            } else if (CGRectGetMaxY(rect) < CGRectGetMinY(scrollView.frame)){
                _floatingOffset = CGSizeMake(0, 0);
                rect.origin.y = CGRectGetMinY(scrollView.frame) - scrollView.contentOffset.y + _floatingOffset.height;
                invContent.frame = rect;
            } else {
                if (direction == ScrollDirectionUp && scrollView.contentOffset.y <= 0) {
                    _floatingOffset = CGSizeMake(0, scrollView.contentOffset.y);
                    rect.origin.y = CGRectGetMinY(scrollView.frame) - scrollView.contentOffset.y + _floatingOffset.height;
                    invContent.frame = rect;
                } else {
                    invContent.frame = rect;
                }
            }
        }
    }else if (scrollView.tag == kTableOrigin || scrollView.tag == kTableFloating) {
        [self hidePopupIfShown];
    }
}

- (void)clickCell:(id)sender{
    UIView* btn = sender;
    CGPoint offset = exfeeContainer.contentOffset;
    BOOL flag = NO;
    CGPoint exfeeOffset;
    CGPoint invOffset;
    if (CGRectGetMinY(btn.frame) - offset.y < CGRectGetHeight(invContent.frame)) {
        // click target is upper than the normal area
        exfeeOffset = CGPointMake(offset.x, MAX(CGRectGetMinY(btn.frame) - CGRectGetHeight(invContent.frame) - kBottomMargin, 0));
        invOffset = CGPointMake(0, CGRectGetMinY(exfeeContainer.frame));
        flag = YES;
    } else if(CGRectGetMaxY(btn.frame) - offset.y > CGRectGetHeight(exfeeContainer.bounds)){
        // click target is lower than the normal area
        exfeeOffset = CGPointMake(offset.x, MAX(CGRectGetMaxY(btn.frame) - CGRectGetHeight(exfeeContainer.bounds), 0));
        invOffset = CGPointMake(0, CGRectGetMinY(exfeeContainer.frame));
        flag = YES;
        
    } else {
        exfeeOffset = offset;
        invOffset = CGPointMake(0, CGRectGetMinY(exfeeContainer.frame));
    }
    
    invContent.tag = kTableFloating;
    [UIView animateWithDuration:0.4
                     animations:^{
                         if (flag) {
                             exfeeContainer.contentOffset = exfeeOffset;
                             //exfeeContainer.bounds.y += offset.y - exfeeContainer.contentOffset.y; // for animation
                         }
                         CGRect frame = invContent.frame;
                         frame.origin = invOffset;
                         invContent.frame = frame;
                     } completion:^(BOOL finished) {
                         _floatingOffset = CGSizeMake(0, exfeeContainer.contentOffset.y);
                         invContent.tag = kTableOrigin;
                     }];
}

- (void)show:(EXBasicMenu*)menu at:(CGPoint)location withAnimation:(BOOL)animated
{
    CGRect f = menu.frame;
    f.origin.x = CGRectGetWidth(self.view.bounds);
    f.origin.y = location.y - 28;
    menu.frame = f;
    f.origin.x = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(f);
    menu.hidden = NO;
    [UIView animateWithDuration:0.4
                     animations:^(void){
                         menu.frame = f;
                     }];
}

- (void)hide:(EXBasicMenu*)menu withAnmiation:(BOOL)animated
{
    if (animated) {
        CGRect f = menu.frame;
        f.origin.x = CGRectGetWidth(menu.superview.bounds);
        [UIView animateWithDuration:0.3
                         animations:^{
                             menu.frame = f;
                         }
                         completion:^(BOOL finished){
                             menu.hidden = YES;
                         }];
    }else{
        menu.hidden = YES;
    }
    
}

#pragma mark EXBasicMenuDelegate
- (void)basicMenu:(EXBasicMenu*)menu didSelectRowAtIndexPath:(NSNumber *)index{
    switch (menu.tag) {
        case kMenuTagRsvp:
        {
            [self hidePopupIfShown];
            NSInteger abc = [index integerValue];
            Invitation * inv = _selected_invitation;
            switch (abc) {
                case 0:
                    if (inv && [Invitation getRsvpCode:inv.rsvp_status] != kRsvpAccepted) {
                        [self sendrsvp:@"ACCEPTED" invitation:inv];
                    }
                    break;
                case 1:
                    [self sendrsvp:@"DECLINED" invitation:inv];
                    break;
                case 2:
                    [self sendrsvp:@"INTERESTED" invitation:inv];
                    break;
                case 3:
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark API request for modification.
- (void)sendrsvp:(NSString*)status invitation:(Invitation*)_invitation {
    
    Identity *myidentity = [self.exfee getMyInvitation].identity;
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer submitRsvp:status
                                          on:_invitation
                                  myIdentity:[myidentity.identity_id intValue]
                                     onExfee:[self.exfee.exfee_id intValue]
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         if ([operation.response statusCode] == 200){
                                             if([responseObject isKindOfClass:[NSDictionary class]])
                                             {
                                                 NSDictionary* meta=(NSDictionary*)[responseObject objectForKey:@"meta"];
                                                 if([[meta objectForKey:@"code"] intValue]==403){
                                                     //                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                     //                                 alert.tag=403;
                                                     //                                 [alert show];
                                                     //                                 [alert release];
                                                 } else if ([[meta objectForKey:@"code"] intValue] == 200) {
                                                     NSArray *viewControllers = [self.tabBarViewController viewControllersForClass:NSClassFromString(@"CrossGroupViewController")];
                                                     NSAssert(viewControllers != nil && viewControllers.count, @"viewController 不应为空");
                                                     
                                                     CrossGroupViewController *crossGroupViewController = viewControllers[0];
                                                     AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                     
                                                     [app.model loadCrossWithCrossId:[crossGroupViewController.cross.cross_id intValue] updatedTime:nil];
                                                     
                                                     self.exfee = crossGroupViewController.cross.exfee;
                                                     [exfeeContainer reloadData];
                                                 }
                                                 
                                             }
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [Util showConnectError:error delegate:self];
                                     }];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // nothing yet
}


- (void)hidePopupIfShown{
    [self hidePopupIfShown:0];
}

- (void)hidePopupIfShown:(NSInteger)skipId{
    
    if (kPopupIdRsvpMenu != skipId){
        [self hide:rsvpMenu withAnmiation:YES];
    }
    
    if (kPopupIdRemoveIdentity != skipId) {
        RemoveButton.hidden = YES;
    }
    
//    NSInteger ctrlid = skipId & MASK_LOW_BITS;
    
//    if (ctrlid != (kPopupTypeEditStatus & MASK_LOW_BITS)) {
//        [self hideMenuWithAnimation:YES];
//    }
//    if (ctrlid != (kPopupTypeVewStatus & MASK_LOW_BITS)) {
//        [self hideStatusView];
//    }
//    if (ctrlid != (kPopupTypeEditTitle & MASK_LOW_BITS)) {
//        [self hideTitleAndDescEditMenuWithAnimation:YES];
//    }
//    if (ctrlid != (kPopupTypeEditDescription & MASK_LOW_BITS)) {
//        [self hideTitleAndDescEditMenuWithAnimation:YES];
//    }
//    if (ctrlid != (kPopupTypeEditTime & MASK_LOW_BITS)) {
//        [self hideTimeEditMenuWithAnimation:YES];
//    }
//    if (ctrlid != (kPopupTypeEditPlace & MASK_LOW_BITS)) {
//        [self hidePlaceEditMenuWithAnimation:YES];
//    }
    
//    popupCtrolId = skipId;
    
}

- (void)reloadSelected
{
    BOOL flag = NO;
    NSNumber *inv_id = _selected_invitation.invitation_id;
    for (NSUInteger i = 0; i < self.sortedInvitations.count; i++) {
        Invitation* inv = [self.sortedInvitations objectAtIndex:i];
        if ([inv.invitation_id integerValue] == [inv_id integerValue]) {
            flag = YES;
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:1];
            PSTCollectionViewCell* cell = [exfeeContainer cellForItemAtIndexPath:indexPath];
            if (cell != nil) {
                [exfeeContainer selectItemAtIndexPath:indexPath animated:NO scrollPosition:PSTCollectionViewScrollPositionNone];
                [self fillInvitationContent:_selected_invitation];
                [self clickCell:cell];
            } else {
                [exfeeContainer selectItemAtIndexPath:indexPath animated:NO scrollPosition:PSTCollectionViewScrollPositionBottom];
                [self fillInvitationContent:_selected_invitation];
                
                double delayInSeconds = 0.01;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    PSTCollectionViewCell*  cell = [exfeeContainer cellForItemAtIndexPath:indexPath];
                    [self clickCell:cell];
                });
                
            }
            break;
        }
    }
    if (flag == NO) {
        self.selected_invitation = nil;
    }
    if (self.selected_invitation == nil) {
        self.selected_invitation = [self.sortedInvitations objectAtIndex:0];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [exfeeContainer selectItemAtIndexPath:indexPath animated:NO scrollPosition:PSTCollectionViewScrollPositionNone];
        [self fillInvitationContent:_selected_invitation];
    }
}
@end
