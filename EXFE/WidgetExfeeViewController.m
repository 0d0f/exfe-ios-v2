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
#import "ExfeeInputViewController.h"
#import "CrossGroupViewController.h"
#import "ExfeeCollectionViewCell.h"
#import "ExfeeAddCollectionViewCell.h"
#import "Util.h"
#import "ImgCache.h"
#import "DateTimeUtil.h"
#import "APICrosses.h"
#import "APIExfee.h"
#import "NSString+EXFE.h"

#import "HereViewController.h"


#define kTagViewExfeeRoot         10
#define kTagViewExfeeSelector     20
#define kTagViewExfeeContent      30

#define kTableFloating   222
#define kTableOrigin     223

#define kMenuTagRsvp 8901
#define kMenuTagAction 8902
#define kMenuTagMate 8903

#define kYOffset  50
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        rsvpDict = @{ @"header": @"Set response to:",
                      @"item0": @{ @"main": @"Accepted",
                                   @"style": @"Highlight"
                                   },
                      @"item1": @{ @"main": @"Unavailable",
                                   @"style": @"Normal"
                                   },
                      @"item2": @{ @"main": @"Interested",
                                   @"style": @"Normal"
//                                   },
//                      @"item3": @{ @"main": @"+ mates...",
//                                   @"style": @"Lowlight"
                                   }
                      };
        [rsvpDict retain];
        myRsvpDict = @{ @"header": @"Set response to:",
                        @"item0": @{ @"main": @"I'm in",
                                     @"style": @"Highlight"
                                     },
                        @"item1": @{ @"main": @"Unavailable",
                                     @"style": @"Normal"
                                     },
                        @"item2": @{ @"main": @"Interested",
                                     @"style": @"Normal"
//                                     },
//                        @"item3": @{ @"main": @"+ mates...",
//                                     @"style": @"Lowlight"
                                     }
                        };
        [myRsvpDict retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"WIDGET_EXFEE"];
    // Do any additional setup after loading the view from its nib.
    CGRect a = [UIScreen mainScreen].applicationFrame;
    CGRect b = self.view.bounds;
    self.view.tag = kTagViewExfeeRoot;
    
    if (self.exfee) {
        self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
    }
    
    flowLayout = [[PSTCollectionViewFlowLayout alloc] init];
    exfeeContainer = [[PSTCollectionView alloc] initWithFrame:CGRectMake(0, kYOffset, CGRectGetWidth(b), CGRectGetHeight(a) - kYOffset) collectionViewLayout:flowLayout];
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
    invContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0 + kYOffset, CGRectGetWidth(b), exfee_content_height )];
    invContent.backgroundColor = [UIColor COLOR_SNOW];
    invContent.alwaysBounceVertical = YES;
    invContent.delegate = self;
    invContent.tag = kTableOrigin;
    {
        layer1 = [CALayer layer];
        layer1.frame = CGRectMake(0, 45, 320, 1);
        layer1.contents = (id)[UIImage imageNamed:@"exfee_line_h1.png"].CGImage;
        layer2 = [CALayer layer];
        layer2.frame = CGRectMake(0, 105, 320, 1);
        layer2.contents = (id)[UIImage imageNamed:@"exfee_line_h2.png"].CGImage;
        layer3 = [CALayer layer];
        layer3.frame = CGRectMake(0, 137, 320, 1);
        layer3.contents = (id)[UIImage imageNamed:@"exfee_line_h2.png"].CGImage;
        layer4 = [CALayer layer];
        layer4.frame = CGRectMake(65, 45, 1, 180);
        layer4.contents = (id)[UIImage imageNamed:@"exfee_line_v.png"].CGImage;
        [invContent.layer addSublayer:layer1];
        [invContent.layer addSublayer:layer2];
        [invContent.layer addSublayer:layer3];
        [invContent.layer addSublayer:layer4];
        
        
        invName = [[UILabel alloc] initWithFrame:CGRectMake(25, 16 , 230, 25)];
        invName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
        invName.textColor = [UIColor COLOR_TUNGSTEN];
        invName.backgroundColor = [UIColor clearColor];
        invName.numberOfLines = 3;
        invName.tag = kTagIdName;
        [invContent addSubview:invName];
        
        invHostFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exfee_host_blue.png"]];
        invHostFlag.frame = CGRectMake(162, 21, CGRectGetWidth(invHostFlag.frame), CGRectGetHeight(invHostFlag.frame));
        invHostFlag.tag = kTagIdHostFlag;
        [invContent addSubview:invHostFlag];
        
        invHostText = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 57, 12)];
        invHostText.text = @"HOST";
        invHostText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        invHostText.textColor = [UIColor COLOR_BLUE_EXFE];
        [invHostText sizeToFit];
        [invContent addSubview:invHostText];
        
        invRsvpImage = [[UIImageView alloc] initWithFrame:CGRectMake(33, 57, 26, 26)];
        invRsvpImage.tag = kTagIdRSVPImage;
        [invContent addSubview:invRsvpImage];
        
        invRsvpLabel = [[EXAttributedLabel alloc] initWithFrame:CGRectMake(75, 60, 200, 22)];
        invRsvpLabel.tag = kTagIdRSVPLabel;
        [invContent addSubview:invRsvpLabel];
        
        invRsvpAltLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 86, 180, 12)];
        invRsvpAltLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        invRsvpAltLabel.textColor = [UIColor COLOR_GRAY];
        invRsvpAltLabel.backgroundColor = [UIColor clearColor];
//        invRsvpAltLabel.numberOfLines = 0;
        invRsvpAltLabel.tag = kTagIdRSVPAltLabel;
        [invContent addSubview:invRsvpAltLabel];
        
        identityProvider = [[UIImageView alloc] initWithFrame:CGRectMake(37, 112, 18, 18)];
        identityProvider.tag = kTagIdIdentityProvider;
        [invContent addSubview:identityProvider];
        
        identityWaring = [[UIImageView alloc] initWithFrame:CGRectMake(75, 112, 18, 18)];
        identityWaring.tag = kTagIdIdentityWarninng;
        [invContent addSubview:identityWaring];
        
        identityName = [[UIBorderLabel alloc] initWithFrame:CGRectMake(70, 106, 225, 32)];
        identityName.leftInset = 5;
        identityName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
        identityName.textColor = [UIColor COLOR_BLACK];
        identityName.backgroundColor = [UIColor clearColor];
        identityName.tag = kTagIdIdentityName;
        [invContent addSubview:identityName];
        
        bioTitle = [[UILabel alloc] initWithFrame:CGRectMake(36, 115 + 32, 40, 33)];
        bioTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        bioTitle.text = @"Bio";
        [bioTitle sizeToFit];
        bioTitle.textColor = [UIColor COLOR_BLACK];
        bioTitle.backgroundColor = [UIColor clearColor];
        bioTitle.tag = kTagIdBioTitle;
        [invContent addSubview:bioTitle];
        
        bioContent = [[UILabel alloc] initWithFrame:CGRectMake(75, 115 + 32, 220, 80)];
        bioContent.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        bioContent.textColor = [UIColor COLOR_BLACK];
        bioContent.backgroundColor = [UIColor clearColor];
        bioContent.numberOfLines = 0;
        bioContent.tag = kTagIdBioContent;
        [invContent addSubview:bioContent];
        
        ActionMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        ActionMenu.frame = CGRectMake(255, 146, 40, 31);
        ActionMenu.hidden = YES;
        ActionMenu.tag = kTagIdActionMenu;
        [invContent addSubview:ActionMenu];
        
        
        RemoveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* img = [[UIImage imageNamed:@"btn_red_30inset.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f];
        [RemoveButton setBackgroundImage:img forState:UIControlStateNormal];
        [RemoveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        RemoveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        RemoveButton.titleLabel.shadowColor = [UIColor lightGrayColor];
        RemoveButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [RemoveButton setTitle:@"Delete" forState:UIControlStateNormal];
        RemoveButton.frame = CGRectMake(0, 0, 70, 30);
        RemoveButton.hidden = YES;
        [RemoveButton addTarget:self action:@selector(removeInvitation:) forControlEvents:UIControlEventTouchUpInside];
        [invContent addSubview:RemoveButton];
    }
    [self.view addSubview:invContent];
    _floatingOffset = CGSizeMake(0, 0);
    
#warning test only
    //_________________test begin___________
    UIButton *hereButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hereButton setFrame:CGRectMake(220, 180, 80, 32)];
    [hereButton setTitle:@"Live" forState:UIControlStateNormal];
    [hereButton.titleLabel setShadowColor:[UIColor blackColor]];
    [hereButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    hereButton.layer.cornerRadius = 2;
    [hereButton addTarget:self action:@selector(hereButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [hereButton setBackgroundImage:[[UIImage imageNamed:@"btn_glass_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0,5)] forState:UIControlStateNormal];
    [invContent addSubview:hereButton];
    //_________________test end___________
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContent:)];
    [invContent addGestureRecognizer:tap];
    [tap release];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swypeDelete:)];
    [invContent addGestureRecognizer:swipe];
    [swipe release];
    
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

- (void)dealloc
{
    [invName release];
    [invHostFlag release];
    [invHostText release];
    [invRsvpImage release];
    [invRsvpLabel release];
    [invRsvpAltLabel release];
    [identityProvider release];
    [identityWaring release];
    [identityName release];
    [bioTitle release];
    [bioContent release];
    [invContent release];
    [flowLayout release];
    
    [exfeeContainer release];
    
    [rsvpMenu release];
    
    [rsvpDict release];
    [myRsvpDict release];
    
    [super dealloc];
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        NSLog(@"willMoveToParentViewController widgetexfee.exfee");
        [self.exfee debugPrint];
        
        [self.onExitBlock invoke];
    }
}

#pragma mark - Test
- (void)hereButtonPressed:(id)sender {
    HereViewController *viewController = [[HereViewController alloc] init];
    viewController.exfee = self.exfee;
    viewController.needSubmit = NO;
    viewController.finishHandler = ^{
        NSLog(@"WidgetExfee callback");
        NSLog(@"viewController.exfee:");
        [viewController.exfee debugPrint];
        NSLog(@"self.exfee:");
        [self.exfee debugPrint];
        
        self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
        [exfeeContainer reloadData];
        
        if ([self.sortedInvitations count] >= 12) { // TODO we want to move the hard limit to server result
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exfees Limit" message:[NSString stringWithFormat:@"This ·X· is limited to 12 participants."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }

    };
    
    [self presentViewController:viewController
                       animated:YES
                     completion:nil];
    [viewController release];
}

#pragma mark Click handler
- (void)removeInvitation:(id)sender
{
    UIView *btn = sender;
    btn.hidden = YES;
    
    NSString *title = @"People will no longer have access to any information in this ·X·. Please confirm to remove.";
    NSString *destTitle = @"Remove from this ·X·";
    if ([[User getDefaultUser] isMe:_selected_invitation.identity]) {
        title = @"You will no longer have access to any information in this ·X· once left. Please confirm to leave.";
        destTitle = @"Leave from this ·X·";
    }
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:title
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:destTitle
                                                   otherButtonTitles:nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    
	[popupQuery showInView:self.view];
	[popupQuery release];
}

#pragma mark UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        _selected_invitation.rsvp_status = @"REMOVED";
        
        Identity *myidentity = [self.exfee getMyInvitation].identity;
        [APIExfee edit:self.exfee
            myIdentity:[myidentity.identity_id intValue]
               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                   if ([operation.HTTPRequestOperation.response statusCode] == 200){
                       if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
                       {
                           Meta* meta = (Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                           int code = [meta.code intValue];
                           int type = code /100;
                           switch (type) {
                               case 2: // HTTP OK
                                   if(code == 200){
                                       Exfee *respExfee = [[mappingResult dictionary] objectForKey:@"response.exfee"];
                                       //[self.exfee removeInvitationsObject:selected_invitation];
                                       _selected_invitation = nil;
                                       self.exfee = respExfee;
                                       self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
                                       
                                       [exfeeContainer reloadData];
                                       [self reloadSelected];
                                       
                                   }
                                   break;
                               default:
                                   break;
                           }
                           
                           
                           
                       }
                   }
               }
               failure:^(RKObjectRequestOperation *operation, NSError *error) {
                   ;
               }];
    }
}

#pragma mark Gesture Handler
- (void)swypeDelete:(UITapGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (CGRectContainsPoint([Util expandRect:identityProvider.frame with:identityName.frame], location)) {
            [self hidePopupIfShown:kPopupIdRemoveIdentity];
            CGRect f = RemoveButton.frame;
            f.origin.x = CGRectGetWidth(invContent.bounds) - CGRectGetWidth(f) - 15;
            f.origin.y = CGRectGetMinY(identityName.frame);
            RemoveButton.frame = f;
            RemoveButton.hidden = NO;
        }
    }
}

- (void)tapContent:(UITapGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        //UIView *tappedView = [sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
        
        if (CGRectContainsPoint([Util expandRect:invRsvpImage.frame with:invRsvpLabel.frame with:invRsvpAltLabel.frame], location)) {
            [self hidePopupIfShown:kPopupIdRsvpMenu];
            
            NSDictionary *data = rsvpDict;
            
            if ([[User getDefaultUser] isMe:_selected_invitation.identity]) {
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
            
            [self show:rsvpMenu at:[sender.view convertPoint:invRsvpLabel.frame.origin toView:self.view] withAnimation:YES];
            
            return;
        } else if (RemoveButton.hidden == NO  && CGRectContainsPoint(RemoveButton.frame, location) ) {
            [RemoveButton sendActionsForControlEvents: UIControlEventTouchUpInside];
        }
    }
}

#pragma mark Fill content and Layout
- (void)fillInvitationContent:(Invitation*)inv
{
    [self fillIdentity:inv.identity];
    [self fillHost:inv];
    [self fillRsvp:inv];
    [self LayoutViews];
}

- (void)fillIdentity:(Identity*)ident
{
    if (ident) {
        NSString* name = [ident getDisplayName];
        if (![invName.text isEqualToString:name]) {
            invName.text = name;
            [invName wrapContent];
            [self setNeedLayout:invName.tag];
        }
        
        NSString* at_id = [ident getDisplayIdentity];
        if (![identityName.text isEqualToString:at_id]) {
            identityName.text = at_id;
        }

        Provider p = [Identity getProviderCode:ident.provider];
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
        
        bioTitle.hidden = !(ident && ident.bio.length > 0);
        bioContent.text = ident.bio;
        [bioContent wrapContent];
    }
}

- (void)fillHost:(Invitation*)inv
{
    if (inv) {
        BOOL shouldHidden = ![inv.host boolValue];
        if (invHostText.hidden != shouldHidden) {
            invHostText.hidden = shouldHidden;
            [self setNeedLayout:kTagIdHostFlag];
        }
        
        if (invHostFlag.hidden != shouldHidden) {
            invHostFlag.hidden = shouldHidden;
            [self setNeedLayout:kTagIdHostFlag];
        }
    }
}

- (void)fillRsvp:(Invitation*)inv
{
    if (inv) {
        NSUInteger changeFlag = kTagIdNone;
        RsvpCode rsvp = [Invitation getRsvpCode:inv.rsvp_status];
        switch (rsvp) {
            case kRsvpAccepted:
            {
                invRsvpImage.image = [UIImage imageNamed:@"rsvp_accepted_stroke_26blue"];
                
                CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 18.0, NULL);
                CTFontRef textfontref2 = CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 18.0, NULL);
                NSAttributedString *acceptStr = [[NSMutableAttributedString alloc] initWithString:@"Accepted"
                                                                                       attributes:@{(NSString*)kCTFontAttributeName: (id)textfontref,
                                                 (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_BLUE_EXFE].CGColor}];
                
                if ([inv.mates intValue] > 0) {
                    NSString *strWithMates = [NSString stringWithFormat:@"[Accepted] with %i mates", [inv.mates intValue]];
                    NSMutableAttributedString *fullStr = [[NSMutableAttributedString alloc] initWithString:strWithMates
                                                                                                attributes:@{(NSString*)kCTFontAttributeName:(id)textfontref2,
                                                          (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_BLUE_EXFE].CGColor}];
                    [fullStr replaceCharactersInRange:[strWithMates rangeOfString:@"[Accepted]"] withAttributedString:acceptStr];
                    invRsvpLabel.attributedText = fullStr;
                    [invRsvpLabel setNeedsDisplay];
                    [fullStr release];
                }else{
                    invRsvpLabel.attributedText = acceptStr;
                    [invRsvpLabel setNeedsDisplay];
                }
                [acceptStr release];
                CFRelease(textfontref);
                CFRelease(textfontref2);
            }
                break;
            case kRsvpDeclined:
            {
                invRsvpImage.image = [UIImage imageNamed:@"rsvp_unavailable_stroke_26g5"];
                
                CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 18.0, NULL);
                NSAttributedString *pending = [[NSMutableAttributedString alloc] initWithString:@"Declined"
                                                                                     attributes:@{(NSString*)kCTFontAttributeName: (id)textfontref,
                                               (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_ALUMINUM].CGColor}];
                invRsvpLabel.attributedText = pending;
                [invRsvpLabel setNeedsDisplay];
                [pending release];
                CFRelease(textfontref);
            }
                break;
            case kRsvpInterested:
            {
                invRsvpImage.image = [UIImage imageNamed:@"rsvp_pending_stroke_26g5"];
                
                CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 18.0, NULL);
                NSAttributedString *pending = [[NSMutableAttributedString alloc] initWithString:@"Intersted"
                                                                                     attributes:@{(NSString*)kCTFontAttributeName: (id)textfontref,
                                               (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_ALUMINUM].CGColor}];
                invRsvpLabel.attributedText = pending;
                [invRsvpLabel setNeedsDisplay];
                [pending release];
                CFRelease(textfontref);
            }
                break;
                // no use
            case kRsvpRmoved:
            case kRsvpNotification:
                // should not be used here
                break;
                
                //pending
            case kRsvpIgnored:
            case kRsvpNoResponse:
            default:{
                invRsvpImage.image = [UIImage imageNamed:@"rsvp_pending_stroke_26g5"];
                
                CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 18.0, NULL);
                NSAttributedString *pending = [[NSMutableAttributedString alloc] initWithString:@"Pending"
                                                                                     attributes:@{(NSString*)kCTFontAttributeName: (id)textfontref,
                                               (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_ALUMINUM].CGColor}];
                invRsvpLabel.attributedText = pending;
                [invRsvpLabel setNeedsDisplay];
                [pending release];
                CFRelease(textfontref);
            }
                break;
        }
        if ([inv.identity.unreachable boolValue]){
            CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 18.0, NULL);
            NSAttributedString *pending = [[NSMutableAttributedString alloc] initWithString:@"Unreachable contact"
                                                                                 attributes:@{(NSString*)kCTFontAttributeName: (id)textfontref,
                                           (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_RGB(0xE5, 0x2E, 0x53)].CGColor}];
            invRsvpLabel.attributedText = pending;
            [invRsvpLabel setNeedsDisplay];
            [pending release];
            CFRelease(textfontref);
        }
        
        NSString *altString = @"";
        if (inv.updated_at != nil) {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:inv.updated_at];
            [gregorian release];
            altString = [DateTimeUtil GetRelativeTime:comps format:0];
        }
        if ([inv.updated_by.connected_user_id intValue]!= [inv.identity.connected_user_id intValue]){
            if (altString && altString.length > 0) {
                altString = [NSString stringWithFormat:@"Set by %@ %@", [inv.updated_by getDisplayName], altString];
            }else{
                 altString = [NSString stringWithFormat:@"Set by %@", [inv.updated_by getDisplayName]];
            }
        }
        invRsvpAltLabel.text = [altString sentenceCapitalizedString];
        [invRsvpAltLabel wrapContent];
        [self setNeedLayout:changeFlag];
    }
}

- (void)setNeedLayout
{
    [self setNeedLayout:kTagIdMax];
}

- (void)setNeedLayout:(NSUInteger)level
{
    if (level > layoutLevel) {
        layoutLevel = level;
    }
}

- (void)clearLayoutLevel
{
    layoutLevel = kTagIdNone;
}

- (void)LayoutViews
{
    if (layoutLevel > kTagIdNone) {
        CGPoint start = CGPointZero;
        
        if (layoutLevel >= kTagIdName) {

                CGSize size = [invName sizeWrapContent:CGSizeMake(CGRectGetWidth(invName.bounds), MAXFLOAT)];
                CGFloat w = size.width;
//                if (w > CGRectGetWidth(invName.bounds)) {
//                    w = CGRectGetWidth(invName.bounds);
//                }
                CGFloat x = w + CGRectGetMinX(invName.frame);
                CGRect f1 = invHostFlag.frame;
                f1.origin.x = x + 12;
                invHostFlag.frame = f1;
                
                CGRect f2 = invHostText.frame;
                f2.origin.x = CGRectGetMaxX(f1);
                invHostText.frame = f2;
            
        }
        
        start.x = CGRectGetMaxX(invHostText.frame);
        start.y = MAX(CGRectGetMaxY(invHostText.frame), CGRectGetMaxY(invName.frame));
        
        if (layoutLevel >= kTagIdRSVPAltLabel) {
            
            [CATransaction begin];
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            CGRect frame = layer1.frame;
            frame.origin.y = start.y + 4;
            layer1.frame = frame;
            
            frame = layer4.frame;
            frame.origin.y = start.y + 4;
            layer4.frame = frame;
            [CATransaction commit];
            
            frame = invRsvpImage.frame;
            frame.origin.y = CGRectGetMaxY(layer1.frame) + 12;
            invRsvpImage.frame = frame;
            
            frame = invRsvpLabel.frame;
            frame.origin.y = CGRectGetMaxY(layer1.frame) + 14;
            invRsvpLabel.frame = frame;
            
            frame = invRsvpAltLabel.frame;
            frame.origin.y = CGRectGetMaxY(invRsvpLabel.frame) + 1;
            invRsvpAltLabel.frame = frame;
        }
        
        start.x = CGRectGetMaxX(invRsvpLabel.frame);
        start.y = MAX(CGRectGetMaxY(invRsvpImage.frame), CGRectGetMaxY(invRsvpAltLabel.frame));
        
        if (layoutLevel >= kTagIdIdentityName) {
            [CATransaction begin];
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            CGRect frame = layer2.frame;
            frame.origin.y = start.y + 9;
            layer2.frame = frame;
            [CATransaction commit];
            
            frame = identityProvider.frame;
            frame.origin.y = CGRectGetMaxY(layer2.frame) + 6;
            identityProvider.frame = frame;
            
            frame = identityWaring.frame;
            frame.origin.y = CGRectGetMaxY(layer2.frame) + 6;
            identityWaring.frame = frame;
            
            frame = identityName.frame;
            frame.origin.y = CGRectGetMaxY(layer2.frame) + 0;
            identityName.frame = frame;
        }
        
        start.x = CGRectGetMaxX(identityProvider.frame);
        start.y = MAX(CGRectGetMaxY(identityProvider.frame), CGRectGetMaxY(identityName.frame));
        
        if (layoutLevel >= kTagIdBioContent) {
            [CATransaction begin];
            [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
            CGRect frame = layer3.frame;
            frame.origin.y = start.y + 0;
            layer3.frame = frame;
            [CATransaction commit];
            
            frame = bioTitle.frame;
            frame.origin.y = CGRectGetMaxY(layer3.frame) + 16;
            bioTitle.frame = frame;
            
            frame = bioContent.frame;
            frame.origin.y = CGRectGetMaxY(layer3.frame) + 16;
            bioContent.frame = frame;
        }
        
        start.x = CGRectGetMaxX(bioContent.frame);
        start.y = MAX(CGRectGetMaxY(bioTitle.frame), CGRectGetMaxY(bioContent.frame));
        
        invContent.contentSize = CGSizeMake(MAX(CGRectGetWidth(invContent.frame), start.x), start.y + 10);
        [self clearLayoutLevel];
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
                cell.description.text = [NSString stringWithFormat:@"%u / %u", [self.exfee.accepted integerValue], [self.exfee.total integerValue]];
                return cell;
            }else{
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
                
                [[ImgCache sharedManager] fillAvatar:cell.avatar with:inv.identity.avatar_filename byDefault:[UIImage imageNamed:@"portrait_default.png"]];
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
            return CGSizeMake(300, CGRectGetHeight(invContent.frame) + kBottomMargin);
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
//            [self hideMenu];
            ExfeeInputViewController *viewController=[[ExfeeInputViewController alloc] initWithNibName:@"ExfeeInputViewController" bundle:nil];
            viewController.lastViewController = self;
            viewController.exfee = self.exfee;
            viewController.needSubmit = YES;
            viewController.onExitBlock = ^{
                self.exfee = viewController.exfee;
                
                self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
                [exfeeContainer reloadData];
            };
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
        }else{
            [self hidePopupIfShown];
            PSTCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            [self clickCell:cell];
            _selected_invitation = [self.sortedInvitations objectAtIndex:indexPath.row];
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
            switch (abc) {
                case 0:
                    if (_selected_invitation && [Invitation getRsvpCode:_selected_invitation.rsvp_status] != kRsvpAccepted) {
                        [self sendrsvp:@"ACCEPTED" invitation:_selected_invitation];
                    }
                    break;
                case 1:
                    [self sendrsvp:@"DECLINED" invitation:_selected_invitation];
                    break;
                case 2:
                    [self sendrsvp:@"INTERESTED" invitation:_selected_invitation];
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
- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation{
    
    Identity *myidentity = [self.exfee getMyInvitation].identity;
    [APIExfee submitRsvp: status
                      on: _invitation
              myIdentity: myidentity.identity_id
                 onExfee: [self.exfee.exfee_id intValue]
                 success: ^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     if ([operation.response statusCode] == 200){
                         if([responseObject isKindOfClass:[NSDictionary class]])
                         {
                             NSDictionary* meta=(NSDictionary*)[responseObject objectForKey:@"meta"];
                             if([[meta objectForKey:@"code"] intValue]==403){
//                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                                 alert.tag=403;
//                                 [alert show];
//                                 [alert release];
                             }else if([[meta objectForKey:@"code"] intValue]==200){
                                 NSLog(@"submit rsvp sucessfully...");
                                 CrossGroupViewController *parent = (CrossGroupViewController*)self.parentViewController;
                                 [APICrosses LoadCrossWithCrossId:[parent.cross.cross_id intValue] updatedtime:@"" success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     
                                     if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
                                     {
                                         Meta* meta=(Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                                         if([meta.code intValue]==200){
                                             self.exfee = parent.cross.exfee;
                                             self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
                                             [exfeeContainer reloadData];
                                             [self reloadSelected];
                                         }
                                         
                                     }
                                 } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                     
                                 }];
                                 self.exfee = parent.cross.exfee;
                                 [exfeeContainer reloadData];
                             }
                             
                         }
                     }
                 }
                 failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
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
    for (NSUInteger i = 0; i < self.sortedInvitations.count; i++) {
        Invitation* inv = [self.sortedInvitations objectAtIndex:i];
        if ([inv.invitation_id integerValue] == [self.selected_invitation.invitation_id integerValue]) {
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
        [exfeeContainer selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self fillInvitationContent:_selected_invitation];
    }
}
@end
