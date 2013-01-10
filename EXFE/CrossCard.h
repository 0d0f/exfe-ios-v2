//
//  CrossCard.h
//  EXFE
//
//  Created by Stony on 12/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"
#import <CoreText/CoreText.h>

@protocol CrossCardDelegate <NSObject>
@required
- (void) onClickConversation:(UIView*)card;
@end


@interface CrossCard : ABTableViewCell<UIGestureRecognizerDelegate>{
    NSString *title;
    UIImage *avatar;
    NSString *time;
    NSString *place;
    UIImage *bannerimg;
    NSInteger conversationCount;
    BOOL hlTitle;
    BOOL hlTime;
    BOOL hlPlace;
    BOOL hlConversation;
    NSNumber * cross_id;
    
    CGRect barnnerRect;
    CGRect textbarRect;
    CGRect titleRect;
    CGRect avatarRect;
    CGRect timeRect;
    CGRect convRect;
    CGRect placeRect;
    
    id<CrossCardDelegate> delegate;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *place;
@property (nonatomic, retain) UIImage *avatar;
@property (nonatomic, retain) UIImage *bannerimg;
@property (nonatomic) NSInteger conversationCount;
@property (nonatomic) BOOL hlTitle;
@property (nonatomic) BOOL hlTime;
@property (nonatomic) BOOL hlPlace;
@property (nonatomic) BOOL hlConversation;
@property (nonatomic, retain) NSNumber *cross_id;
@property (nonatomic, retain) id<CrossCardDelegate> delegate;



@end


