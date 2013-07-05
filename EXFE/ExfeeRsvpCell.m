//
//  ExfeeRsvpCell.m
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "ExfeeRsvpCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation ExfeeRsvpCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CALayer *layer1 = [CALayer layer];
        layer1.frame = CGRectMake(0, 45, 320, 1);
        layer1.contents = (id)[UIImage imageNamed:@"exfee_line_h1.png"].CGImage;
        CALayer *layer2 = [CALayer layer];
        layer2.frame = CGRectMake(0, 105, 320, 1);
        layer2.contents = (id)[UIImage imageNamed:@"exfee_line_h2.png"].CGImage;
        CALayer *layer4 = [CALayer layer];
        layer4.frame = CGRectMake(65, 45, 1, 180);
        layer4.contents = (id)[UIImage imageNamed:@"exfee_line_v.png"].CGImage;
        [self.contentView.layer addSublayer:layer1];
        [self.contentView.layer addSublayer:layer2];
        [self.contentView.layer addSublayer:layer4];


        invName = [[UILabel alloc] initWithFrame:CGRectMake(25, 16 , 230, 25)];
        invName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
        invName.textColor = [UIColor COLOR_CARBON];
        invName.backgroundColor = [UIColor clearColor];
        invName.numberOfLines = 3;
        
        invName.backgroundColor = [UIColor greenColor];
//        invName.tag = kTagIdName;
        [self.contentView addSubview:invName];

        invHostFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exfee_host_blue.png"]];
        invHostFlag.frame = CGRectMake(162, 21, CGRectGetWidth(invHostFlag.frame), CGRectGetHeight(invHostFlag.frame));
//        invHostFlag.tag = kTagIdHostFlag;
        [self.contentView addSubview:invHostFlag];

        invHostText = [[UILabel alloc] initWithFrame:CGRectMake(180, 25, 57, 12)];
        invHostText.text = NSLocalizedString(@"HOST", nil);
        invHostText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        invHostText.textColor = [UIColor COLOR_BLUE_EXFE];
        [invHostText sizeToFit];
        [self.contentView addSubview:invHostText];

        invRsvpImage = [[UIImageView alloc] initWithFrame:CGRectMake(33, 57, 26, 26)];
//        invRsvpImage.tag = kTagIdRSVPImage;
        [self.contentView addSubview:invRsvpImage];

        invRsvpLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(75, 60, 200, 22)];
        invRsvpLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
//        invRsvpLabel.tag = kTagIdRSVPLabel;
        [self.contentView addSubview:invRsvpLabel];

        invRsvpAltLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 86, 180, 12)];
        invRsvpAltLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        invRsvpAltLabel.textColor = [UIColor COLOR_GRAY];
        invRsvpAltLabel.backgroundColor = [UIColor clearColor];
//        invRsvpAltLabel.numberOfLines = 0;
//        invRsvpAltLabel.tag = kTagIdRSVPAltLabel;
        [self.contentView addSubview:invRsvpAltLabel];
        
        
        [self addObserver:self
                forKeyPath:@"name"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
        [self addObserver:self
               forKeyPath:@"isHost"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        [self addObserver:self
               forKeyPath:@"unreachable"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        [self addObserver:self
               forKeyPath:@"rsvp"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        [self addObserver:self
               forKeyPath:@"mates"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        [self addObserver:self
               forKeyPath:@"additionalText"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"isHost"];
    [self removeObserver:self forKeyPath:@"unreachable"];
    [self removeObserver:self forKeyPath:@"rsvp"];
    [self removeObserver:self forKeyPath:@"mates"];
    [self removeObserver:self forKeyPath:@"additionalText"];
    
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//- (void)drawContentView:(CGRect)r
//{
//	// subclasses should implement this
//}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    BOOL isChanged = NO;
    if ([keyPath isEqualToString:@"name"]) {
        isChanged = YES;
    } else if ([keyPath isEqualToString:@"isHost"]) {
        isChanged = YES;
    } else if ([keyPath isEqualToString:@"unreachable"]) {
        isChanged = YES;
    } else if ([keyPath isEqualToString:@"rsvp"]) {
        isChanged = YES;
    } else if ([keyPath isEqualToString:@"mates"]) {
        isChanged = YES;
    } else if ([keyPath isEqualToString:@"additionalText"]) {
        isChanged = YES;
    }
    
    if (isChanged) {
        [self refresh];
    }
    
}

- (void) refresh
{
    switch (self.rsvp) {
        case kRsvpAccepted:
        {
            invRsvpImage.image = [UIImage imageNamed:@"rsvp_accepted_stroke_26blue"];
            if (self.mates > 0) {
                NSString *strWithMates = [NSString stringWithFormat:@"Accepted with %i mates", self.mates];
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
        case kRsvpNotification:
            // should not be used here
            break;
            
            //pending
        case kRsvpIgnored:
        case kRsvpNoResponse:
        default:{
            invRsvpImage.image = [UIImage imageNamed:@"rsvp_pending_stroke_26g5"];
            invRsvpLabel.textColor = [UIColor COLOR_ALUMINUM];
            invRsvpLabel.text = NSLocalizedString(@"Pending", nil);
        }
            break;
    }
    if (self.unreachable){
        CTFontRef textfontref = CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 18.0, NULL);
        NSAttributedString *pending = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Unreachable contact", nil)
                                                                             attributes:@{(NSString*)kCTFontAttributeName: (__bridge id)textfontref,
                                       (NSString*)kCTForegroundColorAttributeName:(id)[UIColor COLOR_RED_EXFE].CGColor}];
        invRsvpLabel.text = pending;
        CFRelease(textfontref);
    }
    
//    NSString *altString = @"";
//    if (inv.updated_at != nil) {
//        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSTimeZoneCalendarUnit) fromDate:inv.updated_at];
//        [gregorian release];
//        altString = [DateTimeUtil GetRelativeTime:comps format:0];
//    }
//    if ([inv.updated_by.connected_user_id intValue]!= [inv.identity.connected_user_id intValue]){
//        if (altString && altString.length > 0) {
//            altString = [NSString stringWithFormat:@"Set by %@ %@", [inv.updated_by getDisplayName], altString];
//        }else{
//            altString = [NSString stringWithFormat:@"Set by %@", [inv.updated_by getDisplayName]];
//        }
//    }
//    invRsvpAltLabel.text = [altString sentenceCapitalizedString];
//    [invRsvpAltLabel wrapContent];
    
}
@end
