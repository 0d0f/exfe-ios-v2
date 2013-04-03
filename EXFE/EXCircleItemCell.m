//
//  EXCircleItemCell.m
//  EXHereDemo
//
//  Created by 0day on 13-3-29.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import "EXCircleItemCell.h"

#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "Util.h"
#import "ImgCache.h"
#import "EXCard.h"
#import "Card.h"

@interface EXCircleItemCell ()
@property (nonatomic, assign) BOOL isUsingDefaultAvatar;
- (void)tapHandler:(UITapGestureRecognizer *)recognizer;
- (void)longPressHandler:(UILongPressGestureRecognizer *)recognizer;

- (void)_setAvatarImage:(UIImage *)image;
@end

@implementation EXCircleItemCell {
    CGFloat _centerDistanceY;
}

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXLiveViewCell"
                                           owner:nil
                                         options:nil] lastObject] retain];
    
    // avatar
    self.avatarImageView.layer.cornerRadius = 30;
    self.avatarImageView.clipsToBounds = YES;
    
    // center
    _centerDistanceY = self.center.y - self.avatarBaseView.center.y;
    
    // label
    EXVerticalAlignLabel *label = [[EXVerticalAlignLabel alloc] initWithFrame:(CGRect){{0, 71}, {75, 35}}];
    label.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
    label.numberOfLines = 2;
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:label];
    self.titleLabel = label;
    [label release];
    
    // tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    [self.avatarBaseView addGestureRecognizer:tap];
    [tap release];
    
    // long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPressHandler:)];
    [self.avatarBaseView addGestureRecognizer:longPress];
    [longPress release];
    
    return self;
}

- (void)dealloc {
    [_indexPath release];
    [_card release];
    [_avatarBaseView release];
    [_titleLabel release];
    [_selectedMaskView release];
    [_avatarImageView release];
    [super dealloc];
}

#pragma mark - Getter && Setter
- (CGPoint)avatarCenter {
    return self.avatarBaseView.center;
}

- (void)setAvatarCenter:(CGPoint)avatarCenter {
    self.center = (CGPoint){avatarCenter.x, avatarCenter.y + _centerDistanceY};
}

- (void)setCard:(Card *)card {
    if (card == _card)
        return;
    
    if (_card && card && [_card isEqualToCard:card]) {
        NSString *perCardAvatarURL = _card.avatarURLString;
        [_card release];
        _card = [card copy];
        
        self.titleLabel.text = card.userName;
        [self.titleLabel sizeToFit];
        
        if (![card.avatarURLString isEqualToString:perCardAvatarURL]) {
            dispatch_queue_t image_queue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(image_queue, ^{
                UIImage *avatarImage=[[ImgCache sharedManager] getImgFrom:card.avatarURLString];
                if(avatarImage != nil && ![avatarImage isEqual:[NSNull null]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([card isEqualToCard:self.card]) {
                            [self _setAvatarImage:avatarImage];
                        }
                    });
                }
            });
            dispatch_release(image_queue);
        }
    } else {
        if (_card) {
            self.titleLabel.text = @"";
            [self _setAvatarImage:nil];
            [_card release];
            _card = nil;
        }
        
        if (card) {
            _card = [card copy];
            
            self.titleLabel.text = card.userName;
            [self.titleLabel sizeToFit];
            
            dispatch_queue_t image_queue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(image_queue, ^{
                UIImage *avatarImage=[[ImgCache sharedManager] getImgFrom:card.avatarURLString];
                if(avatarImage != nil && ![avatarImage isEqual:[NSNull null]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([card isEqualToCard:self.card]) {
                            [self _setAvatarImage:avatarImage];
                        }
                    });
                }
            });
            dispatch_release(image_queue);
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:NO complete:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated complete:(void (^)(void))handler {
    if (selected == _selected)
        return;
    _selected = selected;
    
    [UIView setAnimationsEnabled:animated];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.selectedMaskView.alpha = selected ? 1.0f : 0.0f;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                         
                         if (handler)
                             handler();
                     }];
}

#pragma mark - Gesture

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    if (_tapBlock)
        _tapBlock();
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)recognizer {
    if (_longPressBlock)
        _longPressBlock();
}

#pragma mark - Private
- (void)_setAvatarImage:(UIImage *)image {
    if (nil == image && self.isUsingDefaultAvatar)
        return;
    if (nil == image) {
        self.isUsingDefaultAvatar = YES;
    } else {
        self.isUsingDefaultAvatar = NO;
    }
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.6f
                     animations:^{
                         self.avatarImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if (nil == image) {
                             self.avatarImageView.image = [UIImage imageNamed:@"portrait_64.png"];
                         } else {
                             self.avatarImageView.image = image;
                         }
                         [UIView animateWithDuration:0.1f
                                          animations:^{
                                              self.avatarImageView.alpha = 1.0f;
                                          }];
                     }];
}

@end
