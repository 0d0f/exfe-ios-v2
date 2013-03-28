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


#define kTagViewExfeeRoot         10
#define kTagViewExfeeSelector     20
#define kTagViewExfeeContent      30

#define kTableFloating   222
#define kTableOrigin     223

#define kMenuTagRsvp 8901
#define kMenuTagAction 8902
#define kMenuTagMate 8903

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
        selected_invitation = nil;
        
        rsvpDict = @{ @"header": @"Set response to:",
                      @"item0": @{ @"main": @"Accepted",
                                   @"style": @"Highlight"
                                   },
                      @"item1": @{ @"main": @"Unavailable",
                                   @"style": @"Normal"
                                   },
                      @"item2": @{ @"main": @"Interested",
                                   @"style": @"Normal"
                                   },
                      @"item3": @{ @"main": @"+ mates...",
                                   @"style": @"Lowlight"
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
                                     },
                        @"item3": @{ @"main": @"+ mates...",
                                     @"style": @"Lowlight"
                                     }
                        };
        [myRsvpDict retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect a = [UIScreen mainScreen].applicationFrame;
    CGRect b = self.view.bounds;
    self.view.tag = kTagViewExfeeRoot;
    
    if (self.exfee) {
        self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeHostAcceptOthers];
    }
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    exfeeContainer = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(b), CGRectGetHeight(a) - 44) collectionViewLayout:flowLayout];
    [flowLayout release];
    exfeeContainer.delegate = self;
    exfeeContainer.dataSource = self;
    [exfeeContainer registerClass:[ExfeeCollectionViewCell class] forCellWithReuseIdentifier:@"Exfee Cell"];
    [exfeeContainer registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Blank Cell"];
    [exfeeContainer registerClass:[ExfeeAddCollectionViewCell class] forCellWithReuseIdentifier:@"Add Cell"];
    exfeeContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"conv_bg.png"]];
    exfeeContainer.alwaysBounceVertical = YES;
    exfeeContainer.contentOffset = CGPointMake(0, 0);
//    exfeeContainer.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
    exfeeContainer.tag = kTagViewExfeeSelector;
    [self.view addSubview:exfeeContainer];
    
    CGFloat exfee_content_height = CGRectGetHeight(exfeeContainer.frame) - 94 * (2 + (CGRectGetHeight(a) > 480 ? 1 : 0));
    invContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), exfee_content_height)];
    invContent.backgroundColor = [UIColor COLOR_SNOW];
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
        
        
        invName = [[ UILabel alloc] initWithFrame:CGRectMake(25, 16, 230, 25)];
        invName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
        invName.textColor = [UIColor COLOR_CARBON];
        invName.backgroundColor = [UIColor clearColor];
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
        
        bioTitle = [[UILabel alloc] initWithFrame:CGRectMake(36, 115 + 32, 43, 33)];
        bioTitle.text = @"Bio";
        bioTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        bioTitle.textColor = [UIColor COLOR_BLACK];
        bioTitle.backgroundColor = [UIColor clearColor];
        bioTitle.tag = kTagIdBioTitle;
        bioTitle.hidden = YES;
        [invContent addSubview:bioTitle];
        
        bioContent = [[UILabel alloc] initWithFrame:CGRectMake(75, 115 + 48, 220, 80)];
        bioContent.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        bioContent.textColor = [UIColor COLOR_BLACK];
        bioContent.backgroundColor = [UIColor clearColor];
        bioContent.tag = kTagIdBioContent;
        bioContent.hidden = YES;
        [invContent addSubview:bioContent];
        
        ActionMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        ActionMenu.frame = CGRectMake(255, 146, 40, 31);
        ActionMenu.hidden = YES;
        ActionMenu.tag = kTagIdActionMenu;
        [invContent addSubview:ActionMenu];
        
        
        RemoveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* img = [[UIImage imageNamed:@"iphone_delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f];
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
    [exfeeContainer addSubview:invContent];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContent:)];
    [invContent addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swypeDelete:)];
    [invContent addGestureRecognizer:swipe];
    
}

- (void)viewWillAppear:(BOOL)animated
{
}
- (void)viewDidAppear:(BOOL)animated
{
    NSArray *array = [exfeeContainer indexPathsForSelectedItems];
    if (array == nil || array.count == 0) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [exfeeContainer selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        selected_invitation = [self.sortedInvitations objectAtIndex:0];
        [self fillInvitationContent:selected_invitation];
    }
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
#pragma mark Click handler
- (void)removeInvitation:(id)sender
{
    UIView *btn = sender;
    btn.hidden = YES;
    
    NSString *title = @"People will no longer has access to any information in this ·X· once removed. Please confirm to remove.";
    NSString *destTitle = @"Remove from this ·X·";
    if ([[User getDefaultUser] isMe:selected_invitation.identity]) {
        destTitle = @"Leave from this ·X·";
        title = @"You will no longer has access to any information in this ·X· once left. Please confirm to leave.";
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
        NSArray *array = [exfeeContainer indexPathsForSelectedItems];
        selected_invitation.rsvp_status = @"REMOVED";
        
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
                                       selected_invitation = nil;
                                       self.exfee = respExfee;
                                       self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeHostAcceptOthers];
                                       [exfeeContainer reloadData];
                                       
                                       if (array == nil || array.count <= 1) {
                                           NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                                           [exfeeContainer selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                                           selected_invitation = [self.sortedInvitations objectAtIndex:0];
                                           [self fillInvitationContent:selected_invitation];
                                       }
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
            NSDictionary *data = rsvpDict;
            
            if ([[User getDefaultUser] isMe:selected_invitation.identity]) {
                data = myRsvpDict;
            }
            
            if (rsvpMenu == nil) {
                rsvpMenu = [[EXBasicMenu alloc] initWithFrame:CGRectMake(0, 0, 125, 20 + 44 * 4) andContent:
                            data];
                rsvpMenu.delegate = self;
                rsvpMenu.tag = kMenuTagRsvp;
                [self.view addSubview:rsvpMenu];
            }else{
                [rsvpMenu setContent:data];
            }
            
            [self show:rsvpMenu at:[sender.view convertPoint:invRsvpLabel.frame.origin toView:self.view] withAnimation:YES];
            
            return;
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
        
        bioContent.text = ident.bio;
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
        invRsvpAltLabel.text = altString;
        
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
        if (layoutLevel >= kTagIdName) {
            if (invName.text) {
                CGSize size = [invName.text sizeWithFont:invName.font];
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
        
        
        [self clearLayoutLevel];
    }
}


#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
        {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Blank Cell" forIndexPath:indexPath];
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger seq = row % 4;
    switch (section) {
        case 0:
            return CGSizeMake(300, CGRectGetHeight(invContent.frame));
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
            return UIEdgeInsetsMake(0, 0, 0, 0);
        case 1:
            return UIEdgeInsetsMake(0, 0, 0, 0);
        default:
            return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
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
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section == 1) {
        if (indexPath.row == self.sortedInvitations.count){
//            [self hideMenu];
            ExfeeInputViewController *viewController=[[ExfeeInputViewController alloc] initWithNibName:@"ExfeeInputViewController" bundle:nil];
            viewController.lastViewController = self;
            viewController.exfee = self.exfee;
            viewController.needSubmit = YES;
            viewController.onExitBlock = ^{
                NSLog(@"WidgetExfee callback");
                NSLog(@"viewController.exfee:");
                [viewController.exfee debugPrint];
                NSLog(@"self.exfee:");
                [self.exfee debugPrint];
//                self.exfee = viewController.exfee;
                
                self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeMeAcceptOthers];
                [exfeeContainer reloadData];
                
                if ([self.sortedInvitations count] >= 12) { // TODO we want to move the hard limit to server result
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exfees Limit" message:[NSString stringWithFormat:@"This ·X· is limited to 12 participants."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            };
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
        }else{
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            [self testClick:cell];
            selected_invitation = [self.sortedInvitations objectAtIndex:indexPath.row];
            [self fillInvitationContent:selected_invitation];
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
        
        CGPoint offset = scrollView.contentOffset;
        ScrollDirection direction = ScrollDirectionNone;
        
        if (_lastContentOffset.x >= 0) {
            if (offset.y > _lastContentOffset.y) {
                direction = ScrollDirectionUp;
            }else{
                direction = ScrollDirectionDown;
            }
        }
        _lastContentOffset = offset;
        
        if (invContent.tag == kTableFloating) {
            if (direction == ScrollDirectionDown){
//                NSLog(@"Block view position when floating with drop down: %@", NSStringFromCGPoint(offset));
                if (offset.y < CGRectGetMinY(invContent.frame)) {
                    CGRect newFrame = CGRectOffset(invContent.bounds, 0, MAX(offset.y, 0));
                    invContent.frame = newFrame;
                }
                return;
            }
            
            if (offset.y > CGRectGetMaxY(invContent.frame)){
//                NSLog(@"Convert floating to origin: %@", NSStringFromCGPoint(offset));
                CGRect newFrame = CGRectOffset(invContent.bounds, 0, 0);
                invContent.frame = newFrame;
                invContent.tag = kTableOrigin;
                return;
            }
        }
        
    }
    
}

- (void)testClick:(id)sender{
    UIView* btn = sender;
    
    CGPoint offset = exfeeContainer.contentOffset;
    BOOL flag = NO;
    if (CGRectGetMinY(btn.frame) - offset.y < CGRectGetHeight(invContent.frame)) {
        // click target is upper than the normal area
        offset = CGPointMake(offset.x, MAX(CGRectGetMinY(btn.frame) - CGRectGetHeight(invContent.frame), 0));
        flag = YES;
    } else if(CGRectGetMaxY(btn.frame) - offset.y > CGRectGetHeight(exfeeContainer.bounds)){
        // click target is lower than the normal area
        offset = CGPointMake(offset.x, MAX(CGRectGetMaxY(btn.frame) - CGRectGetHeight(exfeeContainer.bounds), 0));
        flag = YES;
    }
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.4];
    invContent.frame = CGRectOffset(invContent.bounds, offset.x, offset.y);
    if (flag) {
        exfeeContainer.contentOffset = offset;
        //exfeeContainer.bounds.y += offset.y - exfeeContainer.contentOffset.y; // for animation
    }
    [UIView commitAnimations];
    invContent.tag = kTableFloating;
    
}

- (void)show:(EXBasicMenu*)menu at:(CGPoint)location withAnimation:(BOOL)animated
{
    CGRect f = menu.frame;
    f.origin.x = CGRectGetWidth(self.view.bounds);
    f.origin.y = location.y;
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
            [self hide:rsvpMenu withAnmiation:YES];
            NSInteger abc = [index integerValue];
            switch (abc) {
                case 0:
                    if (selected_invitation && [Invitation getRsvpCode:selected_invitation.rsvp_status] != kRsvpAccepted) {
                        [self sendrsvp:@"ACCEPTED" invitation:selected_invitation];
                    }
                    break;
                case 1:
                    [self sendrsvp:@"DECLINED" invitation:selected_invitation];
                    break;
                case 2:
                    [self sendrsvp:@"INTERESTED" invitation:selected_invitation];
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
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                 alert.tag=403;
                                 [alert show];
                                 [alert release];
                             }else if([[meta objectForKey:@"code"] intValue]==200){
                                 NSLog(@"submit rsvp sucessfully...");
                                 CrossGroupViewController *parent = (CrossGroupViewController*)self.parentViewController;
                                 [APICrosses LoadCrossWithCrossId:[parent.cross.cross_id intValue] updatedtime:@"" success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                     
                                     if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
                                     {
                                         Meta* meta=(Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                                         if([meta.code intValue]==200){
                                             self.exfee = parent.cross.exfee;
                                             self.sortedInvitations = [self.exfee getSortedInvitations:kInvitationSortTypeHostAcceptOthers];
                                             [exfeeContainer reloadData];
                                             
                                             for (NSUInteger i = 0; i < self.sortedInvitations.count; i++) {
                                                 Invitation* inv = [self.sortedInvitations objectAtIndex:i];
                                                 if ([_invitation.invitation_id intValue] == [inv.invitation_id intValue]) {
                                                     [exfeeContainer selectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                                                 }
                                             }
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
@end
