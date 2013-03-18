//
//  WidgetExfeeViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//

#import <CoreText/CoreText.h>
#import "WidgetExfeeViewController.h"
#import "ExfeeCollectionViewCell.h"
#import "Util.h"
#import "ImgCache.h"

#define EXFEE_CONTENT_HEIGHT      (220)

#define kTagViewExfeeRoot         10
#define kTagViewExfeeSelector     20
#define kTagViewExfeeContent      30

#define kTableFloating   222
#define kTableOrigin     223

typedef enum {
    kTagIdNone = 0,
    kTagIdActionMenu,
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
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//    [flowLayout setMinimumInteritemSpacing:0.f];
//    [flowLayout setMinimumLineSpacing:0.f];
//    flowLayout.sectionInset = UIEdgeInsetsMake(2, 400, 2, 2);
    
    exfeeContainer = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(b), CGRectGetHeight(a) - 50) collectionViewLayout:flowLayout];
    [flowLayout release];
    exfeeContainer.delegate = self;
    exfeeContainer.dataSource = self;
    [exfeeContainer registerClass:[ExfeeCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [exfeeContainer registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Blank Cell"];
    exfeeContainer.backgroundColor = [UIColor darkGrayColor];
    exfeeContainer.alwaysBounceVertical = YES;
    exfeeContainer.contentOffset = CGPointMake(0, 0);
//    exfeeContainer.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
    exfeeContainer.tag = kTagViewExfeeSelector;
    [self.view addSubview:exfeeContainer];
    
    
    invContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), EXFEE_CONTENT_HEIGHT)];
    invContent.backgroundColor = [UIColor COLOR_SNOW];
    invContent.tag = kTableOrigin;
    {
        invName = [[ UILabel alloc] initWithFrame:CGRectMake(25, 16, 230, 25)];
        invName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
        invName.textColor = [UIColor COLOR_CARBON];
        invName.tag = kTagIdName;
        [invContent addSubview:invName];
        
        invHostFlag = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 57, 12)];
        invHostFlag.text = @"HOST";
        invHostFlag.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        invHostFlag.textColor = [UIColor COLOR_BLUE_EXFE];
        [invHostFlag sizeToFit];
        [invContent addSubview:invHostFlag];
        
        invRsvpImage = [[UIImageView alloc] initWithFrame:CGRectMake(33, 57, 26, 26)];
        [invContent addSubview:invRsvpImage];
        
        invRsvpLabel = [[EXAttributedLabel alloc] initWithFrame:CGRectMake(75, 60, 200, 22)];
        [invContent addSubview:invRsvpLabel];
        
        invRsvpAltLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 86, 180, 12)];
        invRsvpAltLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        invRsvpAltLabel.textColor = [UIColor COLOR_GRAY];
        [invContent addSubview:invRsvpAltLabel];
        
        identityProvider = [[UIImageView alloc] initWithFrame:CGRectMake(37, 115, 18, 18)];
        [invContent addSubview:identityProvider];
        
        identityWaring = [[UIImageView alloc] initWithFrame:CGRectMake(75, 115, 18, 18)];
        [invContent addSubview:identityWaring];
        
        identityName = [[UILabel alloc] initWithFrame:CGRectMake(75, 108, 220, 32)];
        identityName.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
        identityName.textColor = [UIColor COLOR_BLACK];
        [invContent addSubview:identityName];
        
        ActionMenu = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        ActionMenu.frame = CGRectMake(255, 146, 40, 31);
        [invContent addSubview:ActionMenu];
    }
    [exfeeContainer addSubview:invContent];
    
    selected_invitation = [self.exfee.invitations.allObjects objectAtIndex:0];
    [self fillInvitationContent:selected_invitation];
    
}

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
                identityProvider.image = [UIImage imageNamed:@"identity_facebook_18_grey.png"];
                break;
            case kProviderFacebook:
                identityProvider.image = [UIImage imageNamed:@"identity_twitter_18_grey.png"];
                break;
            default:
            break;
        }
    }
}

- (void)fillHost:(Invitation*)inv
{
    if (inv) {
        BOOL shouldHidden = ![inv.host boolValue];
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
        
        NSString *altString = nil;
        if (inv.updated_by.connected_user_id != inv.identity.connected_user_id){
            altString = [NSString stringWithFormat:@"Set by %@ %@", [inv.updated_by getDisplayName], @"xx days ago"];
        }else{
            altString =  @"xx days ago";
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
        
        
        
        [self clearLayoutLevel];
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
    [invRsvpImage release];
    [invRsvpLabel release];
    [invRsvpAltLabel release];
    [identityProvider release];
    [identityWaring release];
    [identityName release];
    [invContent release];
    
    [exfeeContainer release];
    
    [super dealloc];
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
            return self.exfee.invitations.count;
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
            ExfeeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            
            Invitation* inv = [self.exfee.invitations.allObjects objectAtIndex:row];
            cell.name.text = inv.identity.name;
            [cell setRsvp:[Invitation getRsvpCode:inv.rsvp_status] andUnreachable:[inv.identity.unreachable boolValue]];
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
            
            return cell;
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
            return CGSizeMake(300, EXFEE_CONTENT_HEIGHT);
        case 1:
            switch (seq) {
                case 0:
                case 3:
                    return CGSizeMake(82, 96);
                    //break;
                default:
                    return CGSizeMake(78, 96);
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
    NSLog(@"Selected Image is Item %d",indexPath.row);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self testClick:cell];
    selected_invitation = [self.exfee.invitations.allObjects objectAtIndex:indexPath.row];
    [self fillInvitationContent:selected_invitation];
    cell.selected = YES;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
    NSLog(@"Scroll Start");
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastContentOffset = CGPointMake(-1, -1);
    NSLog(@"Scroll Finished");
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
                NSLog(@"Block view position when floating with drop down: %@", NSStringFromCGPoint(offset));
                if (offset.y < CGRectGetMinY(invContent.frame)) {
                    CGRect newFrame = CGRectOffset(invContent.bounds, 0, MAX(offset.y, 0));
                    invContent.frame = newFrame;
                }
                return;
            }
            
            if (offset.y > CGRectGetMaxY(invContent.frame)){
                NSLog(@"Convert floating to origin: %@", NSStringFromCGPoint(offset));
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
    NSLog(@"button click: %i", btn.tag);
    
    CGPoint offset = exfeeContainer.contentOffset;
    BOOL flag = NO;
    if (CGRectGetMinY(btn.frame) - offset.y < CGRectGetHeight(invContent.frame)) {
        // click target is upper than the normal area
        offset = CGPointMake(offset.x, MAX(CGRectGetMinY(btn.frame) - 20 - CGRectGetHeight(invContent.frame), 0));
        flag = YES;
    } else if(CGRectGetMaxY(btn.frame) - offset.y > CGRectGetHeight(exfeeContainer.bounds)){
        // click target is lower than the normal area
        offset = CGPointMake(offset.x, MAX(CGRectGetMaxY(btn.frame) + 20 - CGRectGetHeight(exfeeContainer.bounds), 0));
        flag = YES;
    }
    
    invContent.frame = CGRectOffset(invContent.bounds, offset.x, offset.y);
    if (flag) {
        exfeeContainer.contentOffset = offset;
        //exfeeContainer.bounds.y += offset.y - exfeeContainer.contentOffset.y; // for animation
    }
    invContent.tag = kTableFloating;
    
}
@end
