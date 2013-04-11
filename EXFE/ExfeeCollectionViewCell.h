//
//  ExfeeCollectionViewCell.h
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "Invitation+EXFE.h"

typedef NS_ENUM(NSUInteger, SequencePosition){
    kPosUnknown,
    kPosFirst,
    kPosMiddle,
    kPosLast
};

@interface ExfeeCollectionViewCell : PSTCollectionViewCell{
    
    UIImageView *_rsvpImage;
    UIImageView *_avatarFrame;
    CALayer *_matesBg;
    CATextLayer *_matesLayer;
    
//    CGRect _matesRect;
    
    CGRect rectAvatar;
    CGRect rectAvatarFrame;
    CGRect rectRsvpImage;
    CGRect rectName;
    CGRect rectMates;
}

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, assign) RsvpCode rsvp;
@property (nonatomic, assign) BOOL unreachable;
@property (nonatomic, assign) BOOL host;
@property (nonatomic, assign) NSUInteger mates;
@property (nonatomic, retain) NSNumber *invitation_id;
@property (nonatomic, assign) SequencePosition sequence;

- (void)setRsvp:(RsvpCode)rsvp andUnreachable:(BOOL)unreachable withHost:(BOOL)host;
@end
